// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.20 <0.9.0;

import "@tw3/solidity/contracts/utils/String.sol";

// edited by ChatGPT to add natspec and events

/**
 * @title UserDatabase Library
 * @dev A contract for managing user data and profiles.
 */

/**
 * @dev Struct to store user data.
 */
struct UserData {
    bool indexUser;
    uint256 registrationDate;
    address defaultAddress;
    string userName;
    string userBio;
    string imgUrl;
    Profile[] linkedProfiles;
}

/**
 * @dev Struct to store linked profiles.
 */
struct Profile {
    uint256 platformId;
    string id;
    address _address;
}

 abstract contract UserDatabaseV2 {
    using String for string;

    constructor() {
        Min_Timestamp = block.timestamp;

        // set private user data
        _setUserData(1, UserData(
            true,
            0,
            address(1),
            "Private User",
            "This user has chosen not to index their account",
            "/assets/images/private.png",
            new Profile[](0)
        ));
    }

    uint256 immutable Min_Timestamp;
    uint8 constant RESERVED_ID = 255;

    /**
     * @dev Mapping to store the ID of a user by their username.
     */
    mapping (string => uint256) _idOfName;

    /**
     * @dev Mapping to store the ID of a user by their address.
     */
    mapping (address => uint256) _idOfAddress;

    /**
     * @dev Mapping to store user data by their ID.
     */
    mapping (uint256 => UserData) _userData;

    /**
     * @dev Mapping to store profile verification status by user address and profile.
     */
    mapping (address => mapping (bytes => bool)) profileVerified;

    /**
     * @dev Mapping to store the ID of a user by their profile.
     */
    mapping (bytes => uint256) _idOfProfile;

    uint256[] _userList;

    function userNameAvailable(address userAddress, string memory userName) public view returns (bool) {
        require(userName.length() < 36, "Username too long");
        require(
            !userName.includes('<') &&
            !userName.includes('"') &&
            !userName.includes('`') &&
            !userName.includes("'") &&
            !userName.includes('@'), 
            "Username includes invalid chars"
        );
        // if userName has a userId of 0, if userName is owned by userAddress already and if userName isn't empty.
        return _idOfName[userName.toLowerCase()] == 0 || _idOfName[userName] == _idOfAddress[userAddress];
    }

    function _isUser(uint256 userId) internal view returns (bool) {
        return _userData[userId].registrationDate >= Min_Timestamp;
    }

    function _getUserData(uint256 userId) internal view returns (UserData memory) {
        return _userData[userId];
    }

    function getUserData(uint256 userId) public view returns (UserData memory) {
        if (msg.sender == _userData[userId].defaultAddress || _userData[userId].indexUser) return _getUserData(userId);
        return _userData[0];
    }

    function getUserDataFromAddress(address userAddress) public view returns (UserData memory) {
        return getUserData(_idOfAddress[userAddress]);
    }

    function getUserDataFromName(string memory userName) public view returns (UserData memory) {
        return getUserData(_idOfName[userName.toLowerCase()]);
    }

    function getUserDataFromProfile(bytes memory userProfile) public view returns (UserData memory) {
        return getUserData(_idOfProfile[userProfile]);
    }

    /**
        * @dev Sets user data. 
        * @notice This function does not automatically add the user to the user list. 
        To register new users also call _addToUserList()
        * @param id The ID of the user.
        * @param newData The new user data.
    */
    function _setUserData(uint256 id, UserData memory newData) internal virtual {
        
        _userData[id].indexUser = newData.indexUser;
        _userData[id].registrationDate = newData.registrationDate;
        _userData[id].defaultAddress = newData.defaultAddress;
        _userData[id].userName = newData.userName;
        _userData[id].userBio = newData.userBio;
        _userData[id].imgUrl = newData.imgUrl;
        
        for (uint256 i; i < newData.linkedProfiles.length; i++) {

            if (i >= _userData[id].linkedProfiles.length) {
                _userData[id].linkedProfiles.push(newData.linkedProfiles[i]);
            } else {
                _userData[id].linkedProfiles[i] = newData.linkedProfiles[i];
            }

        }

        _idOfName[newData.userName.toLowerCase()] = id;
        _idOfAddress[newData.defaultAddress] = id;

        emit UserDataUpdated(newData.defaultAddress, newData.userName, newData.userBio, newData.imgUrl, newData.linkedProfiles);
    }

    /**
        * @dev Function to add a user to the user list.
        * @param id The ID of the user.
    */
    function _addToUserList(uint256 id) internal {
        _userList.push(id);
    }

    function _safeSetUserData(address userAddress, UserData memory newData) internal virtual {
        // checks for username availability
        
        // initial registration: set address, registration date and id if needed
        if (!_isUser(_idOfAddress[userAddress])) {
            require(newData.userName.length() > 0, "Registration Failed: userName was empty");
            _idOfAddress[userAddress] = uint256(keccak256(abi.encode(userAddress, block.timestamp)));
            _userData[_idOfAddress[userAddress]].registrationDate = block.timestamp;
            _userData[_idOfAddress[userAddress]].defaultAddress = userAddress;
            _userList.push(_idOfAddress[userAddress]);
        }

        // update indexUser if needed checks if different
        if (newData.indexUser != _userData[_idOfAddress[userAddress]].indexUser) {
            _userData[_idOfAddress[userAddress]].indexUser = newData.indexUser;
        }
        // update userName if needed checks if usernames are different or empty
        if (
            !newData.userName.equals(getUserDataFromAddress(userAddress).userName) && 
            newData.userName.length() > 0
        ) {
            _userData[_idOfAddress[userAddress]].userName = newData.userName;
            require(userNameAvailable(userAddress, newData.userName), "userName unavailable");
            _idOfName[newData.userName] = _idOfAddress[userAddress];
        }

        // update userBio if needed checks if bios are different or empty
        if (
            !newData.userBio.equals(_userData[_idOfAddress[userAddress]].userBio) && 
            newData.userBio.length() > 0
        ) {
            _userData[_idOfAddress[userAddress]].userBio = newData.userBio;
        }

        // update imgUrl if needed checks if imgs are different or empty
        if (
            !newData.imgUrl.equals(getUserDataFromAddress(userAddress).imgUrl) && 
            newData.imgUrl.length() > 0
        ) {
            _userData[_idOfAddress[userAddress]].imgUrl = newData.imgUrl;
        }

        // updates linkedProfiles if newData.linkedProfiles is not empty
        if (newData.linkedProfiles.length > 0) {

            // remove additional array storage slots if needed
            while (_userData[_idOfAddress[userAddress]].linkedProfiles.length > newData.linkedProfiles.length) {
                _userData[_idOfAddress[userAddress]].linkedProfiles.pop();
            }

            // map memory to storage
            for (uint256 i; i < _userData[_idOfAddress[userAddress]].linkedProfiles.length; i++) {
                _userData[_idOfAddress[userAddress]].linkedProfiles[i] = newData.linkedProfiles[i];
            }

            // add additional array storage slots if needed
            for (uint256 i; _userData[_idOfAddress[userAddress]].linkedProfiles.length < newData.linkedProfiles.length; i++) {
                _userData[_idOfAddress[userAddress]].linkedProfiles.push(newData.linkedProfiles[i + _userData[_idOfAddress[userAddress]].linkedProfiles.length]);
            }
        }

        emit UserDataUpdated(userAddress, newData.userName, newData.userBio, newData.imgUrl, newData.linkedProfiles);
    }

    /**
        * @dev Verifies a profile to add it to the mapping space.
        * @param userAddress The address of the user.
        * @param profile The profile to verify.
        * @param verified Whether the profile is verified.
    */
    function _verifyProfile(address userAddress, Profile calldata profile, bool verified) internal virtual {
        require(_isUser(_idOfAddress[userAddress]), "userAddress must be registered");
        
        profileVerified[userAddress][abi.encode(profile)] = verified;
        
        if (verified) {
            _idOfProfile[abi.encode(profile)] = _idOfAddress[userAddress];
        } else {
            _idOfProfile[abi.encode(profile)] = 0;
        }

        emit ProfileVerified(userAddress, profile, verified);
    }

    function getUserCount() public view returns(uint256) {
        return _userList.length;
    }

    function _getUserList(uint256 start, uint256 end) internal view returns (uint256[] memory) {
        uint256[] memory userList = new uint256[](end - start + 1);
        for (uint256 i; i < userList.length; i++) {
            userList[i] = _userList[start + i];
        }
        return userList;
    }

    function getUserList(uint256 pageIndex, uint256 count) public view returns (uint256[] memory) {
        uint256 start = pageIndex * count;
        uint256 end = count == 0 ? type(uint256).max : start + count;

        if (start >= _userList.length) {
            start = _userList.length - 1;
        }
        
        if (end >= _userList.length) {
            end = _userList.length - 1;
        }

        uint256[] memory userList = new uint256[](end - start + 1);
        for (uint256 i = start; i <= end; i++) {
            if (msg.sender == _userData[_userList[i + start]].defaultAddress || _userData[_userList[i + start]].indexUser) {
                userList[i] = _userList[i + start];
            } else {
                userList[i] = 1;
            }
        }

        return userList;
    }

    function getListData(uint256 pageIndex, uint256 count) public view returns (UserData[] memory) {
        uint256 start = pageIndex * count;
        uint256 end = count == 0 ? type(uint256).max : start + count;

        if (start >= _userList.length) {
            start = _userList.length - 1;
        }
        
        if (end >= _userList.length) {
            end = _userList.length - 1;
        }

        UserData[] memory userList = new UserData[](end - start + 1);
        for (uint256 i = start; i <= end; i++) {
            if (msg.sender == _userData[_userList[i + start]].defaultAddress || _userData[_userList[i + start]].indexUser) {
                userList[i] = _userData[_userList[i + start]];
            } else {
                userList[i] = _userData[1];
            }
        }

        return userList;
    }


    /**
        * @dev Event emitted when user data is updated.
    */
    event UserDataUpdated(address indexed userAddress, string userName, string userBio, string imgUrl, Profile[] linkedProfiles);

    /**
        * @dev Event emitted when a profile is verified.
    */
    event ProfileVerified(address indexed userAddress, Profile profile, bool verified);

 }