const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("deploying contract with account:", deployer.address);
    const balance = await deployer.getBalance().toString();
    console.log("Account balance: ", balance);
    const Token = await ethers.getContractFactory("FlashSwap");
    const token = await Token.deploy();
    console.log("Token Address: ", token.address);
}

main().then(() => process.exit(0)).catch((error) => {
  console.log(error);
  process.exit(1);
})