pragma solidity ^0.4.18;

import "./ERCReceivingContract.sol";

interface ERC20 {
		function totalSupply() external constant returns (uint);
    function balanceOf(address tokenOwner) external constant returns (uint balance);
    function allowance(address tokenOwner, address spender) external constant returns (uint remaining);
    function transfer(address _to, uint tokens) external returns (bool success);
    function approve(address _spender, uint tokens) external returns (bool success);
    function transferFrom(address _from, address _to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
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

contract TokenFromScratch3 is ERC20 {
	string public symbol = "TFS";
	string public name = "Token From Scratch2";
	uint8 internal decimals = 0;
	uint256 _totalSupply = 10000;
	mapping (address => uint256) public _balanceOf;
	mapping (address => mapping (address => uint256)) public _allowances;
	using Addresses for address;

	function TokenFromScratch3() public {
	    _balanceOf[msg.sender] = _totalSupply;

	}

	function totalSupply() external constant returns (uint) {
		return _totalSupply;
	}

	function balanceOf(address _addr) external constant returns (uint) {
		return _balanceOf[_addr];
	}



	function transfer(address _to, uint tokens, bytes _data) internal returns (bool) {
		if (tokens > 0 && tokens <= _balanceOf[msg.sender]) {
			if(_to.isContract()){
				ERCReceivingContract _contract = ERCReceivingContract(_to);
				_contract.tokenFallback(msg.sender, tokens, _data);
			}
			_balanceOf[msg.sender] -= tokens;
			_balanceOf[_to] += tokens;
			emit Transfer(msg.sender, _to, tokens, _data);
			return true;
		}
		return false;
	}

	function transfer(address _to, uint tokens) external returns (bool){
		return transfer(_to, tokens, "");
	}

	function approve(address _spender, uint tokens) external returns (bool){
		if (tokens <= _balanceOf[msg.sender]) {
			_allowances[msg.sender][_spender] = tokens;
			emit Approval(msg.sender,_spender,tokens);
			return true;
		}
		return false;
	}

	function transferFrom(address _from, address _to, uint tokens, bytes _data) internal returns (bool) {
		if (_balanceOf[_from] >= tokens &&
			_allowances[_from][msg.sender] > 0 &&
			_allowances[_from][msg.sender] >= tokens &&
			tokens > 0){
				_allowances[_from][msg.sender] -= tokens;
				if (_to.isContract()){
					ERCReceivingContract _contract = ERCReceivingContract(_to);
					_contract.tokenFallback(msg.sender, tokens, _data);
				}
			_balanceOf[_from] -= tokens;
			_balanceOf[_to] += tokens;
			emit Transfer(_from, _to, tokens, _data);
			return true;
		}
		return false;
	}
	function transferFrom(address _from, address _to, uint tokens) external returns (bool){
		return transferFrom(_from, _to, tokens, "");
	}

	function allowance(address tokenOwner, address spender) external constant returns (uint){
		if (_allowances[tokenOwner][spender] < _balanceOf[tokenOwner]) {
			return _allowances[tokenOwner][spender];
		}
		return _balanceOf[tokenOwner];
	}

}
