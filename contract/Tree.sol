// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Import the ERC721EnumerableUpgradeable contract
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

// Inherit from the ERC721EnumerableUpgradeable contract
contract TreeNFT is
    Initializable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    // Struct for storing tree information
    struct Tree {
        string species;
        uint256 age;
        string location;
        string proofOfPlant;
        string proofOfLife;
    }

    // Mapping from token ID to tree information
    mapping(uint256 => Tree) private _treeInfo;

    // Event for when new tree NFT is minted
    event TreeMinted(
        address indexed owner,
        uint256 indexed tokenId,
        string species,
        uint256 age,
        string location
    );

    // Event for when tree age is updated
    event TreeAgeUpdated(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 newAge
    );

    // Event for when tree proof of plant is updated
    event TreeProofOfPlantUpdated(
        address indexed owner,
        uint256 indexed tokenId,
        string newProofOfPlant
    );

    // Event for when tree proof of life is updated
    event TreeProofOfLifeUpdated(
        address indexed owner,
        uint256 indexed tokenId,
        string newProofOfLife
    );

    // Event for when tree species is updated
    event TreeSpeciesUpdated(
        address indexed owner,
        uint256 indexed tokenId,
        string newSpecies
    );

    // Initialize the contract
    function initialize() public initializer {
        __ERC721_init("TreeNFT", "TNFT");
        __Ownable_init();
    }

    constructor() {
        initialize();
    }

    modifier exists(uint256 tokenId) {
        require(_exists(tokenId), "Token ID does not exist");
        _;
    }

    function _setTreeInfo(
        uint256 tokenId,
        Tree memory tree
    ) internal onlyOwner {
        _treeInfo[tokenId] = tree;
    }

    /**
     * @dev Mints a new tree NFT
     * @param to The receiver of the minted NFT
     * @param species The species of the tree
     * @param age  The age of the tree
     * @param location The location of the tree
     * @param proofOfPlant The proof of the tree
     * @param proofOfLife The proof that the tree is still alive
     */
    function mint(
        address to,
        string memory species,
        uint256 age,
        string memory location,
        string calldata proofOfPlant,
        string calldata proofOfLife
    ) public onlyOwner {
        require(
            to != address(0),
            "Zero address is not a valid receiver address"
        );

        require(bytes(species).length > 0, "Empty species");
        require(bytes(location).length > 0, "Empty location");
        require(bytes(proofOfPlant).length > 0, "Empty proof of plant");
        require(bytes(proofOfLife).length > 0, "Empty proof of life");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _mint(to, tokenId);
        _setTreeInfo(
            tokenId,
            Tree(species, age, location, proofOfPlant, proofOfLife)
        );
        emit TreeMinted(to, tokenId, species, age, location);
    }

    /// @return  The tree information for a given token ID
    function getTreeInfo(
        uint256 tokenId
    )
        public
        view
        exists(tokenId)
        returns (
            string memory,
            uint256,
            string memory,
            string memory,
            string memory
        )
    {
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
     * @dev Update the age of a tree for a given token ID
     * @param tokenId The tokenId of the NFT
     * @param newAge The updated age of the tree
     */
    function updateTreeAge(
        uint256 tokenId,
        uint256 newAge
    ) public onlyOwner exists(tokenId) {
        require(newAge > _treeInfo[tokenId].age, "New age shouldn't be lower than the current age");
        _treeInfo[tokenId].age = newAge;
        emit TreeAgeUpdated(ownerOf(tokenId), tokenId, newAge);
    }

    /**
     * @dev Update the proof of plant for a given token ID
     * @param tokenId The tokenId of the NFT
     * @param newProofOfPlant The new proof of plant for the tree NFT 
     */
    function updateProofOfPlant(
        uint256 tokenId,
        string calldata newProofOfPlant
    ) public onlyOwner exists(tokenId) {
        _treeInfo[tokenId].proofOfPlant = newProofOfPlant;
        emit TreeProofOfPlantUpdated(
            ownerOf(tokenId),
            tokenId,
            newProofOfPlant
        );
    }

     /**
     * @dev Update the proof of life for a given token ID
     * @param tokenId The tokenId of the NFT
     * @param newProofOfLife The new proof of life for the tree NFT 
     */
    function updateProofOfLife(
        uint256 tokenId,
        string calldata newProofOfLife
    ) public onlyOwner exists(tokenId) {
        _treeInfo[tokenId].proofOfLife = newProofOfLife;
        emit TreeProofOfLifeUpdated(ownerOf(tokenId), tokenId, newProofOfLife);
    }

        /**
     * @dev Update the species for a given token ID
     * @param tokenId The tokenId of the NFT
     * @param newSpecies The new species for the tree NFT 
     */
    function updateSpecies(
        uint256 tokenId,
        string calldata newSpecies
    ) public onlyOwner exists(tokenId) {
        _treeInfo[tokenId].species = newSpecies;
        emit TreeSpeciesUpdated(ownerOf(tokenId), tokenId, newSpecies);
    }

    /// @return Get the total number of minted trees
    function getTotalMintedTrees() public view returns (uint256) {
        return totalSupply();
    }
}
