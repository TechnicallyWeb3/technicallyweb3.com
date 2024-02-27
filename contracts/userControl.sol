// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.20 <0.9.0;

import "./users.sol";

contract UserControl is UserDatabase {

    address public owner;
    uint256[] _userList;

    mapping (string platformName => uint256) _platformId;
    mapping (uint256 platformId => string) _platformName;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    mapping (address admin => bool) _isAdmin;

    modifier onlyAdmin {
        require(msg.sender == owner || _isAdmin[msg.sender], "onlyAdmin");
        _;
    }

    function toggleAdmin(address admin) external onlyOwner {
        _isAdmin[admin] = !_isAdmin[admin];
    }

    constructor(
        uint256[] memory platformIds, 
        string[] memory platformNames
    ) {
        owner = msg.sender;
        require(platformIds.length == platformNames.length, "Uneven array length");

        for (uint256 i; i < platformNames.length; i++) {
            setPlatform(platformIds[i], platformNames[i]);
        }
    }

    function setPlatform(uint256 id, string memory name) public onlyAdmin {
        _platformId[name] = id;
        _platformName[id] = name;
    }

    function getPlatformId(string memory name) public view returns (uint256) {
        return _platformId[name];
    }

    function getPlatformName(uint256 id) public view returns (string memory) {
        return _platformName[id];
    }


    function overrideUserData(uint256 id, UserData calldata newData) external onlyAdmin {
        _setUserData(id, newData);
    }

    function safeOverrideUserData(address userAddress, UserData memory newData) external onlyAdmin {
        _safeSetUserData(userAddress, newData);
    }

    ///@notice allows advanced users to set their own data using the full object.
    function setUserData(UserData calldata newData) public {
        _safeSetUserData(msg.sender, newData);
    }

    function verifyProfile(address userAddress, Profile calldata profile, bool verified) external onlyAdmin {
        _verifyProfile(userAddress, profile, verified);
    }

    function register(string memory username, string memory bio, string memory imgUrl) external {
        
        UserData memory newData = UserData(
            0,
            msg.sender,
            username,
            bio,
            imgUrl,
            new Profile[](0)
        );

        _safeSetUserData(msg.sender, newData);
        _userList.push(_getId(msg.sender));
    }

    function addToUserList(uint256 id) external onlyAdmin() {
        _userList.push(id);
    }

    function linkProfile(string memory platform, string memory id) external {
        require(isUser(msg.sender), "Must be a user");
        uint256 platformId = getPlatformId(platform);
        Profile[] memory userProfiles = getUserData(msg.sender).linkedProfiles;
        Profile[] memory newProfiles = new Profile[](userProfiles.length + 1);

        for (uint256 i; i < userProfiles.length; i++) {
            newProfiles[i] = userProfiles[i];   
        }
        newProfiles[newProfiles.length - 1] = Profile(platformId, id, address(0));

        UserData memory newData = UserData(
            0,
            msg.sender,
            "",
            "",
            "",
            newProfiles
        );

        _safeSetUserData(msg.sender, newData);

    }

    function updateUser(UserData calldata newData) external {
        require(msg.sender == newData.defaultAddress, "Can only update own userData");
        _safeSetUserData(msg.sender, newData);
    }

}