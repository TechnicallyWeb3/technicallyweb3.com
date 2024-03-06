// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.20 <0.9.0;

import "./users.sol";

contract DACControl is UserDatabase {

    struct Roles {
        bool leader;
        bool contributor;
        bool vip;
        bool community;
    }

    struct VoteWeights {
        uint16 leader;
        uint16 contributor;
        uint16 vip;
        uint16 community;
    }

    mapping (address => Roles) roles;

}