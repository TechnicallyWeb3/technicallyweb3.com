const { expect } = require("chai");
const hre = require("hardhat");

describe("Basic Tests", function () {

    let userControl;
    let tx;
    let accounts;

    before(async () => {
        console.log("loading accounts");
        accounts = await ethers.getSigners();
        console.log(`${accounts.length} accounts loaded`);

        owner = accounts[0];

        console.log(`owner ${owner.address}`);

        const UserControl = await ethers.getContractFactory("UserControl");

        console.log("deploying UserControl");
        userControl = await UserControl.deploy([
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22,
            23,
            24,
            25
        ],[
            'twitter',
            'instagram',
            'linkedin',
            'tiktok',
            'youtube',
            'github',
            'reddit',
            'discord',
            'telegram',
            'snapchat',
            'twitch',
            'mastodon',
            'patreon',
            'quora',
            'pintrest',
            'tumblr',
            'slack',
            'stackoverflow',
            'soundcloud',
            'spotify',
            'upwork',
            'kickstarter',
            'email',
            'website',
            'web3address'        
        ]);
        await userControl.waitForDeployment();
        console.log("deployed UserControl");
    });

    it("Add and read user data", async function () {

        tx = await userControl.setUserData([
            false,
            0,
            '0x0000000000000000000000000000000000000000',
            'TechnicallyWeb',
            'Hello World!',
            '/assets/images/logo.png',
            [
                [4,'@technicallyweb3','0x0000000000000000000000000000000000000000']
            ]

        ]);
        await tx.wait();

        tx = await userControl['getUserDataFromName(string)']('TechnicallyWEb');
        console.log(tx);

        tx = await userControl.connect(accounts[0])['getUserDataFromAddress(address)'](accounts[0]);
        console.log(tx);

        // tx = await userControl['testIncludes(string)']('<TechnicallyWEb"`<@');
        // await tx.wait();

        // tx = await userControl['someBool()']();
        // console.log(tx);

        // tx = await userControl['isUserFromAddress(address)'](owner);
        // console.log(`owner isUser ${tx}`);

        // tx = await userControl['getUserDataFromAddress(address)'](owner);
        // console.log(tx);

        // tx = await userControl['getUserCount()']();
        // console.log(tx);

        // tx = await userControl['getUserList(uint256,uint256)'](0,0);
        // console.log(tx);

    });

    it("Add additional users", async function () {

        for (let i = 0; i < 10; i++) {
            privacy = i % 2 == 0 ? true : false;
            tx = await userControl.connect(accounts[i]).setUserData([
                privacy,
                0,
                '0x0000000000000000000000000000000000000000',
                `TechnicallyWeb${i}`,
                'Hello World!',
                '/assets/images/logo.png',
                [
                    [4,'@technicallyweb3','0x0000000000000000000000000000000000000000']
                ]
    
            ]);
            await tx.wait();
            console.log
        }

        tx = await userControl['getUserList(uint256,uint256)'](0,19);
        console.log(tx);

        tx = await userControl.connect(accounts[1])['getListData(uint256,uint256)'](0,19);
        console.log(tx);

        
    });

});
