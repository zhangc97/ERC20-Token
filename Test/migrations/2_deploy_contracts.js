var ConvertLib = artifacts.require("./ConvertLib.sol");
var TokenFromScratch3 = artifacts.require("./TokenFromScratch3.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(TokenFromScratch3).then(function(){
    return deployer.deploy(
      Crowdsale,
      TokenFromScratch3.address,
      web3.eth.blockNumber,
      web3.eth.blockNumber+1000,
      web3.toWei(1, 'ether'),
      1
    ).then(function(){});
  });
};
