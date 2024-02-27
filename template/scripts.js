const USER_ABIFILE = '/artifacts/contracts/userControl.sol/UserControl.json';
const USER_ADDRESS = '0xF7C255C599b464De52a71c84aD6d0ab193bd3593';

const DEFAULT_RPC = 'https://ethereum-sepolia.publicnode.com';
const CHAIN_SYMBOL = 'S.ETH';
const DAPP_CHAIN = [
    '0xaa36a7'
];

web3 = new Web3(new Web3.providers.HttpProvider(DEFAULT_RPC));
let currentChain;
let userContract;

let isConnected = false;
let connectedAddress;
let connectedAccounts = [];
let connectedAccount;

let userData = [];

const isRegistered = ((user) => {
    if (userData.length == 0 || user == null) return false;
    if (userData.length - 1 < user) throw error ("User id out of bounds");
    return userData[user].registrationDate > 0;
});

const chainSupported = ((chain) => {
    let i;
    for (i = 0; i < DAPP_CHAIN.length; i++) {
        if (chain == DAPP_CHAIN[i]) break;
    }
    return (i < DAPP_CHAIN.length || DAPP_CHAIN.length == 0);
});

const addIcon = '<path d="M256 80c0-17.7-14.3-32-32-32s-32 14.3-32 32V224H48c-17.7 0-32 14.3-32 32s14.3 32 32 32H192V432c0 17.7 14.3 32 32 32s32-14.3 32-32V288H400c17.7 0 32-14.3 32-32s-14.3-32-32-32H256V80z"/>';
const loginIcon = '<path d="M217.9 105.9L340.7 228.7c7.2 7.2 11.3 17.1 11.3 27.3s-4.1 20.1-11.3 27.3L217.9 406.1c-6.4 6.4-15 9.9-24 9.9c-18.7 0-33.9-15.2-33.9-33.9l0-62.1L32 320c-17.7 0-32-14.3-32-32l0-64c0-17.7 14.3-32 32-32l128 0 0-62.1c0-18.7 15.2-33.9 33.9-33.9c9 0 17.6 3.6 24 9.9zM352 416l64 0c17.7 0 32-14.3 32-32l0-256c0-17.7-14.3-32-32-32l-64 0c-17.7 0-32-14.3-32-32s14.3-32 32-32l64 0c53 0 96 43 96 96l0 256c0 53-43 96-96 96l-64 0c-17.7 0-32-14.3-32-32s14.3-32 32-32z"/>';
const addText = 'Add Another Account';
const loginText = 'Login with MetaMask';

async function loadContract(abiFile, contractAddress) {
    return await fetch(abiFile)
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(text => {
        console.log('ABI loaded:', text.abi);
        const abi = text.abi;
        contract = new web3.eth.Contract(abi, contractAddress);
        return contract;
        
    })
    .catch(error => {
        console.error('Error loading text:', error);
    });
}

async function loadMain() {
    userContract = await loadContract(USER_ABIFILE, USER_ADDRESS);
    await checkMetamask();
    for (let i = 0; i < connectedAccounts.length; i++) {
        userData.push(await userContract.methods['getUserData(address)'](connectedAccounts[i]));
    }
    console.log(userData);
}

async function connectMetamask() {
    // Check if MetaMask is installed
    if (typeof window.ethereum !== 'undefined') {

        try {
            await setChain();

            // Request account access
            accounts = await ethereum.request({ method: 'eth_requestAccounts' });

            // Handle the connected accounts
            handleAccountsChanged(accounts);

        } catch (error) {
            console.error(error);
        }
    } else {
        accounts = [];
        handleAccountsChanged(accounts);
        console.error('MetaMask is not installed');
        alert("Please open this dApp in a browser with metamask installed.");
    }
}

async function checkMetamask() {
    if (typeof window.ethereum !== 'undefined') {

        // check for existing connection
        try {
            accounts = await ethereum.request({ method: 'eth_accounts' });
            await handleAccountsChanged(accounts);
        } catch (error) {
            console.error('Error:', error);
        }

        try {
            currentChain = await ethereum.request({ method: 'eth_chainId' });
            await handleChainChanged(currentChain);
        } catch (error) {
            console.error('Error:', error);
        }

    }
    
}

