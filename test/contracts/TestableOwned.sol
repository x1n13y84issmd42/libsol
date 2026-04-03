// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { Owned } from "../../contracts/access/Owned.sol";

/**
 * @title Test subject for the Owned contract test.
 */
contract TestableOwned is Owned {
	function action() external view only_owner {
		///
	}
}
