const CHAIN_SYMBOL = 'S.ETH';
const DAPP_CHAIN = [
    '0xaa36a7',
    '0x89'
];

let currentChain;

let isConnected = false;
let connectedAddress;
let connectedAccounts = [];

const defaultUser = {
    registrationDate: 0, // uint64 minimum for timestamps
    username: '',
    imageUrl: '',
};

let userData = {...defaultUser};

const isRegistered = ((user) => {
    return userData.registrationDate > 0;
});

const chainSupported = ((chain) => {
    let i;
    for (i = 0; i < DAPP_CHAIN.length; i++) {
        if (chain == DAPP_CHAIN[i]) break;
    }
    console.log((i < DAPP_CHAIN.length));
    return (i < DAPP_CHAIN.length);
});

const addIcon = '<path d="M256 80c0-17.7-14.3-32-32-32s-32 14.3-32 32V224H48c-17.7 0-32 14.3-32 32s14.3 32 32 32H192V432c0 17.7 14.3 32 32 32s32-14.3 32-32V288H400c17.7 0 32-14.3 32-32s-14.3-32-32-32H256V80z"/>';
const loginIcon = '<path d="M217.9 105.9L340.7 228.7c7.2 7.2 11.3 17.1 11.3 27.3s-4.1 20.1-11.3 27.3L217.9 406.1c-6.4 6.4-15 9.9-24 9.9c-18.7 0-33.9-15.2-33.9-33.9l0-62.1L32 320c-17.7 0-32-14.3-32-32l0-64c0-17.7 14.3-32 32-32l128 0 0-62.1c0-18.7 15.2-33.9 33.9-33.9c9 0 17.6 3.6 24 9.9zM352 416l64 0c17.7 0 32-14.3 32-32l0-256c0-17.7-14.3-32-32-32l-64 0c-17.7 0-32-14.3-32-32s14.3-32 32-32l64 0c53 0 96 43 96 96l0 256c0 53-43 96-96 96l-64 0c-17.7 0-32-14.3-32-32s14.3-32 32-32z"/>';
const addText = 'Add Another Account';
const loginText = 'Login with MetaMask';
document.addEventListener('DOMContentLoaded', async function () {

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

    async function handleAccountsChanged(accounts) {

        profileMenu.style.display = 'none';
        connectedAccounts = accounts;

        if (accounts.length > 0) {

            // Get checksummed address
            connectedAddress = Web3.utils.toChecksumAddress(accounts[0]);

            // Perform actions when connected
            isConnected = true;

            const switchAccountEvent = new CustomEvent('switchAccount', {detail: connectedAddress});
            window.dispatchEvent(switchAccountEvent);

            updateScreen();

        } else {

            console.log('Disconnected from MetaMask');
            // Perform actions when disconnected
            isConnected = false;
            userData = {...defaultUser};

            updateScreen();
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
            web3 = new Web3(new Web3.providers.HttpProvider('https://ethereum-sepolia.publicnode.com'));
        } else {
            networkErrorButton.style.display = 'none';
            web3 = new Web3(ethereum);
        }
    }

    function updateScreen() {

        // Update the connected address
        if (isConnected) {
            connectIcon.innerHTML = addIcon;
            inboxButton.style.display = 'block';

            // test info
            userData.registrationDate = 1;
            userData.username = 'TechnicallyWeb3';


            addressStart.textContent = '';
            addressEnd.textContent = addText;

        } else {
            connectIcon.innerHTML = loginIcon;
            addressStart.textContent = '';
            addressEnd.textContent = loginText;
            userData = {...defaultUser};
            inboxButton.style.display = 'none';
        }

        console.log(`isConnected: ${isConnected?connectedAddress:isConnected}`);
        console.log(`isUser: ${isRegistered() && userData.username ? userData.username : isRegistered()}`);
        
    }
    
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

    // main loop
    checkMetamask();
});