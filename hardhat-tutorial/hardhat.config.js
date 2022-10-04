require("@nomiclabs/hardhat-ethers");
require("dotenv").config({ path: ".env" });

const ALCHEMY_HTTP_URL = process.env.ALCHEMY_HTTP_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/JhrQahBzp44-3_fmZWkuR8omeNceljEw",
      accounts: [PRIVATE_KEY],
    },
  },

};

// The whitelist contract is deployed on 0x18b7FA42Ff583bfBe9A463D48406af21372dE4ad
// The NFT contract is deployed on 0xf457169a93d88f2ECF054EaAd253f8E8c0FA21c7
// The CryptoDevs contract is deployed on 0x38Ae84CC0e60dfaeF9fBBBa3Cc7A424B8a6B5C78
// The exchange contract is deployed on 0xc37C652A27446eaA5b6fF8903A549C6789f30522