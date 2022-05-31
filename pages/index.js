import React from "react";
import factory from "../ethereum/factory";

class CampaignIndex extends React.Component {
  constructor() {
    super();
  }

  async componentDidMount() {
    const campaigns = await factory.methods.getDeployedCampaigns().call(); // retrieves the addresses of all the deployed campaigns
    console.log(campaigns);
  }

  render() {
    return <div>Campaigns Index!</div>;
  }
}

export default CampaignIndex;
