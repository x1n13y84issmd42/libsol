// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

/**
 * @notice Prevents reentrant calls to contract functions.
 * @dev Inherit this contract to have the {non_reentrant} function modifier available.
 */
contract NonReentrant {
	uint8 entered;

	/**
	 * @notice Reentrant calls will revert with this error.
	 */
	error ReentrancyDenied();
	
	/**
	 * @notice Function modifier to prevent reentrant calls. 
	 */
	modifier non_reentrant() {
		if (entered == 1) {
			revert ReentrancyDenied();
		}
		entered = 1;
		_;
		entered = 0;
	}
}
