// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

/**
 * @notice Allows derived contracts to be temporarily paused by authorized accounts. 
 * 
 * @dev Extend it to have when_paused & when_unpaused modifiers in derived contracts.
 */
abstract contract Pausable {
	bool public paused;

	event Paused(address a);
	event Unpaused(address a);

	error ContractPaused();
	error ContractUnpaused();

	/**
	 * @dev Allows functions to be called only when a contact is paused.
	 */
	modifier when_paused() {
		requirePaused();
		_;
	}

	/**
	 * @dev Allows functions to be called only when a contact is NOT paused.
	 */
	modifier when_unpaused() {
		requireUnpaused();
		_;
	}

	/**
	 * @dev Pauses a contract.
	 */
	function pause() internal when_unpaused {
		paused = true;
		emit Paused(msg.sender);
	}

	/**
	 * @dev Unpauses/resumes a contract.
	 */
	function unpause() internal when_paused {
		paused = false;
		emit Unpaused(msg.sender);
	}

	function requirePaused() internal view {
		if (! paused) {
			revert ContractUnpaused();
		}
	}

	function requireUnpaused() internal view {
		if (paused) {
			revert ContractPaused();
		}
	}
}