const getProfileCardHTML = (user) => {
    
    const userAddress = Web3.utils.toChecksumAddress(connectedAccounts[user]);
    const userUsername = userData[user].username ? userData[user].username : userAddress.slice(0, -6);
    const userAddressEnd = userData[user].username ? '' : userAddress.slice(-6);
    const genericIcon = `<button class="header-button">${userUsername.slice(0, 2)}</button>`;
    const profilePic = `<img width="50px" height="50px" src="${userData[user].imageUrl}" />`;
    const userImg = userData[user].imageUrl ? profilePic : genericIcon;
    if (user == connectedAccount) {
        return `<div class="profile-card active-profile" id="profileCardActive"><div class="profile-img" id="profileCardActiveImg">${userImg}</div> <div class="address"><span class="address-start" id="profileCardActiveUsername">${userUsername}</span><span class="address-end" id="profileCardActiveAddress">${userAddressEnd}</span></div><a href="/template/profile/" class="nav-icon"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M352 0c-12.9 0-24.6 7.8-29.6 19.8s-2.2 25.7 6.9 34.9L370.7 96 201.4 265.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L416 141.3l41.4 41.4c9.2 9.2 22.9 11.9 34.9 6.9s19.8-16.6 19.8-29.6V32c0-17.7-14.3-32-32-32H352zM80 32C35.8 32 0 67.8 0 112V432c0 44.2 35.8 80 80 80H400c44.2 0 80-35.8 80-80V320c0-17.7-14.3-32-32-32s-32 14.3-32 32V432c0 8.8-7.2 16-16 16H80c-8.8 0-16-7.2-16-16V112c0-8.8 7.2-16 16-16H192c17.7 0 32-14.3 32-32s-14.3-32-32-32H80z"/></svg></a></div>`;
    } else {
        return `<a href="javascript:void(0);" class="profile-card" id="profileCard${user}">
        <div class="profile-img">
            ${userImg}
        </div> 
        <div class="address"><span class="address-start">${userUsername}</span><span class="address-end">${userAddressEnd}</span></div>
        <div class="nav-icon"  id="profileSwitch"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M0 224c0 17.7 14.3 32 32 32s32-14.3 32-32c0-53 43-96 96-96H320v32c0 12.9 7.8 24.6 19.8 29.6s25.7 2.2 34.9-6.9l64-64c12.5-12.5 12.5-32.8 0-45.3l-64-64c-9.2-9.2-22.9-11.9-34.9-6.9S320 19.1 320 32V64H160C71.6 64 0 135.6 0 224zm512 64c0-17.7-14.3-32-32-32s-32 14.3-32 32c0 53-43 96-96 96H192V352c0-12.9-7.8-24.6-19.8-29.6s-25.7-2.2-34.9 6.9l-64 64c-12.5 12.5-12.5 32.8 0 45.3l64 64c9.2 9.2 22.9 11.9 34.9 6.9s19.8-16.6 19.8-29.6V448H352c88.4 0 160-71.6 160-160z"/></svg></svg></div>
    </a>`
    }
}

function switchAccounts(user) {
    console.log(`Switching to Account ${user}`);
    connectedAccount = user;
    // console.log(`Accounts Switched ${connectedAccount}`);
    const container = document.getElementById('profileListMenu');


    if (user != null) {
        container.innerHTML = getProfileCardHTML(connectedAccount);    
    } 

    // console.log(`Users loaded ${userData.length}`);
    // console.log(user != null);
    for (let i = 0; i < userData.length; i++) {
        if (i != connectedAccount) {
            container.innerHTML += getProfileCardHTML(i);
            let newProfileCard = document.getElementById(`profileCard${i}`);

            (function(index) {
                // console.log(`Adding event listener to ${newProfileCard.id}`);
                newProfileCard.addEventListener('click', function() {
                    switchAccounts(index);
                });
                console.dir(newProfileCard)
            })(i);
            // newProfileCard.addEventListener('click', function() {
            //     switchAccounts(i);
            // });

            console.log(`Added ${i}`);

        }

    }

    updateScreen();

}

