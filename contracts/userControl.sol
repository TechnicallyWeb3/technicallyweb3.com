// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.20 <0.9.0;

import "./users.sol";

/**
    * @title User Database Control
    * @dev A contract for allowing user control over their account.
*/
contract UserControl is UserDatabase {

    address public owner;
    uint256[] _userList;

    mapping (string => uint256) _platformId;
    mapping (uint256 => string) _platformName;

    /**
        * @dev Modifier to only allow the owner to execute a function.
    */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
        * @dev Modifier to only allow admins to execute a function.
    */
    modifier onlyAdmin {
        require(msg.sender == owner || _isAdmin[msg.sender], "onlyAdmin");
        _;
    }

    /**
        * @dev Mapping to store admin status.
    */
    mapping (address => bool) _isAdmin;

    /**
        * @dev Function to toggle admin status.
        * @param admin The address of the admin to toggle.
    */
    function toggleAdmin(address admin) external onlyOwner {
        _isAdmin[admin] = !_isAdmin[admin];
    }

    /**
        * @dev Constructor to initialize the contract.
        * @param platformIds Array of platform IDs.
        * @param platformNames Array of platform names.
    */
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

    /**
        * @dev Function to set a platform.
        * @param id The ID of the platform.
        * @param name The name of the platform.
    */
    function setPlatform(uint256 id, string memory name) public onlyAdmin {
        _platformId[name] = id;
        _platformName[id] = name;
    }

    /**
        * @dev Function to get the ID of a platform.
        * @param name The name of the platform.
        * @return The ID of the platform.
    */
    function getPlatformId(string memory name) public view returns (uint256) {
        return _platformId[name];
    }

    /**
        * @dev Function to get the name of a platform.
        * @param id The ID of the platform.
        * @return The name of the platform.
    */
    function getPlatformName(uint256 id) public view returns (string memory) {
        return _platformName[id];
    }

    /**
        * @dev Function to override user data.
        * @param id The ID of the user.
        * @param newData The new user data.
    */
    function overrideUserData(uint256 id, UserData calldata newData) external onlyAdmin {
        _setUserData(id, newData);
    }

    /**
        * @dev Function to safely override user data.
        * @param userAddress The address of the user.
        * @param newData The new user data.
    */
    function safeOverrideUserData(address userAddress, UserData memory newData) external onlyAdmin {
        _safeSetUserData(userAddress, newData);
    }

    /**
        * @dev Function to set user data.
        * @param newData The new user data.
    */
    function setUserData(UserData calldata newData) public {
        _safeSetUserData(msg.sender, newData);
    }

    /**
        * @dev Function to verify a profile.
        * @param userAddress The address of the user.
        * @param profile The profile to verify.
        * @param verified Whether the profile is verified.
    */
    function verifyProfile(address userAddress, Profile calldata profile, bool verified) external onlyAdmin {
        _verifyProfile(userAddress, profile, verified);
    }

    /**
        * @dev Function to register a new user.
        * @param username The username of the user.
        * @param bio The bio of the user.
        * @param imgUrl The image URL of the user.
    */
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

    /**
        * @dev Function to add a user to the user list.
        * @param id The ID of the user.
    */
    function addToUserList(uint256 id) external onlyAdmin() {
        _userList.push(id);
    }

    /**
        * @dev Function to link a profile to a user.
        * @param platform The platform of the profile.
        * @param id The ID of the profile.
    */
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

    /**
        * @dev Function to update user data.
        * @param newData The updated UserData object.
    */
    function updateUser(UserData calldata newData) external {
        require(msg.sender == newData.defaultAddress, "Can only update own userData");
        _safeSetUserData(msg.sender, newData);
    }

}