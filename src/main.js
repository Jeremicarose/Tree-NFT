const Web3 = require('web3');
const TreeNFT = require("../contract/Tree.abi.json");
const { newKitFromWeb3 } = require('@celo/contractkit');
let contractInstance;

const ERC20_DECIMALS = 18;
const TNContractAddress = "0x0cc968a21B00F76407F167b0d4D9EAE893FF9FbE";

let kit;
let isInitialized = false; // Flag to check if contract is already initialized

const connectCeloWallet = async function () {
  if (window.celo && !isInitialized) { // Check if Celo wallet exists and contract is not already initialized
    try {
      await window.celo.enable();

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
    } catch (error) {
      console.error(error);
    }
  } else {
    console.log("Please install the CeloExtensionWallet or contract is already initialized.");
  }
}

// Rest of the code remains unchanged...


const mintTree = async (event) => {
  event.preventDefault();

  let species = document.querySelector('#species').value
  let age = document.querySelector('#age').value
  let location = document.querySelector('#location').value
  let proofOfPlant = document.querySelector('#proofOfPlant').value
  let proofOfLife = document.querySelector('#proofOfLife').value
  let tokenURI = "https://ipfs";

  document.querySelector('#mintButton').textContent = 'Minting...';
  try {
    const tx = await contractInstance.methods.mint(kit.defaultAccount, species, age, location, proofOfPlant, proofOfLife, tokenURI).send({from: kit.defaultAccount});
    console.log(tx);
    document.querySelector('#mintButton').textContent = 'Mint';
    document.querySelector('#successAlert').style.display = 'block';
    document.querySelector('#successAlert').textContent = 'Tree successfully minted! ' + kit.defaultAccount;
    await loadTrees();
  } catch (error) {
    console.error(error);
    document.querySelector('#mintButton').textContent = 'Mint';
    document.querySelector('#errorAlert').style.display = 'block';
    document.querySelector('#errorAlert').textContent = 'An error occurred while minting the tree.';
  }
}

document.querySelector('#mintForm').addEventListener('submit', mintTree);

const loadTrees = async () => {
  
  try {
    let totalSupply = await contractInstance.methods.getTotalMintedTrees().call();
    const tbody = document.querySelector('#treeInfoTableBody');
    tbody.innerHTML = '';
    
    for(let i = 0; i < totalSupply; i++) {
      const tree = await contractInstance.methods.getTreeInfo(i).call();

      // The getTreeInfo function returns an array, so you need to reference the items by index
      // If you have control over the contract, consider returning a struct with named fields for better readability
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
  } catch (error) {
    console.error(error);
  }
}



const getBalance = async function () {
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance
}

window.addEventListener('load', async () => {
  await connectCeloWallet()
  if (kit) {
    await getBalance()
  }
});
