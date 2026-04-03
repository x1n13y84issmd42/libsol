// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { Owned } from "../access/Owned.sol";

/**
 * @notice ERC20 Token standard implementation.
 * See https://eips.ethereum.org/EIPS/eip-20
 */
contract ERC20Token is Owned {
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	string public name;
	string public symbol;
	uint256 public totalSupply;
	uint8 public decimals;
	
	event Approval(address indexed owner, address indexed spender, uint256 amount);
	event Transfer(address indexed from, address indexed to, uint256 amount);

	error InsufficientFunds(address spender, uint256 funds, uint256 amount);
	error InsufficientAllowance(address owner, address spender, uint256 allowance, uint256 amount);
	error InvalidSender(address a);
	error InvalidReceiver(address a);

	constructor(string memory _name, string memory _symbol, uint8 _decimals) {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
	}

	function mint(address to, uint256 amount) external only_owner {
		if (to == address(0)) {
			revert InvalidReceiver(address(0));
		}

		balanceOf[to] += amount;
		totalSupply += amount;
	}

	function transfer(address to, uint256 amount) external returns(bool) {
		_validateAddresses(msg.sender, to);
		return _transfer(msg.sender, to, amount);
	}

	function approve(address spender, uint256 amount) external returns(bool) {
		if (spender == address(0)) {
			revert InvalidReceiver(address(0));
		}

		allowance[msg.sender][spender] = amount;

		emit Approval(msg.sender, spender, amount);

		return true;
	}

	function transferFrom(address from, address to, uint256 amount) external returns(bool) {
		_validateAddresses(from, to);

		if (msg.sender != from) {
			uint256 a = allowance[from][msg.sender];

			if (a < amount) {
				revert InsufficientAllowance(from, msg.sender, a, amount);
			}

			unchecked {
				allowance[from][msg.sender] = a - amount;
			}
		}

		return _transfer(from, to, amount);
	}

	function _transfer(address from, address to, uint256 amount) internal returns(bool){
		if (balanceOf[from] < amount) {
			revert InsufficientFunds(from, balanceOf[from], amount);
		}

		unchecked {
			balanceOf[from] -= amount;
			balanceOf[to] += amount;	
		}

		emit Transfer(from, to, amount);

		return true;
	}

	function _validateAddresses(address from, address to) internal pure {
		if (from == address(0)) {
			revert InvalidSender(address(0));
		}

		if (to == address(0)) {
			revert InvalidReceiver(address(0));
		}
	}
}
