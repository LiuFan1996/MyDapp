var OnePay = artifacts.require("./OnePay.sol");

module.exports = function(deployer) {
  deployer.deploy(OnePay);
};