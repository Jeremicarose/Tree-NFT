const Web3 = require('web3');
const TreeNFT = require("../contract/Tree.abi.json");
const { newKitFromWeb3 } = require('@celo/contractkit');
let contractInstance;

const ERC20_DECIMALS = 18;
const TNContractAddress = "0xfEBbBE2A50e01e380CBb55B2ab0E77e296d28aEe";

let kit;
let isInitialized = false; // Flag to check if contract is already initialized

const connectCeloWallet = async function() {
  if (window.celo && !isInitialized) { // Check if Celo wallet exists and contract is not already initialized
    try {
      console.log("Celo wallet detected. Trying to enable...");
      await window.celo.enable();
      console.log("Celo wallet enabled!");

      const web3 = new Web3(window.celo);
      kit = newKitFromWeb3(web3);

      const accounts = await kit.web3.eth.getAccounts();
      if (accounts.length === 0) {
        throw new Error('No account found');
      }
      kit.defaultAccount = accounts[0];

      contractInstance = new kit.web3.eth.Contract(
        TreeNFT,
        TNContractAddress
      );

      // Set the isInitialized flag to true after successful initialization
      isInitialized = true;

      // Call the loadTrees function to display the minted trees on the page
      await loadTrees();
    } catch (error) {
      console.error("Error while enabling Celo wallet:", error);
    }
  } else {
    console.log("Please install the CeloExtensionWallet or contract is already initialized.");
  }
}

const mintTree = async (event) => {
  event.preventDefault();

  let species = document.querySelector('#species').value;
  let age = document.querySelector('#age').value;
  let location = document.querySelector('#location').value;
  let proofOfPlant = document.querySelector('#proofOfPlant').value;
  let proofOfLife = document.querySelector('#proofOfLife').value;
  let tokenURI = "https://example.com/metadata";

  document.querySelector('#mintButton').disabled = true;
  document.querySelector('#mintButton').textContent = 'Minting...';
  try {
    const totalSupply = await contractInstance.methods.getTotalMintedTrees().call();
    const tokenId = parseInt(totalSupply);
    const to = kit.defaultAccount;

    const tx = await contractInstance.methods.mint(
      to,
      tokenId,
      species,
      age,
      location,
      proofOfPlant,
      proofOfLife,
      tokenURI
    ).send({ from: kit.defaultAccount });

    console.log(tx);
    document.querySelector('#mintButton').textContent = 'Mint';
    document.querySelector('#successAlert').style.display = 'block';
    document.querySelector('#successAlert').textContent = 'Tree successfully minted! ' + kit.defaultAccount;
    await loadTrees();
  } catch (error) {
    console.error('Transaction failed:', error.message);
    document.querySelector('#mintButton').textContent = 'Mint';
    document.querySelector('#errorAlert').style.display = 'block';
    document.querySelector('#errorAlert').textContent = 'An error occurred while minting the tree.';
  }
  document.querySelector('#mintButton').disabled = false;
}

document.querySelector('#mintForm').addEventListener('submit', mintTree);

const loadTrees = async () => {
  try {
    console.log("Loading trees...");
    const totalSupply = await contractInstance.methods.getTotalMintedTrees().call();
    const tokenId = parseInt(totalSupply);
    console.log("Total supply:", tokenId);
    const tbody = document.querySelector('#treeInfoTableBody');
    tbody.innerHTML = '';

    // Check if totalSupply is defined before starting the loop
    if (typeof totalSupply === 'string') { // BigNumber returns string
      console.log("Looping through trees...");
      for (let i = 0; i < parseInt(totalSupply); i++) {
        console.log("Fetching tree info for index:", i);
        const tree = await contractInstance.methods.getTreeInfo(i).call();
        console.log("Tree info:", tree);

        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td>${tree[0]}</td>  <!-- species -->
          <td>${tree[1]}</td>  <!-- age -->
          <td>${tree[2]}</td>  <!-- location -->
          <td>${tree[3]}</td>  <!-- proofOfPlant -->
          <td>${tree[4]}</td>  <!-- proofOfLife -->
        `;
        tbody.appendChild(tr);
      }
    } else {
      console.log("Total supply is undefined");
    }
  } catch (error) {
    console.error("Error in loadTrees:", error);
  }
}

const getBalance = async function() {
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance
}

window.addEventListener('load', async () => {
  console.log("Window loaded");
  await connectCeloWallet();
  if (kit) {
    await getBalance();
  }
});

