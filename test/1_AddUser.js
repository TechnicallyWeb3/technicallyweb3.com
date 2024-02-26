const { expect } = require("chai");
const hre = require("hardhat");

describe("Basic Tests", function () {

    let userControl;
    let tx;

    before(async () => {
        console.log("loading accounts");
        accounts = await ethers.getSigners();
        console.log(`${accounts.length} accounts loaded`);

        owner = accounts[0];

        console.log(`owner ${owner.address}`);

        const UserControl = await ethers.getContractFactory("UserControl");

        console.log("deploying UserControl");
        userControl = await UserControl.deploy();
        await userControl.waitForDeployment();
        console.log("deployed UserControl");
    });

    it("Add and read user data", async function () {
        tx = await userControl.setUserData([
            0,
            '0x0000000000000000000000000000000000000000',
            'technicallyweb3',
            'Hello World!',
            '/assets/images/logo.png',
            [
                [8,'@technicallyweb3','0x0000000000000000000000000000000000000000']
            ]

        ]);
        await tx.wait();

        tx = await userControl['isUser(string)']('technicallyweb3');
        console.log(`technicallyweb3 isUser ${tx}`);

        tx = await userControl['getUserData(string)']('technicallyweb3');
        console.log(tx);

        tx = await userControl['isUser(address)'](owner);
        console.log(`owner isUser ${tx}`);

        tx = await userControl['getUserData(address)'](owner);
        console.log(tx);

    });

});
