pragma solidity ^0.4.18;

import "./Token.sol";
import "./TokenFromScratch3.sol";
import "./ERCReceivingContract.sol";
import "./SafeMath.sol";

contract Crowdsale { //need ERC223 to notify when the contract recieves Tokens

  using SafeMath for uint256;

  TokenFromScratch3 public _token; //place the token comes from
  uint256 private _price; //price per token
  uint256 private _limit; //cap
  uint256 private _available; //amount left
  uint256 private _raised; //raised amount
  address public _wallet; //wallet im sending my coins to
  uint256 private _start;
  uint256 private _end;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  mapping(address => uint) private _contributions;

/*-------------------Modifiers-------------------------*/
  modifier isToken {
    require(msg.sender == address(_token));
    _;
  }
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    if (!isOwner()) {
      require(block.timestamp >= _start);
      _;
    } else {
      _;
    }
  }

  function Crowdsale(uint256 openingtime, uint256 closingtime, uint256 price, address wallet, TokenFromScratch3 token) public {
      require(price > 0);
      require(wallet != address(0));
      require(token != address(0));
      _token = token; //setting address tokens are coming from
      //_deadline = deadline; //setting deadline time
      _price = price; //setting price in wei per token
      //_limit = limit; //setting cap
      _wallet = wallet; //setting address the money will be sent to after time is done
      _start = openingtime;
      _end = closingtime;
  }

  function() external payable {
    buyFor(msg.sender);
  }
  function hasClosed() public view returns (bool) {
     //solium-disable-next-line security/no-block-members
   return block.timestamp > _end;
  }

  function hasOpened() public view returns (bool) {
    return block.timestamp >= _start;
  }

  function isOwner() public view returns (bool) {
    return msg.sender == address(_token);
  }


  function availableBalance() external view returns(uint) {
      return _available;
  }


  function buyFor(address beneficiary) public onlyWhileOpen() payable {
    //require(beneficiary != address(0));
    //require(msg.value != 0);
    if (!hasClosed()){
      uint256 weiamount = msg.value;
      uint256 amount = weiamount.div(_price);
      _raised = _raised.add(amount);
      _token.transfer(beneficiary,amount);
    //_contributions[beneficiary] = _contributions[beneficiary].add(amount);
    //_available = _available.sub(amount);
      _forwardFunds();
      emit TokenPurchase(msg.sender,beneficiary,weiamount,amount);
    } else {
      revert();
    }
  }

  function _forwardFunds() internal {
    _wallet.transfer(msg.value);
  }

}
