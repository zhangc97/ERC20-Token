pragma solidity ^0.4.18;

import "./ERCReceivingContract.sol";
import "./Token.sol";
import "./SafeMath.sol";

interface ERC20 {
		function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256);
    function allowance(address tokenOwner, address spender) public view returns (uint256);
    function transfer(address _to, uint256 tokens) public returns (bool);
    function approve(address _spender, uint256 tokens) public returns (bool);
    function transferFrom(address _from, address _to, uint256 tokens) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

library Addresses {
  function isContract(address _base) internal constant returns (bool) {
      uint codeSize;
      assembly {
          codeSize := extcodesize(_base)
      }
      return codeSize > 0;
  }
}

contract TokenFromScratch3 is Token("TokenFromScratch3", "TFS", 0, 50000000000000000000), ERC20 {

	using Addresses for address;
	using SafeMath for uint256;

	mapping(address=>uint256) public _balanceOf;
  mapping(address => mapping(address=>uint256)) public _allowances;

	function TokenFromScratch3() public {
	    _balanceOf[msg.sender] = _totalsupply;

	}

	function totalSupply() public view returns (uint256) {
		return _totalsupply;
	}

	function balanceOf(address _addr) public view returns (uint256) {
		return _balanceOf[_addr];
	}

	function transfer(address _to, uint256 tokens, bytes _data) public returns (bool) {
		if (tokens > 0 && tokens <= _balanceOf[msg.sender]) {
			if(_to.isContract()){
				ERCReceivingContract _contract = ERCReceivingContract(_to);
				_contract.tokenFallback(msg.sender, tokens, _data);
			}
			_balanceOf[msg.sender] = _balanceOf[msg.sender].sub(tokens);
			_balanceOf[_to] = _balanceOf[_to].add(tokens);
			emit Transfer(msg.sender, _to, tokens, _data);
			return true;
		}
		return false;
	}

	function transfer(address _to, uint256 tokens) public returns (bool){
		return transfer(_to, tokens, "");
	}

	function approve(address _spender, uint tokens) public returns (bool){
		if (tokens <= _balanceOf[msg.sender]) {
			_allowances[msg.sender][_spender] = tokens;
			emit Approval(msg.sender,_spender,tokens);
			return true;
		}
		return false;
	}

	function transferFrom(address _from, address _to, uint tokens, bytes _data) public returns (bool) {
		if (_balanceOf[_from] >= tokens &&
			_allowances[_from][msg.sender] > 0 &&
			_allowances[_from][msg.sender] >= tokens &&
			tokens > 0){
				_allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(tokens);
				if (_to.isContract()){
					ERCReceivingContract _contract = ERCReceivingContract(_to);
					_contract.tokenFallback(msg.sender, tokens, _data);
				}
			_balanceOf[_from] = _balanceOf[_from].sub(tokens);
			_balanceOf[_to] += _balanceOf[_to].add(tokens);
			emit Transfer(_from, _to, tokens, _data);
			return true;
		}
		return false;
	}
	function transferFrom(address _from, address _to, uint256 tokens) public returns (bool){
		return transferFrom(_from, _to, tokens, "");
	}

	function allowance(address tokenOwner, address spender) public view returns (uint256){
		if (_allowances[tokenOwner][spender] < _balanceOf[tokenOwner]) {
			return _allowances[tokenOwner][spender];
		}
		return _balanceOf[tokenOwner];
	}
	function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, _allowances[msg.sender][_spender]);
    return true;
  }
	function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = _allowances[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      _allowances[msg.sender][_spender] = 0;
    } else {
      _allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, _allowances[msg.sender][_spender]);
    return true;
  }

}
