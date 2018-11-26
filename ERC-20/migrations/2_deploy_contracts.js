var MyTonked = artifacts.require("./MyTonkenERC20.sol");

module.exports = function(deployer) {
  deployer.deploy(MyTonked);
};
