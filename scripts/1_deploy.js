async function main() {
    console.log(`Preparing deployment...\n`)

    // We get the contract to deploy
    const Flashloan = await ethers.getContractFactory("Flashloan")

    // Fetch accounts
    const accounts = await ethers.getSigners()
    console.log(`Accounts fetched:\n${accounts[0].address}\n`)

    console.log(`Deploying contract...\n`)

    const dodoFlashloan = await Flashloan.deploy()
    await dodoFlashloan.deployed()

    console.log(`DODO Flashloan Deployed to: ${dodoFlashloan.address}\n`)
    console.log(`-- View on Polyscan --`)
    console.log(`https://polygonscan.com/address/${dodoFlashloan.address}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });