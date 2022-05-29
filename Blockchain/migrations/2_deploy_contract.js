const loteria = artifacts.require("Loteria");

module.exports = function(deployer) {
  deployer.deploy(loteria);
};
