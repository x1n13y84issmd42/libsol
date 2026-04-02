// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

contract Owned {
	address public owner;

	error OnlyOwnerAllowed(address addr);
	error InvalidOwner(address addr);

	event OwnershipTransfer(address newOwner);

	modifier only_owner {
		if (msg.sender != owner) {
			revert OnlyOwnerAllowed(msg.sender);
		}

		_;
	}

	constructor() {
		owner = msg.sender;
	}

	function transferOwnership(address newOwner) external only_owner {
		if (newOwner == address(0)) {
			revert InvalidOwner(address(0));
		}

		owner = newOwner;
		emit OwnershipTransfer(newOwner);
	}
}
