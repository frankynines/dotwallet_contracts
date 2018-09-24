const DotCollectible = artifacts.require("./DotCollectible.sol");

module.exports = async function(deployer) {
  await deployer.deploy(DotCollectible, "Collectible", "DCT");
  const erc721 = await DotCollectible.deployed();
};