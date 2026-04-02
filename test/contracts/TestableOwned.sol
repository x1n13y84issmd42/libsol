// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { Owned } from "../../contracts/access/Owned.sol";

contract TestableOwned is Owned {
	function test() external view OnlyOwner {
		///
	}
}
