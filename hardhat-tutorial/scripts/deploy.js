const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS  } = require("../constants");


async function main() {

  const CryptoDevsTokenContract = CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS;

  const exchangeContract = await ethers.getContractFactory("Exchange");

  const deployedExchangeContract = await exchangeContract.deploy(
    CryptoDevsTokenContract
  );

  await deployedExchangeContract.deployed();

  console.log("The exchange contract is deployed on %s", deployedExchangeContract.address);

}

main()
  .then(() => process.exit(0)) 
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });

  //The whitelist contract is deployed on 0x18b7FA42Ff583bfBe9A463D48406af21372dE4ad