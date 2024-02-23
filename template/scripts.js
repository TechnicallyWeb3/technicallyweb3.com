const CHAIN_SYMBOL = 'S.ETH';
const DAPP_CHAIN = '0xaa36a7';

let currentChain;

let isConnected = false;
let connectedAddress;

const defaultUser = {
    registrationDate: 0, // uint64 minimum for timestamps
    username: '',
    imageUrl: '',
};

let userData = {...defaultUser};

const isRegistered = ((user) => {
    return userData.registrationDate > 0;
});

const idIcon = '<path d="M528 160V416c0 8.8-7.2 16-16 16H320c0-44.2-35.8-80-80-80H176c-44.2 0-80 35.8-80 80H64c-8.8 0-16-7.2-16-16V160H528zM64 32C28.7 32 0 60.7 0 96V416c0 35.3 28.7 64 64 64H512c35.3 0 64-28.7 64-64V96c0-35.3-28.7-64-64-64H64zM272 256a64 64 0 1 0 -128 0 64 64 0 1 0 128 0zm104-48c-13.3 0-24 10.7-24 24s10.7 24 24 24h80c13.3 0 24-10.7 24-24s-10.7-24-24-24H376zm0 96c-13.3 0-24 10.7-24 24s10.7 24 24 24h80c13.3 0 24-10.7 24-24s-10.7-24-24-24H376z"/>';
const loginIcon = '<path d="M217.9 105.9L340.7 228.7c7.2 7.2 11.3 17.1 11.3 27.3s-4.1 20.1-11.3 27.3L217.9 406.1c-6.4 6.4-15 9.9-24 9.9c-18.7 0-33.9-15.2-33.9-33.9l0-62.1L32 320c-17.7 0-32-14.3-32-32l0-64c0-17.7 14.3-32 32-32l128 0 0-62.1c0-18.7 15.2-33.9 33.9-33.9c9 0 17.6 3.6 24 9.9zM352 416l64 0c17.7 0 32-14.3 32-32l0-256c0-17.7-14.3-32-32-32l-64 0c-17.7 0-32-14.3-32-32s14.3-32 32-32l64 0c53 0 96 43 96 96l0 256c0 53-43 96-96 96l-64 0c-17.7 0-32-14.3-32-32s14.3-32 32-32z"/>';
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
        window.isConnected = isConnected;

    }

    async function setChain() {

        if (currentChain != DAPP_CHAIN) {
            // Switch to a different network
            try {
                await ethereum.request({
                    method: 'wallet_switchEthereumChain',
                    params: [{ chainId: DAPP_CHAIN }], //0x89 MATIC //0xaa36a7 Sepolia
                });
                const switchResult = await ethereum.request({ method: 'eth_chainId' });
                if (switchResult == DAPP_CHAIN) {
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

        if (chainId != DAPP_CHAIN) {
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
            connectIcon.innerHTML = idIcon;

            // test info
            userData.registrationDate = 1;
            userData.username = 'TechnicallyWeb3';

            if (isRegistered() && userData.username) {
                addressStart.textContent = userData.username;
                addressEnd.textContent = ''; 
            } else {
                addressStart.textContent = connectedAddress.slice(0, -6);
                addressEnd.textContent = connectedAddress.slice(-6);
            }

        } else {
            connectIcon.innerHTML = loginIcon;
            addressStart.textContent = '';
            addressEnd.textContent = loginText;
            userData = {...defaultUser};
        }

        console.log(`isConnected: ${isConnected?connectedAddress:isConnected}`);
        console.log(`isUser: ${isRegistered() && userData.username ? userData.username : isRegistered()}`);
        
    }
    
    connectButton.addEventListener('click', function() {
        console.log("Connect button pressed");
        if (!isConnected) connectMetamask();
        else window.location = '/profile/';
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
        console.log("no ethereum")
    }

    // main loop
    checkMetamask();
});