require('babel-register');
require('babel-polyfill');

const HDWalletProvider = require("truffle-hdwallet-provider");
const MNEMONIC = ""
const INFURA_KEY = ""

if (!MNEMONIC || !INFURA_KEY) {
  console.error("Please set a mnemonic and infura key.")
  return
}

module.exports = {
  networks: {
    development: {
        host: '127.0.0.1',
        port: 8545,
        network_id: '*', // Match any network id
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(MNEMONIC, "https://ropsten.infura.io/" + INFURA_KEY)
      },
      network_id: 3
    }  
},
};
