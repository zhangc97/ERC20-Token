pragma solidity ^0.4.18;

import "./ERCReceivingContract.sol";
import "./Token.sol";
import "./TokenFromScratch3.sol";
import "./ERCReceivingContract.sol";
import "./SafeMath.sol";

contract CrowdSale is ERCReceivingContract { //need ERC223 to notify when the contract recieves Tokens

  using SafeMath for uint256;

  Token private _token; //place the token comes from
  uint private _deadline; //deadline
  uint private _price; //price per token
  uint private _limit; //cap
  uint private _available; //amount left
  uint private _raised; //raised amount
  address private _wallet; //wallet im sending my coins to

  event Buy(address beneficiary , uint amount);

  mapping(address => uint) private _limits;

  modifier valid(address recipient, uint value) {
    assert(value > 0);
    uint amount = value/_price;
    assert(_limit >= amount);
    assert(_limits[recipient].add(amount) <= _limit );
    _;
  }

  modifier available() {
    require(_available >0);
    require(now <= _deadline);
    _;
  }

  modifier isOver() {
    require(_deadline > now);
    _;
  }

  modifier isToken() {
    require(msg.sender == address(_token));
    _;
  }



  function CrowdSale(address token, uint _deadline, uint price, uint limit, address wallet) public {
      _token = Token(token);
      _start = start;
      _end = end;
      _price = price;
      _limit = limit;
  }

  function() public isOver() payable {
    buy(msg.sender);

  }


  function availableBalance() external view returns(uint) {
      return _available;
  }

  function buy() public payable {
    buyFor(msg.sender);

  }

  function buyFor(address beneficiary) public available() valid(beneficiary, msg.value) payable {
    require(beneficiary != address(0));
    require(msg.value != 0);
    uint amount = msg.value/_price;
    _token.transfer(beneficiary,amount);
    _limits[beneficiary] = _limits[beneficiary].add(amount);
    _available = _available.sub(amount);
    _raised = _raised.add(amount);
    emit Buy(beneficiary, amount);
  }

  function tokenFallback(address _from, uint _value, bytes _data) external isToken() {
      _available += _value;
  }

}
