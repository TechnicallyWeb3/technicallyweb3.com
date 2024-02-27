const hre = require("hardhat");

let userControl;

async function deploy() {

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
    console.log(`waiting for deployment of UserControl ${userControl.target}`);
    await userControl.waitForDeployment();
    console.log(`deployed UserControl ${userControl.target}`);

    tx = await userControl.setUserData([
        0,
        '0x0000000000000000000000000000000000000000',
        'technicallydev',
        'Hello World!',
        '/assets/images/logo.png',
        [
            [8,'@technicallyweb3','0x0000000000000000000000000000000000000000']
        ]

    ]);
    await tx.wait();

    tx = await userControl['isUser(string)']('technicallydev');
    console.log(`technicallydev isUser ${tx}`);

}

const result = deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

console.log(result);
