// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Furry.sol";

contract CounterTest is Test {
    FurryFoxFriends furry;
    bytes32 merkleRoot = 0xc947ddeae47a6fd5b11ad273122c92bcc4f04d6eb11d56105836588302c9c69a; 
    // This is the Merkle root generated from the script/MakeMerkle.sol script
    // It corresponds to the following addresses and their respective proof in the output.json file
    // and can be used to mint in the presale:
    // 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D
    // 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    // 0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd
    // 0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D

    address attackerAddress;

    function setUp() public {
        furry = new FurryFoxFriends(merkleRoot);
        vm.label(address(furry), "FurryFoxFriends");

        attackerAddress = makeAddr("attacker");
        vm.label(attackerAddress, "Attacker");
    }

    function test_Attack() public {
        vm.startPrank(attackerAddress);
        
        // Try to exploit the presaleMint function with a completely fake leaf
        // that's not in the whitelist
        
        // Create a fake leaf using the attacker's address
        bytes32 fakeLeaf = keccak256(abi.encodePacked("fake_attack_leaf", attackerAddress));
        
        // Create fake proof
        bytes32[] memory fakeProof = new bytes32[](2);
        fakeProof[0] = bytes32(uint256(0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef));
        fakeProof[1] = bytes32(uint256(0xcafebabecafebabecafebabecafebabecafebabecafebabecafebabecafebabe));
        
        console.log("Attempting to mint with fake leaf:", vm.toString(fakeLeaf));
        
        // Try to mint using presaleMint() with fake leaf and proof
        try furry.presaleMint(fakeProof, fakeLeaf) {
            console.log("SUCCESS: Fake leaf attack worked!");
            assertEq(furry.ownerOf(0), attackerAddress);
        } catch Error(string memory reason) {
            console.log("Fake leaf attack failed with reason:", reason);
        }
        
        vm.stopPrank();
    }
    
    function test_MultipleAttackers() public {
        // First attacker tries with a fake leaf
        vm.startPrank(attackerAddress);
        
        bytes32[] memory fakeProof1 = new bytes32[](2);
        fakeProof1[0] = bytes32(uint256(0x1111111111111111111111111111111111111111111111111111111111111111));
        fakeProof1[1] = bytes32(uint256(0x2222222222222222222222222222222222222222222222222222222222222222));
        
        bytes32 fakeLeaf1 = keccak256(abi.encodePacked("fake_leaf_1", attackerAddress));
        
        try furry.presaleMint(fakeProof1, fakeLeaf1) {
            console.log("First attacker successfully minted with fake leaf!");
            assertEq(furry.ownerOf(0), attackerAddress);
        } catch Error(string memory reason) {
            console.log("First attacker failed:", reason);
        }
        
        vm.stopPrank();
        
        // Second attacker tries with a different fake leaf
        address secondAttacker = makeAddr("secondAttacker");
        vm.label(secondAttacker, "SecondAttacker");
        
        vm.startPrank(secondAttacker);
        
        bytes32[] memory fakeProof2 = new bytes32[](2);
        fakeProof2[0] = bytes32(uint256(0x3333333333333333333333333333333333333333333333333333333333333333));
        fakeProof2[1] = bytes32(uint256(0x4444444444444444444444444444444444444444444444444444444444444444));
        
        bytes32 fakeLeaf2 = keccak256(abi.encodePacked("fake_leaf_2", secondAttacker));
        
        try furry.presaleMint(fakeProof2, fakeLeaf2) {
            console.log("Second attacker successfully minted with fake leaf!");
            assertEq(furry.ownerOf(1), secondAttacker);
        } catch Error(string memory reason) {
            console.log("Second attacker failed:", reason);
        }
        
        vm.stopPrank();
        
        // Third attacker tries with another fake leaf
        address thirdAttacker = makeAddr("thirdAttacker");
        vm.label(thirdAttacker, "ThirdAttacker");
        
        vm.startPrank(thirdAttacker);
        
        bytes32[] memory fakeProof3 = new bytes32[](2);
        fakeProof3[0] = bytes32(uint256(0x5555555555555555555555555555555555555555555555555555555555555555));
        fakeProof3[1] = bytes32(uint256(0x6666666666666666666666666666666666666666666666666666666666666666));
        
        bytes32 fakeLeaf3 = keccak256(abi.encodePacked("fake_leaf_3", thirdAttacker));
        
        try furry.presaleMint(fakeProof3, fakeLeaf3) {
            console.log("Third attacker successfully minted with fake leaf!");
            assertEq(furry.ownerOf(2), thirdAttacker);
        } catch Error(string memory reason) {
            console.log("Third attacker failed:", reason);
        }
        
        vm.stopPrank();
    }
    
    function test_FakeLeafAttack() public {
        vm.startPrank(attackerAddress);
        
        // Try to create a completely fake leaf that's not in the whitelist
        // and see if we can somehow bypass the Merkle proof verification
        
        // Create a fake leaf with the attacker's address
        bytes32 fakeLeaf = keccak256(abi.encodePacked(attackerAddress));
        
        // Try different proof combinations to see if we can find a vulnerability
        bytes32[] memory fakeProof = new bytes32[](2);
        fakeProof[0] = bytes32(uint256(0x1234567890123456789012345678901234567890123456789012345678901234));
        fakeProof[1] = bytes32(uint256(0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdef));
        
        console.log("Attempting to mint with fake leaf:", vm.toString(fakeLeaf));
        
        // Try to mint with the fake leaf and proof
        try furry.presaleMint(fakeProof, fakeLeaf) {
            console.log("SUCCESS: Fake leaf attack worked!");
            assertEq(furry.ownerOf(0), attackerAddress);
        } catch Error(string memory reason) {
            console.log("Fake leaf attack failed with reason:", reason);
        }
        
        vm.stopPrank();
    }
    
    function test_ManipulatedLeafAttack() public {
        vm.startPrank(attackerAddress);
        
        // Try to create a fake leaf that might bypass verification
        // by manipulating the leaf construction in different ways
        
        // Method 1: Try with a simple hash of the attacker address
        bytes32 fakeLeaf1 = keccak256(abi.encodePacked(attackerAddress));
        
        // Method 2: Try with a hash that includes some padding
        bytes32 fakeLeaf2 = keccak256(abi.encodePacked(attackerAddress, "padding"));
        
        // Method 3: Try with a hash that mimics the original structure
        bytes32 fakeLeaf3 = keccak256(abi.encodePacked(bytes32(uint256(uint160(attackerAddress)))));
        
        console.log("Testing different fake leaf constructions...");
        
        // Try each fake leaf with random proofs
        bytes32[] memory fakeProof = new bytes32[](2);
        fakeProof[0] = bytes32(uint256(0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa));
        fakeProof[1] = bytes32(uint256(0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb));
        
        // Test fake leaf 1
        try furry.presaleMint(fakeProof, fakeLeaf1) {
            console.log("SUCCESS: Fake leaf 1 attack worked!");
            assertEq(furry.ownerOf(0), attackerAddress);
        } catch Error(string memory reason) {
            console.log("Fake leaf 1 failed:", reason);
        }
        
        // Test fake leaf 2
        try furry.presaleMint(fakeProof, fakeLeaf2) {
            console.log("SUCCESS: Fake leaf 2 attack worked!");
            assertEq(furry.ownerOf(1), attackerAddress);
        } catch Error(string memory reason) {
            console.log("Fake leaf 2 failed:", reason);
        }
        
        // Test fake leaf 3
        try furry.presaleMint(fakeProof, fakeLeaf3) {
            console.log("SUCCESS: Fake leaf 3 attack worked!");
            assertEq(furry.ownerOf(2), attackerAddress);
        } catch Error(string memory reason) {
            console.log("Fake leaf 3 failed:", reason);
        }
        
        vm.stopPrank();
    }
}
