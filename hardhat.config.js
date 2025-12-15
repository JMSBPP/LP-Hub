require("@nomicfoundation/hardhat-foundry");
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  paths: {
    sources: "./src",      // Match your Foundry source directory
    tests: "./test",       // Match your Foundry test directory
    cache: "./cache",      // Path to the cache directory
    artifacts: "./out"     // Match your Foundry output directory
  },
  networks: {
    hardhat: {
      // This sets up Hardhat Network to behave similarly to Foundry's anvil
      allowUnlimitedContractSize: true,
    }
  },
  mocha: {
    timeout: 300000  // 5 minutes timeout for tests that might run long
  }
};