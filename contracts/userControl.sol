// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.20 <0.9.0;

import "./users.sol";

contract UserControl is UserDatabase {

    address public owner;

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

    constructor() {
        owner = msg.sender;
    }


    function overrideUserData(uint256 id, address userAddress, UserData calldata newData) external onlyAdmin {
        _setUserData(id, userAddress, newData);
    }

    function setUserData(UserData calldata newData) external {
        _safeSetUserData(msg.sender, newData);
    }

    function verifyProfile(address userAddress, Profile calldata profile, bool verified) external onlyAdmin {
        _verifyProfile(userAddress, profile, verified);
    }
}