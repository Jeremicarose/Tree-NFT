// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// Import the ERC721EnumerableUpgradeable contract
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

// Inherit from the ERC721EnumerableUpgradeable contract
contract TreeNFT is
    Initializable,
    ERC721EnumerableUpgradeable,
  
{
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

    function _setTreeInfo(uint256 tokenId, Tree memory tree) internal {
        _treeInfo[tokenId] = tree;
    }

    // Mint a new tree NFT
    function mint(
        address to,
        uint256 tokenId,
        string calldata species,
        uint256 age,
        string calldata location,
        string calldata proofOfPlant,
        string calldata proofOfLife,
        string calldata tokenURI
    ) public {
        _mint(to, tokenId);
        //_setTokenURI(tokenId, tokenURI);
        _setTreeInfo(
            tokenId,
            Tree(species, age, location, proofOfPlant, proofOfLife)
        );
        emit TreeMinted(to, tokenId, species, age, location);
    }

    // Get the tree information for a given token ID

    function getTreeInfo(uint256 tokenId)
        public
        view
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

    // Update the age of a tree for a given token ID
    function updateTreeAge(uint256 tokenId, uint256 newAge) public  {
        require(_exists(tokenId), "Token ID does not exist");
        _treeInfo[tokenId].age = newAge;
        emit TreeAgeUpdated(ownerOf(tokenId), tokenId, newAge);
    }

    // Update the proof of plant for a given token ID
    function updateProofOfPlant(
        uint256 tokenId,
        string calldata newProofOfPlant
    ) public  {
        require(_exists(tokenId), "Token ID does not exist");
        _treeInfo[tokenId].proofOfPlant = newProofOfPlant;
        emit TreeProofOfPlantUpdated(
            ownerOf(tokenId),
            tokenId,
            newProofOfPlant
        );
    }

    // Update the proof of life for a given token ID
    function updateProofOfLife(uint256 tokenId, string calldata newProofOfLife)
        public
        
    {
        require(_exists(tokenId), "Token ID does not exist");
        _treeInfo[tokenId].proofOfLife = newProofOfLife;
        emit TreeProofOfLifeUpdated(ownerOf(tokenId), tokenId, newProofOfLife);
    }

    // Update the species of a tree for a given token ID
    function updateSpecies(uint256 tokenId, string calldata newSpecies)
        public
        onlyOwner
    {
        require(_exists(tokenId), "Token ID does not exist");
        _treeInfo[tokenId].species = newSpecies;
        emit TreeSpeciesUpdated(ownerOf(tokenId), tokenId, newSpecies);
    }

    // Get the total number of minted trees
    function getTotalMintedTrees() public view returns (uint256) {
        return totalSupply();
    }
}
