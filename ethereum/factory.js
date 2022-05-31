import web3 from "./web3";
import CampaignFactory from "./build/CampaignFactory.json"; // import the compiled contract

const contractInstance = new web3.eth.Contract(
  JSON.parse(CampaignFactory.abi),
  0x33a960cf8de68b09dc8fd98edbfde8769aad1682
);

export default contractInstance;
