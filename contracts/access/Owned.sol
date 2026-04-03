// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

/**
 * @notice Basic access control. Introduces contract ownership
 * and restricts certain function to be called only by contract owner.
 * 
 * @dev Inherit this to have the {only_owner} function modifier available.
 */
contract Owned {
	address public owner;

	error OnlyOwnerAllowed(address addr);
	error InvalidOwner(address addr);

	event OwnershipTransfer(address newOwner);

	/**
	 * @notice Function modifier that allows only contract owner to call certain functions.
	 */
	modifier only_owner {
		if (msg.sender != owner) {
			revert OnlyOwnerAllowed(msg.sender);
		}

		_;
	}

	constructor() {
		owner = msg.sender;
	}

	/**
	 * @notice Changes the contract owner. Can be done only by current contract owner.
	 * Emits {OwnershipTransfer} event.
	 * @param newOwner A new contract owner address. Cannot be address(0).
	 */
	function transferOwnership(address newOwner) external only_owner {
		if (newOwner == address(0)) {
			revert InvalidOwner(address(0));
		}

		owner = newOwner;
		emit OwnershipTransfer(newOwner);
	}
}
