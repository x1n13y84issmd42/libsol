// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { Pausable } from "../../contracts/utility/Pausable.sol";
import { Test } from 'forge-std/Test.sol';

/**
 * @dev Test subject.
 */
contract TestablePausable is Pausable {
	function stop() public when_unpaused {
		pause();
	}
	
	function go() public when_paused {
		unpause();
	}

	function action_on_pause() public when_paused {
		///
	}

	function action_on_unpause() public when_unpaused {
		///
	}
}

contract PausableTest is Test {
	TestablePausable testable;

	function setUp() public {
		testable = new TestablePausable();
	}

	function test() public {
		// Pausing it.
		vm.expectEmit(true, false, false, false);
		emit Pausable.Paused(msg.sender);
		testable.stop();
		require(testable.paused());

		// This passes.
		testable.action_on_pause();

		// This reverts.
		vm.expectRevert(Pausable.ContractPaused.selector);
		testable.action_on_unpause();
		
		// Cannot stop what is already stopped.
		vm.expectRevert(Pausable.ContractPaused.selector);
		testable.stop();

		///////

		// Unpausing it.
		vm.expectEmit(true, false, false, false);
		emit Pausable.Unpaused(msg.sender);
		testable.go();
		require(testable.paused() == false);

		// This passes.
		testable.action_on_unpause();

		// This reverts.
		vm.expectRevert(Pausable.ContractUnpaused.selector);
		testable.action_on_pause();

		// Cannot resume what is already going.
		vm.expectRevert(Pausable.ContractUnpaused.selector);
		testable.go();
	}
}
