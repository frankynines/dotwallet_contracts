const DotSticker = artifacts.require("./DotSticker.sol");

module.exports = async function(deployer) {
  await deployer.deploy(DotSticker, "Dot Collectible", "DWC");
  const erc721 = await DotSticker.deployed();
};