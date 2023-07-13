require("dotenv").config();

require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-etherscan")
require("hardhat-deploy")
require("solidity-coverage")
require("hardhat-gas-reporter")




/** @type import('hardhat/config').HardhatUserConfig */

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
const COINMARKETCAP = process.env.COINMARKETCAP

module.exports = {

defaultNetwork:"hardhat",

networks:{
  hardhat:{
    chainId:31337,
    blockconfirmations:1
  },
  sepolia:{
    url:SEPOLIA_RPC_URL,
    accounts:[PRIVATE_KEY],
    chainId:11155111,
    blockconfirmations:6
  }
},
  solidity: "0.8.7",
  gasReporter: {
    enabled:false,
    outputFile:"gasReporter.txt",
    noColors:true,
    currency:"USD",
    coinmarketcap:COINMARKETCAP,
    token:"ETH"
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  namedAccounts: {
    deployer: {
        default: 0,
    },
    player: {
        default: 1,
    },
},
};
