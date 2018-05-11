pragma solidity ^0.4.18;

import "./ERCReceivingContract.sol";

contract CrowdSale is ERCReceivingContract { //need ERC223 to notify when the contract recieves Tokens

  address private _token;
  uint private _start;
  uint private _end;
  uint private _price;
  uint private _limit;
  uint private _balance;

  function CrowdSale(address token, uint start, uint end, uint price, uint limit) {
      _token = token;
      _start = start;
      _end = end;
      _price = price;
      _limit = limit;
  }

  function availableBalance() public view returns(uint) {
      return _balance;
  }

  function buy() public payable {

  }

  function buyFor(address beneficiary) public payable {

  }

  function tokenFallback(address _from, uint _value, bytes _data) public {
      _balance += _value;
  }

}
