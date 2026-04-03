// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import "../../contracts/collection/IntervalTree.sol";

/**
 * @notice Test subject for IntervalTree testing.
 */
contract TestableIntervalTree {
    using IntervalTree for IntervalTree.Tree;
    using IntervalTree for IntervalTree.Node;
    
    IntervalTree.Tree tree;
    IntervalTree.Node[] nodes;

    event Result(uint a, uint b);

    function add(uint a, uint b) public {
        tree.add(a, b, msg.sender);
    }
    
    function check(uint v) public {
        tree.search(v, nodes);

        for (uint i=0; i<nodes.length; i++) {
            emit Result(nodes[i].i.a, nodes[i].i.b);
        }

        delete nodes;
    }

    function length() external view returns(uint256) {
        return tree.length();
    }
}
