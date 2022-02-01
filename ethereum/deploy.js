/**
 * Solidity v0.8.11
 */
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");

const compiledFactory = require("./build/CampaignFactory.json");

provider = new HDWalletProvider(
  "know emerge piano inner fun scene summer sustain during sense category roast",
  "https://rinkeby.infura.io/v3/239f02068b234dc5b70e4430477577c5"
);

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log("Attempting to deploy from account: ", accounts[0]);

  const result = await new web3.eth.Contract(compiledFactory.abi)
    .deploy({ data: "0x" + compiledFactory.evm.bytecode.object })
    .send({ gas: "1500000", from: accounts[0] });

  console.log("Contract deployed to: ", result.options.address);
  provider.engine.stop();
};

deploy();
