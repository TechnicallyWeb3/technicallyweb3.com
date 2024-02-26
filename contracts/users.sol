// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.20 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract UserDatabase {
    using Strings for string;

    struct UserData {
        uint256 registrationDate;
        address defaultAddress;
        string userName;
        string userBio;
        string imgUrl;
        Profile[] linkedProfiles;
    }

    /*
    
    // 0 web3 address
    // 1 website
    // 2 business
    // 3 linkedin
    // 4 github
    // 5 twitter
    // 6 youtube
    // 7 instagram
    // 8 tiktok
    // 9 telegram
    // 10 discord
    // 11 reddit
    // 12 snapchat
    // 13 mastodon
    // 14 twitch
    // 15 quora
    // 16 pintrest
    // 17 slack
    // 18 tumblr
    // 19 stackoverflow
    // 20 soundcloud
    // 21 spotify
    // 22 upwork

    */

    struct Profile {
        uint256 platform;
        string id;
        address _address;
    }

    mapping (string userName => uint256) _idOfName;
    mapping (address userAddress => uint256) _idOfAddress;
    mapping (uint256 userId => UserData) _userData;

    mapping (address userAddress => mapping (bytes profile => bool)) profileVerified;
    mapping (bytes profile => uint256 userId) _idOfProfile;

    function userNameAvailable(address userAddress, string memory userName) public view returns (bool) {
        return _idOfName[userName] == 0 || _idOfName[userName] == _idOfAddress[userAddress];
    }

    function isUser(uint256 userId) public view returns (bool) {
        return _userData[userId].registrationDate > 0;
    }
    
    function isUser(address userAddress) public view returns (bool) {
        return _userData[_idOfAddress[userAddress]].registrationDate > 0;
    }

    function isUser(string memory userName) public view returns (bool) {
        return _userData[_idOfName[userName]].registrationDate > 0;
    }

    function isUser(bytes memory userProfile) public view returns (bool) {
        return _userData[_idOfProfile[userProfile]].registrationDate > 0;
    }

    function getUserData(uint256 userId) public view returns (UserData memory) {
        return _userData[userId];
    }

    function getUserData(address userAddress) public view returns (UserData memory) {
        return _userData[_idOfAddress[userAddress]];
    }

    function getUserData(string memory userName) public view returns (UserData memory) {
        return  _userData[_idOfName[userName]];
    }

    function getUserData(bytes memory userProfile) public view returns (UserData memory) {
        return  _userData[_idOfProfile[userProfile]];
    }

    function _setUserData(uint256 id, address userAddress, UserData calldata newData) internal {
        _idOfName[newData.userName] = id;
        _idOfAddress[userAddress] = id;
        _userData[id] = newData;
        _userData[id].defaultAddress = userAddress;
    }

    function _safeSetUserData(address userAddress, UserData calldata newData) internal {
        // checks for username availability
        require(userNameAvailable(userAddress, newData.userName), "userName unavailable");
        
        // initial registration: set address, registration date and id if needed
        if (!isUser(userAddress)) {
            _idOfAddress[userAddress] = uint256(keccak256(abi.encode(userAddress, block.timestamp)));

            _userData[_idOfAddress[userAddress]].registrationDate = block.timestamp;
            _userData[_idOfAddress[userAddress]].defaultAddress = userAddress;
        }

        // update userName if needed checks if usernames are different or empty
        if (
            !newData.userName.equal(_userData[_idOfAddress[userAddress]].userName) && 
            !newData.userName.equal('')
        ) {
            _userData[_idOfAddress[userAddress]].userName = newData.userName;
            _idOfName[newData.userName] = _idOfAddress[userAddress];
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

        // updates linkedProfiles if newData is not empty
        if (newData.linkedProfiles.length > 0) {

            // remove additional array storage slots if needed
            while (_userData[_idOfAddress[userAddress]].linkedProfiles.length > newData.linkedProfiles.length) {
                _userData[_idOfAddress[userAddress]].linkedProfiles.pop();
            }

            // map calldata to storage
            for (uint256 i; i < _userData[_idOfAddress[userAddress]].linkedProfiles.length; i++) {
                _userData[_idOfAddress[userAddress]].linkedProfiles[i] = newData.linkedProfiles[i];
            }

            // add additional array storage slots if needed
            for (uint256 i; _userData[_idOfAddress[userAddress]].linkedProfiles.length < newData.linkedProfiles.length; i++) {
                _userData[_idOfAddress[userAddress]].linkedProfiles.push(newData.linkedProfiles[i + _userData[_idOfAddress[userAddress]].linkedProfiles.length]);
            }
        }

    }

    function _verifyProfile(address userAddress, Profile calldata profile, bool verified) internal {
        require(isUser(userAddress), "userAddress must be user");
        
        profileVerified[userAddress][abi.encode(profile)] = verified;
        if (verified) {
            _idOfProfile[abi.encode(profile)] = _idOfAddress[userAddress];
        } else {
            _idOfProfile[abi.encode(profile)] = 0;
        }
    }

}