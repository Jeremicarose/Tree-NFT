// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

/**
 * @title TreeNFT
 * @dev A contract for minting and managing tree non-fungible tokens (NFTs).
 */
contract TreeNFT is Initializable, ERC721EnumerableUpgradeable, OwnableUpgradeable {
    struct Tree {
        string species;
        uint256 age;
        string location;
        string proofOfPlant;
        string proofOfLife;
    }

    mapping (uint256 => Tree) private _treeInfo;

    event TreeMinted(address indexed owner, uint256 indexed tokenId, string species, uint256 age, string location);
    event TreeAgeUpdated(address indexed owner, uint256 indexed tokenId, uint256 newAge);
    event TreeProofOfPlantUpdated(address indexed owner, uint256 indexed tokenId, string newProofOfPlant);
    event TreeProofOfLifeUpdated(address indexed owner, uint256 indexed tokenId, string newProofOfLife);
    event TreeSpeciesUpdated(address indexed owner, uint256 indexed tokenId, string newSpecies);

    /**
     * @dev Initializes the contract.
     */
    function initialize() public initializer {
        __ERC721_init("TreeNFT", "TNFT");
        __Ownable_init();
    }

    /**
     * @dev Sets the tree information for a given token ID.
     * @param tokenId The ID of the token.
     * @param tree The tree information.
     */
    function _setTreeInfo(uint256 tokenId, Tree memory tree) internal onlyOwner {
        _treeInfo[tokenId] = tree;
    }

    /**
     * @dev Mints a new tree NFT.
     * @param to The address to mint the token to.
     * @param tokenId The ID of the token.
     * @param species The species of the tree.
     * @param age The age of the tree.
     * @param location The location of the tree.
     * @param proofOfPlant The proof of plant for the tree.
     * @param proofOfLife The proof of life for the tree.
     * @param tokenURI The URI for the token metadata.
     */
    function mint(
        address to,
        uint256 tokenId,
        string memory species,
        uint256 age,
        string memory location,
        string memory proofOfPlant,
        string memory proofOfLife,
        string memory tokenURI
    ) public onlyOwner {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _setTreeInfo(tokenId, Tree(species, age, location, proofOfPlant, proofOfLife));
        emit TreeMinted(to, tokenId, species, age, location);
    }

    /**
     * @dev Retrieves the tree information for a given token ID.
     * @param tokenId The ID of the token.
     * @return The tree information.
     */
    function getTreeInfo(uint256 tokenId) public view returns (
        string memory species,
        uint256 age,
        string memory location,
        string memory proofOfPlant,
        string memory proofOfLife
    ) {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        Tree memory tree = _treeInfo[tokenId];
        return (
            tree.species,
            tree.age,
            tree.location,
            tree.proofOfPlant,
            tree.proofOfLife
        );
    }

    /**
     * @dev Updates the age of a tree for a given token ID.
     * @param tokenId The ID of the token.
     * @param newAge The new age of the tree.
     */
    function updateTreeAge(uint256 tokenId, uint256 newAge) public onlyOwner {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        _treeInfo[tokenId].age = newAge;
        emit TreeAgeUpdated(ownerOf(tokenId), tokenId, newAge);
    }

    /**
     * @dev Updates the proof of plant for a given token ID.
     * @param tokenId The ID of the token.
     * @param newProofOfPlant The new proof of plant for the tree.
     */
    function updateProofOfPlant(uint256 tokenId, string memory newProofOfPlant) public onlyOwner {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        _treeInfo[tokenId].proofOfPlant = newProofOfPlant;
        emit TreeProofOfPlantUpdated(ownerOf(tokenId), tokenId, newProofOfPlant);
    }

    /**
     * @dev Updates the proof of life for a given token ID.
     * @param tokenId The ID of the token.
     * @param newProofOfLife The new proof of life for the tree.
     */
    function updateProofOfLife(uint256 tokenId, string memory newProofOfLife) public onlyOwner {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        _treeInfo[tokenId].proofOfLife = newProofOfLife;
        emit TreeProofOfLifeUpdated(ownerOf(tokenId), tokenId, newProofOfLife);
    }

    /**
     * @dev Updates the species of a tree for a given token ID.
     * @param tokenId The ID of the token.
     * @param newSpecies The new species of the tree.
     */
    function updateSpecies(uint256 tokenId, string memory newSpecies) public onlyOwner {
        require(_exists(tokenId), "TreeNFT: Token ID does not exist");
        _treeInfo[tokenId].species = newSpecies;
        emit TreeSpeciesUpdated(ownerOf(tokenId), tokenId, newSpecies);
    }

    /**
     * @dev Retrieves the total number of minted trees.
     * @return The total number of minted trees.
     */
    function getTotalMintedTrees() public view returns (uint256) {
        return totalSupply();
    }
}
