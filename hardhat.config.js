require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config();
require("hardhat-gas-reporter");
require('hardhat-contract-sizer');
require('hardhat-abi-exporter');

module.exports = {
  solidity: "0.8.11",
  optimizer: {
    enabled: true,
    runs: 200,
  },
 
  networks: {
    hardhat: {
      forking: {
        url: process.env.MAINNET_ALCHEMY_URL ? process.env.MAINNET_ALCHEMY_URL : '',
        blockNumber: 14032174 	
      },
      allowUnlimitedContractSize: true,
      loggingEnabled: true,
      initialBaseFeePerGas: 0,
      blockGasLimit: 0x1fffffffffffff,
    },
    localhost: {
      url: "http://127.0.0.1:8545", // same address and port for both Buidler and Ganache node
    },
    kovan: {
      url: process.env.KOVAN_INFURA_URL ? process.env.KOVAN_INFURA_URL : '',
      accounts: process.env.KOVAN_DEV_PRIVATE_KEY ? [`0x${process.env.KOVAN_DEV_PRIVATE_KEY}`] : [],
    },
    goerli: {
      url: process.env.GOERLI_INFURA_URL ? process.env.GOERLI_INFURA_URL : '',
      accounts: process.env.GOERLI_DEV_PRIVATE_KEY ? [`0x${process.env.GOERLI_DEV_PRIVATE_KEY}`] : [],
    },
    rinkeby: {
      url: process.env.RINKEBY_INFURA_URL ? process.env.RINKEBY_INFURA_URL : '',
      accounts: process.env.RINKEBY_DEV_PRIVATE_KEY ? [`0x${process.env.RINKEBY_DEV_PRIVATE_KEY}`] : [],
    },
    arbitrum: {
      url: process.env.ARBITRUM_ALCHEMY_URL ? process.env.ARBITRUM_ALCHEMY_URL : '',
      accounts: process.env.ARBITRUM_DEV_PRIVATE_KEY ? [`0x${process.env.ARBITRUM_DEV_PRIVATE_KEY}`] : [],
    }
  }
};
