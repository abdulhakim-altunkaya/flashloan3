
const hre = require("hardhat");

async function main() {


  const flashswap = await hre.ethers.deployContract("Lock", [], {});

  await flashswap.waitForDeployment();

  console.log(`flashswap deployed to ${flashswap.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
