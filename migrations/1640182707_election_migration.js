const Election = artifacts.require('Election.sol');
 
module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(Election);
};
