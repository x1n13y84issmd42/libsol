// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

// Implements a binary interval tree.
library IntervalTree {
    struct Interval {
        uint a;
        uint b;
    }
    
    struct Node {
        Interval i;
        address addr;
    
        uint max;
        
        // Indices of child nodes in the node array within a Tree instance.
        uint left;
        uint right;
    }
    
    // A "hybrid array" collection type.
    // Never shrinks, always grows, can be emptied at no cost and refilled at will.
    struct NodeArray {
        Node[] data;
        uint length;
    }
    
    // Adds a node to the array.
    function push(NodeArray storage array, Node storage node) public {
        if (array.length >= array.data.length) {
            array.data.push(node);
        } else {
            array.data[array.length] = node;
        }
        array.length++;
    }
    
    // Resets the array to "empty" state.
    function empty(NodeArray storage array) public {
        array.length = 0;
    }
    
    function at(NodeArray storage array, uint i) public view returns(Node storage) {
        return array.data[i];
    }
    
    // The tree itself.
    // Uses an array for storage.
    struct Tree {
        Node[] nodes;
    }

    // Adds an interval to the tree.    
    function add(Tree storage tree, uint a, uint b, address addr) public {
        tree.nodes.push(Node({
            i: Interval({a: a, b: b}),
            max: b,
            left: 0, right: 0,
            addr: addr
        }));
        
        fix(tree, tree.nodes[0], tree.nodes.length-1, a, b);
    }
    
    function max(uint a, uint b) private pure returns(uint) {
        if (a > b)
            return a;
        
        return b;
    }
    
    // Finds a correct place for a newly inserted node.
    function fix(Tree storage tree, Node storage node, uint nid, uint a, uint b) private {
        node.max = max(node.max, b);

        if (a < node.i.a) {
            if (node.left != 0) {
                fix(tree, tree.nodes[node.left], nid, a, b);
                return;
            }

            node.left = nid;
        } else {
            if (node.right != 0) {
                fix(tree, tree.nodes[node.right], nid, a, b);
                return;
            }

            node.right = nid;
        }
    }
    
    // Checks whether the interval i contains the value v.
    function contains(Interval storage i, uint v) private view returns(bool) {
        return (i.a <= v && v <= i.b);
    }

    // Traverses the tree and finds all intervals that contain v.
    // Puts found intervals into the nodes array.
    function search(Tree storage tree, uint v, NodeArray storage nodes) public {
        searchIntervals(tree, 0, v, nodes);
    }
    
    // DFS.
    function searchIntervals(Tree storage tree, uint i, uint v, NodeArray storage nodes) private {
        if (contains(tree.nodes[i].i, v)) {
            push(nodes, tree.nodes[i]);
        }

        if (tree.nodes[i].left != 0 && tree.nodes[tree.nodes[i].left].max >= v) {
            searchIntervals(tree, tree.nodes[i].left, v, nodes);
        }
        
        if (tree.nodes[i].right != 0 && tree.nodes[tree.nodes[i].right].max >= v) {
            searchIntervals(tree, tree.nodes[i].right, v, nodes);
        }
    }
    
    function length(Tree storage tree) public view returns(uint) {
        return tree.nodes.length;
    }
}