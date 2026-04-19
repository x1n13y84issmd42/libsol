// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { Ownable } from "../../contracts/access/Ownable.sol";

/**
 * @title Test subject for the Owned contract test.
 */
contract TestableOwnable is Ownable {
	function action() external view only_owner {
		///
	}
}
