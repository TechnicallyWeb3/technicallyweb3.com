// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.20 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

// edited by ChatGPT to add natspec and events

/**
 * @title UserDatabase
 * @dev A contract for managing user data and profiles.
 */
abstract contract UserDatabase {
    using Strings for string;

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

    function _toLowercase(string memory input) internal pure returns (string memory) {
		bytes memory bytesInput = bytes(input);
		for (uint i = 0; i < bytesInput.length; i++) {
            // checks for valid ascii characters // will allow unicode after building a string library
            require (uint8(bytesInput[i]) > 41 && uint8(bytesInput[i]) < 127, "Only ASCII characters");
			// Uppercase character...
            if (uint8(bytesInput[i]) > 64 && uint8(bytesInput[i]) < 91) {
                // add 32 to make it lowercase
                bytesInput[i] = bytes1(uint8(bytesInput[i]) + 32);
            }
		}
		return string(bytesInput);
	}

    /**
        * @dev Checks if a username is available.
        * @param userAddress The address of the user.
        * @param userName The username to check.
        * @return Whether the username is available.
    */
    function userNameAvailable(address userAddress, string memory userName) public view returns (bool) {
        // should check against standard characters to prevent injection attacks.
        // if userName has a userId of 0, if userName is owned by userAddress already and if userName isn't empty.
        return _idOfName[userName] == 0 || _idOfName[userName] == _idOfAddress[userAddress];
    }

    /**
        * @dev Checks if a user exists by their ID.
        * @param userId The ID of the user.
        * @return Whether the user exists.
    */
    function isUserFromId(uint256 userId) public view returns (bool) {
        return _userData[userId].registrationDate > 0 && _userData[userId].indexUser;
    }
    
    /**
        * @dev Checks if a user exists by their address.
        * @param userAddress The address of the user.
        * @return Whether the user exists.
    */
    function isUserFromAddress(address userAddress) public view returns (bool) {
        return _userData[_idOfAddress[userAddress]].registrationDate > 0 && _userData[_idOfAddress[userAddress]].indexUser;
    }

    /**
        * @dev Checks if a user exists by their username.
        * @param userName The username of the user.
        * @return Whether the user exists.
    */
    function isUserFromName(string memory userName) public view returns (bool) {
        return _userData[_idOfName[userName]].registrationDate > 0;
    }

    /**
        * @dev Checks if a user exists by their verified profile.
        * @param userProfile The profile of the user.
        * @return Whether the user exists.
    */
    function isUserFromProfile(bytes memory userProfile) public view returns (bool) {
        return _userData[_idOfProfile[userProfile]].registrationDate > 0 && _userData[_idOfProfile[userProfile]].indexUser;
    }

    /**
        * @dev Retrieves user data by their ID.
        * @param userId The ID of the user.
        * @return The user data.
    */
    function getUserDataFromId(uint256 userId) public view returns (UserData memory) {
        if (_userData[userId].indexUser) return _userData[userId];
        return UserData(
            true,
            1,
            address(1),
            "Private User",
            "This user has chosen not to index their account",
            "/assets/images/private.png",
            new Profile[](0)
        );
    }

    /**
        * @dev Retrieves user data by their address.
        * @param userAddress The address of the user.
        * @return The user data.
    */
    function getUserDataFromAddress(address userAddress) public view returns (UserData memory) {
        return _userData[_idOfAddress[userAddress]];
    }

    /**
        * @dev Retrieves user data by their username.
        * @param userName The username of the user.
        * @return The user data.
    */
    function getUserDataFromName(string memory userName) public view returns (UserData memory) {
        return  _userData[_idOfName[userName]];
    }

    /**
        * @dev Retrieves user data by their profile.
        * @param userProfile The profile of the user.
        * @return The user data.
    */
    function getUserDataFromProfile(bytes memory userProfile) public view returns (UserData memory) {
        return  _userData[_idOfProfile[userProfile]];
    }

    /**
        * @dev Retrieves the ID of a user by their address.
        * @param userAddress The address of the user.
        * @return The ID of the user.
    */
    function _getId(address userAddress) internal view returns (uint256) {
        return _idOfAddress[userAddress];
    }

    /**
        * @dev Retrieves the ID of a user by their username.
        * @param userName The username of the user.
        * @return The ID of the user.
    */
    function _getId(string memory userName) internal view returns (uint256) {
        return _idOfName[userName];
    }

    /**
        * @dev Retrieves the ID of a user by their profile.
        * @param userProfile The profile of the user.
        * @return The ID of the user.
    */
    function _getId(bytes memory userProfile) internal view returns (uint256) {
        return _idOfProfile[userProfile];
    }

    /**
        * @dev Sets user data.
        * @param id The ID of the user.
        * @param newData The new user data.
    */
    function _setUserData(uint256 id, UserData memory newData) internal virtual {
        _idOfName[_toLowercase(newData.userName)] = id;
        _idOfAddress[newData.defaultAddress] = id;
        
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

        emit UserDataUpdated(newData.defaultAddress, newData.userName, newData.userBio, newData.imgUrl, newData.linkedProfiles);
    }

    /**
        * @dev Function to add a user to the user list.
        * @param id The ID of the user.
    */
    function _addToUserList(uint256 id) internal {
        _userList.push(id);
    }

    /**
        * @dev Safely sets user data.
        * @param userAddress The address of the user.
        * @param newData The new user data.
    */
    function _safeSetUserData(address userAddress, UserData memory newData) internal virtual {
        // checks for username availability
        require(userNameAvailable(userAddress, newData.userName), "userName unavailable");
        
        // initial registration: set address, registration date and id if needed
        if (!isUserFromAddress(userAddress)) {
            require(!newData.userName.equal(''), "Username cannot be blank for registration");
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
            !newData.userName.equal(_userData[_idOfAddress[userAddress]].userName) && 
            !newData.userName.equal('')
        ) {
            _userData[_idOfAddress[userAddress]].userName = newData.userName;
            _idOfName[_toLowercase(newData.userName)] = _idOfAddress[userAddress];
        }

        // update userBio if needed checks if bios are different or empty
        if (
            !newData.userBio.equal(_userData[_idOfAddress[userAddress]].userBio) && 
            !newData.userBio.equal('')
        ) {
            _userData[_idOfAddress[userAddress]].userBio = newData.userBio;
        }

        // update imgUrl if needed checks if imgs are different or empty
        if (
            !newData.imgUrl.equal(_userData[_idOfAddress[userAddress]].imgUrl) && 
            !newData.imgUrl.equal('')
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
        require(isUserFromAddress(userAddress), "userAddress must be user");
        
        profileVerified[userAddress][abi.encode(profile)] = verified;
        
        if (verified) {
            _idOfProfile[abi.encode(profile)] = _idOfAddress[userAddress];
        } else {
            _idOfProfile[abi.encode(profile)] = 0;
        }

        emit ProfileVerified(userAddress, profile, verified);
    }

    function _getUserList(uint256 start, uint256 end) internal view returns (uint256[] memory) {
        uint256[] memory userList = new uint256[](end - start);
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
        uint256 index;
        for (uint256 i = start; i <= end; i++) {
            if (_userData[_userList[i]].indexUser) {
                userList[index] = _userList[i];
                index++;
            }
        }

        return userList;
    }

    function getUserCount() public view returns(uint256) {
        return _userList.length;
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