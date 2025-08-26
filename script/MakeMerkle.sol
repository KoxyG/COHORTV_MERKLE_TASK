// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

// Merkle proof generator script (address-only version)
// To use:
// 1. Run `forge script script/GenerateInput.s.sol` to generate the input file
// 2. Run `forge script script/Merkle.s.sol`
// 3. The output file will be generated in /script/target/output.json

/** 
 * @title MakeMerkle (Address Only)
 * @author Ciara Nightingale
 * @author Cyfrin
 *
 * Original Work by:
 * @author kootsZhin
 * @notice https://github.com/dmfxyz/murky
 */

contract MakeMerkle is Script, ScriptHelper {
    using stdJson for string;

    Merkle private m = new Merkle();

    string private inputPath = "/script/target/input.json";
    string private outputPath = "/script/target/output.json";

    string private elements = vm.readFile(string.concat(vm.projectRoot(), inputPath));
    string[] private types = elements.readStringArray(".types");
    uint256 private count = elements.readUint(".count");

    bytes32[] private leafs = new bytes32[](count);
    string[] private inputs = new string[](count);
    string[] private outputs = new string[](count);

    string private output;

    // Public state variable to store the Merkle root
    string public merkleRoot;

    function getValuesByIndex(uint256 i, uint256 j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }

    function generateJsonEntries(string memory _inputs, string memory _proof, string memory _root, string memory _leaf)
        internal
        pure
        returns (string memory)
    {
        // Proper JSON formatting with double quotes
        return string.concat(
            "{",
            '\"inputs\":', _inputs, ",",
            '\"proof\":', _proof, ",",
            '\"root\":\"', _root, '\",',
            '\"leaf\":\"', _leaf, '\"',
            "}"
        );
    }

    function run() public {
        console.log("Generating Merkle Proof for %s", inputPath);

        for (uint256 i = 0; i < count; ++i) {
            string[] memory input = new string[](types.length);
            bytes32[] memory data = new bytes32[](types.length);

            for (uint256 j = 0; j < types.length; ++j) {
                if (compareStrings(types[j], "address")) {
                    address value = elements.readAddress(getValuesByIndex(i, j));
                    data[j] = bytes32(uint256(uint160(value)));
                    input[j] = vm.toString(value);
                }
                // No uint logic: skip any non-address type
            }
            // Only address data is encoded
            leafs[i] = keccak256(ltrim64(abi.encode(data)));
            inputs[i] = stringArrayToString(input);
        }

        for (uint256 i = 0; i < count; ++i) {
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));
            string memory root = vm.toString(m.getRoot(leafs));
            string memory leaf = vm.toString(leafs[i]);
            string memory input = inputs[i];
            outputs[i] = generateJsonEntries(input, proof, root, leaf);
        }

        // Store the Merkle root as a string
        merkleRoot = vm.toString(m.getRoot(leafs));

        console.log("The Merkle root is %s", merkleRoot);

        output = stringArrayToArrayString(outputs);
        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);
        console.log("DONE: The output is found at %s", outputPath);
    }

    /// @notice Returns the Merkle root after running the script
    function getMerkleRoot() external view returns (string memory) {
        return merkleRoot;
    }
}