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
        //Carry out the attack here
        // The attacker tries to mint during the presale without being whitelisted
        

        
        assertEq(furry.ownerOf(0), attackerAddress);
        vm.stopPrank();
    }
}
