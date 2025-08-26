//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/*

$$$$$$$$\                                            $$$$$$$$\                  
$$  _____|                                           $$  _____|                 
$$ |   $$\   $$\  $$$$$$\   $$$$$$\  $$\   $$\       $$ |    $$$$$$\  $$\   $$\ 
$$$$$\ $$ |  $$ |$$  __$$\ $$  __$$\ $$ |  $$ |      $$$$$\ $$  __$$\ \$$\ $$  |
$$  __|$$ |  $$ |$$ |  \__|$$ |  \__|$$ |  $$ |      $$  __|$$ /  $$ | \$$$$  / 
$$ |   $$ |  $$ |$$ |      $$ |      $$ |  $$ |      $$ |   $$ |  $$ | $$  $$<  
$$ |   \$$$$$$  |$$ |      $$ |      \$$$$$$$ |      $$ |   \$$$$$$  |$$  /\$$\ 
\__|    \______/ \__|      \__|       \____$$ |      \__|    \______/ \__/  \__|
                                     $$\   $$ |                                 
                                     \$$$$$$  |                                 
                                      \______/                                  

$$$$$$$$\        $$\                           $$\                 $$\   $$\ $$$$$$$$\ $$$$$$$$\ 
$$  _____|       \__|                          $$ |                $$$\  $$ |$$  _____|\__$$  __|
$$ |    $$$$$$\  $$\  $$$$$$\  $$$$$$$\   $$$$$$$ | $$$$$$$\       $$$$\ $$ |$$ |         $$ |   
$$$$$\ $$  __$$\ $$ |$$  __$$\ $$  __$$\ $$  __$$ |$$  _____|      $$ $$\$$ |$$$$$\       $$ |   
$$  __|$$ |  \__|$$ |$$$$$$$$ |$$ |  $$ |$$ /  $$ |\$$$$$$\        $$ \$$$$ |$$  __|      $$ |   
$$ |   $$ |      $$ |$$   ____|$$ |  $$ |$$ |  $$ | \____$$\       $$ |\$$$ |$$ |         $$ |   
$$ |   $$ |      $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |$$$$$$$  |      $$ | \$$ |$$ |         $$ |   
\__|   \__|      \__| \_______|\__|  \__| \_______|\_______/       \__|  \__|\__|         \__|   
                                                                                                                                                                                                                                                                                               
*/

// You didn't get on the presale for the FurryFoxFriends NFTs?
// No worries, you can still get one!
contract FurryFoxFriends is ERC721 {
    using MerkleProof for bytes32;

    bytes32 merkleRoot;
    uint256 totalSupply;
    bool isPublicSale;
    mapping(address => bool) alreadyMinted;
    mapping(bytes32 => bool) alreadyUsedLeaf;

    constructor(bytes32 _merkleRoot) ERC721("FurryFoxFriends", "FFF"){
        merkleRoot = _merkleRoot;
    }
    function openPresale() external {
        isPublicSale = true;
    }

    function presaleMint(bytes32[] calldata proof, bytes32 leaf) external {
        require(MerkleProof.verifyCalldata(proof, merkleRoot, leaf), "not verified");
        require(!alreadyMinted[msg.sender], "already minted");
        require(!alreadyUsedLeaf[leaf], "leaf already used");

        totalSupply++;
        _mint(msg.sender, totalSupply - 1);
    }

    function mint() external {
        require(isPublicSale, "public sale not open");

        totalSupply++;
        _mint(msg.sender, totalSupply - 1);
    }
}
