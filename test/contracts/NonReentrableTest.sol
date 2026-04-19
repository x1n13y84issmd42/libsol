// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { NonReentrable } from "../../contracts/access/NonReentrable.sol";
import { Test } from 'forge-std/Test.sol';

/**
 * @title Test subject.
 */
contract TestableNonReentrable is NonReentrable {
	function action() external non_reentrant {
		(bool ok,) = msg.sender.call{value: 0}("");
		require(ok);
	}
}

contract NonReentrableTest is Test {
	TestableNonReentrable testable;

	function setUp() public {
		testable = new TestableNonReentrable();
	}

	error Foobar();

	function test_reentrancy() public {
		testable.action();
	}

	receive() external payable {
		vm.expectRevert(NonReentrable.ReentrancyDenied.selector);

		TestableNonReentrable(msg.sender).action();
	}
}
