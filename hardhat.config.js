require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config(); // Load environment variables from .env file if you're using dotenv

const MNEMONIC = process.env.MNEMONIC;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.22",
  networks: {
    hardhat: {
      accounts: {
        mnemonic: MNEMONIC,
        initialIndex: 0,
        path: "m/44'/60'/0'/0",
        count: 10,
        accountsBalance: '1000000000000000000000', // 1000 ETH in wei
      },
    },
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: {
        mnemonic: MNEMONIC,
        initialIndex: 0,
        path: "m/44'/60'/0'/0",
        count: 10,
        accountsBalance: '1000000000000000000000', // 1000 ETH in wei
      },
    
    },
    sepolia: {
      url: "https://ethereum-sepolia-rpc.publicnode.com",
      accounts: {
        mnemonic: MNEMONIC,
        initialIndex: 0,
        path: "m/44'/60'/0'/0",
        count: 10
      },
      gasPrice: 30000000000,
    },
  },
};
