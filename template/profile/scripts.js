async function updateUser() {
    username = usernameInput.value;
    userbio = userbioInput.value;
    userimg = userimgInput.value;

    userObject = [
        userindexInput.checked,
        0,
        connectedAddress,
        username,
        userbio,
        userimg,
        []
    ]
    console.log(userContract);
    userContract.methods.updateUser(userObject).send({ from: connectedAddress });
    updateUserData();
}



document.addEventListener('DOMContentLoaded', async function () {
    
    function updatePage() {
        profileAddressStart.textContent = connectedAddress.slice(0, -6);
        profileAddressEnd.textContent = connectedAddress.slice(-6);
        if (userData[connectedAccount]) {
            console.log(userData[connectedAccount])
            
            usernameInput.value = userData[connectedAccount].userName;
            userbioInput.value = userData[connectedAccount].userBio;
            userimgInput.value = userData[connectedAccount].imgUrl;
            userindexInput.checked = userData[connectedAccount].indexUser;
        }
        
    }

    updateUserButton.addEventListener('click', async function() {
        await updateUser();
        updatePage();
    });

    window.addEventListener('userDataLoaded', function(data) {
        updatePage();
    });

});