async function handleAccountsChanged(accounts) {

    profileMenu.style.display = 'none';
    connectedAccounts = accounts;

    const switchAccountEvent = new CustomEvent('switchAccount', {detail: connectedAccount});
    window.dispatchEvent(switchAccountEvent);

    userData = [];

    if (connectedAccounts.length > 0) {
        // Perform actions when connected
        isConnected = true;

        for (let i = 0; i < connectedAccounts.length; i++) {
            // test info
            const testUser = {
                registrationDate : 0,
                username : '',
                imageUrl : ''
            }
            
            userData.push(testUser);
            // console.log(`${i} , `)
            


        }

        switchAccounts(0);

    } else {

        console.log('Disconnected from MetaMask');
        // Perform actions when disconnected
        isConnected = false;
        switchAccounts(null);

    }



}

async function setChain() {

    if (!chainSupported(currentChain)) {
        // Switch to a different network
        try {
            await ethereum.request({
                method: 'wallet_switchEthereumChain',
                params: [{ chainId: DAPP_CHAIN[0] }], //0x89 MATIC //0xaa36a7 Sepolia
            });
            const switchResult = await ethereum.request({ method: 'eth_chainId' });
            if (switchResult == DAPP_CHAIN[0]) {
                console.log('Switched to the new network successfully');
            } else {
                console.error('Failed to switch the network');
            }
        } catch (switchError) {
            console.error('Error switching network:', switchError);
        }

    }
}

async function handleChainChanged(chainId) {
    // Handle the chain change event
    console.log('Network chain ID:', chainId);
    currentChain = chainId;

    if (!chainSupported(currentChain)) {
        networkErrorButton.style.display = 'inline-block';
        web3 = new Web3(new Web3.providers.HttpProvider(DEFAULT_RPC));
    } else {
        networkErrorButton.style.display = 'none';
        web3 = new Web3(ethereum);
    }
}

function updateScreen() {
    // profileListMenu.style.display = 'none';

    // Update the connected address
    if (isConnected) {
        connectButton.style.display = 'none';
        inboxButton.style.display = 'block';

        profileListMenu.style.display = 'flex';

        addressStart.textContent = '';
        addressEnd.textContent = addText;

    } else {
        profileListMenu.style.display = 'none';
        connectButton.style.display = 'flex';
        connectIcon.innerHTML = loginIcon;
        addressStart.textContent = '';
        addressEnd.textContent = loginText;
        inboxButton.style.display = 'none';
    }

    console.log(`isConnected: ${isConnected?connectedAccounts[connectedAccount]:isConnected}`);
    console.log(`isUser: ${isRegistered(connectedAccount) && userData[connectedAccount].username ? userData[connectedAccount].username : isRegistered(connectedAccount)}`);
    console.log(userData[connectedAccount]);
    
}

document.addEventListener('DOMContentLoaded', async function () {
    
    connectButton.addEventListener('click', function() {
        if (!isConnected) connectMetamask();
        else connectMetamask();
    });

    inboxButton.addEventListener('click', function() {
        profileMenu.style.display = 'none';
        inboxMenu.style.display = inboxMenu.style.display == 'flex' ? 'none' : 'flex';
    });

    profileButton.addEventListener('click', function() {
        inboxMenu.style.display = 'none';
        profileMenu.style.display = profileMenu.style.display == 'flex' ? 'none' : 'flex';
    });

    networkErrorButton.addEventListener('click', function() {
        setChain();
    });

    try {
        ethereum.on('accountsChanged', function (accounts) {
            handleAccountsChanged(accounts);
        });

        ethereum.on('chainChanged', (chainId) => {
            handleChainChanged(chainId);
        });
    } catch {
        console.error("no ethereum");
    }

    await loadMain();
    // main loop
});