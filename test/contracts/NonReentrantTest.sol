// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { NonReentrant } from "../../contracts/access/NonReentrant.sol";
import { Test } from 'forge-std/Test.sol';

/**
 * @title Test subject.
 */
contract TestableNonReentrant is NonReentrant {
	function action() external non_reentrant {
		(bool ok,) = msg.sender.call{value: 0}("");
		require(ok);
	}
}

contract NonReentrantTest is Test {
	TestableNonReentrant testable;

	function setUp() public {
		testable = new TestableNonReentrant();
	}

	error Foobar();

	function test_reentrancy() public {
		testable.action();
	}

	receive() external payable {
		vm.expectRevert(NonReentrant.ReentrancyDenied.selector);

		TestableNonReentrant(msg.sender).action();
	}
}
