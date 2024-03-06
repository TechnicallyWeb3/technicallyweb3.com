// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.20 <0.9.0;

contract EncryptedMessaging {

    struct Message {
        address sender;
        uint256 timestamp;
        string messageFrom;
        string messageTo;
        uint256 replyIndex;
    }

    function conversationId(address party1, address party2) public pure returns (uint256) {
        if (party1 > party2) {
            return uint256(keccak256(abi.encodePacked(party1, party2)));
        }
        return uint256(keccak256(abi.encodePacked(party2, party1)));

    } 

    mapping (uint256 conversationId => mapping (uint256 messageIndex => Message)) message;
    mapping (address user => mapping (uint256 conversationId => uint256[] messageIndexes)) ownMessages;
    mapping (address user => uint256[] conversationIds) userConversations;

    function getConversations(uint256 maxConversations, uint256 page) public view returns (uint256[] memory) {

        if (maxConversations == 0 || maxConversations >= userConversations[msg.sender].length) {
            return userConversations[msg.sender];
        }

        uint256[] memory conversationList = new uint256[](maxConversations);
        for (uint256 i; i < conversationList.length; i++) {
            conversationList[i] = userConversations[msg.sender][userConversations[msg.sender].length - 1 - i];
        }

        return conversationList;
    }

    function getMessages(uint256 _conversationId, uint256 maxMessages) public view returns (Message[] memory) {
        uint256 outputSize = maxMessages != 0 ? maxMessages < ownMessages[msg.sender][_conversationId].length ? maxMessages : ownMessages[msg.sender][_conversationId].length : ownMessages[msg.sender][_conversationId].length;
        Message[] memory messageList = new Message[](outputSize);
        for (uint256 i; i < messageList.length; i++) {
            messageList[i] = message[_conversationId][ownMessages[msg.sender][_conversationId][i]];
        }
        return messageList;
    }
}