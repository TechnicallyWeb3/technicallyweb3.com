async function updateUser() {
    username = usernameInput.value;
    userbio = userbioInput.value;
    userimg = userimgInput.value;

    userObject = [
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
        profileAddressStart.textContent = connectedAddress.slice(-6);
    }

    updateUserButton.addEventListener('click', async function() {
        await updateUser();
        updatePage();
    });



});