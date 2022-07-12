const { expect } = require("chai")
const { ethers } = require("hardhat")
require("dotenv").config()

// Token addresses
const WETH = '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619'
const WMATIC = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270'

describe("DodoFlashloan", function () {

    let dodoFlashloan
    let account

    beforeEach(async () => {
        // Fetch & deploy contracts
        const Flashloan = await ethers.getContractFactory("Flashloan")
        dodoFlashloan = await Flashloan.deploy()

        // Fetch account
        const accounts = await ethers.getSigners()
        account = accounts[0]
    })

    describe("Basic Flashloan", () => {
        it('Borrows WETH from the Private Pool', async () => {
            // Define pool and amount
            const pool = '0x5333Eb1E32522F1893B7C9feA3c263807A02d561' // WETH/USDC
            const amount = ethers.utils.parseUnits('10', "ether")

            // Perform flashloan
            const transaction = await dodoFlashloan.connect(account).dodoFlashLoan(pool, amount, WETH)
            const result = await transaction.wait()

            // Decode the first transfer event emitted from the transaction
            const from = ethers.utils.defaultAbiCoder.decode(['address'], result.logs[0].topics[1])
            const to = ethers.utils.defaultAbiCoder.decode(['address'], result.logs[0].topics[2])
            const value = ethers.utils.defaultAbiCoder.decode(['uint'], result.events[0].data)

            expect(from[0]).to.equal(pool)
            expect(to[0]).to.equal(dodoFlashloan.address)
            expect(value[0]).to.equal(amount)
        })

        it('Borrows WMATIC from the Vending Machine Pool', async () => {
            // Define pool and amount
            const pool = '0x0F20C4148369fB70083593B1475922BEc87AEbe3' // WMATIC/USDC
            const amount = ethers.utils.parseUnits('10', "ether")

            // Perform flashloan
            const transaction = await dodoFlashloan.connect(account).dodoFlashLoan(pool, amount, WMATIC)
            const result = await transaction.wait()

            // Decode the first transfer event emitted from the transaction
            const from = ethers.utils.defaultAbiCoder.decode(['address'], result.logs[0].topics[1])
            const to = ethers.utils.defaultAbiCoder.decode(['address'], result.logs[0].topics[2])
            const value = ethers.utils.defaultAbiCoder.decode(['uint'], result.events[0].data)

            expect(from[0]).to.equal(pool)
            expect(to[0]).to.equal(dodoFlashloan.address)
            expect(value[0]).to.equal(amount)
        })
    })
});