import { getAddress } from "@zetachain/protocol-contracts";
import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import ZRC20 from "@zetachain/protocol-contracts/abi/zevm/ZRC20.sol/ZRC20.json";

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  if (hre.network.name !== "zeta_testnet") {
    throw new Error(
      '🚨 Please use the "zeta_testnet" network to deploy to ZetaChain.'
    );
  }

  const [signer] = await hre.ethers.getSigners();
  if (signer === undefined) {
    throw new Error(
      `Wallet not found. Please, run "npx hardhat account --save" or set PRIVATE_KEY env variable (for example, in a .env file)`
    );
  }

  const systemContract = getAddress("systemContract", "zeta_testnet");

  // const factory = await hre.ethers.getContractFactory("Staking");
  let symbol, chainID;
  if (args.chain === "btc_testnet") {
    symbol = "BTC";
    chainID = 18332;
  } else {
    const zrc20 = getAddress("zrc20", args.chain);
    const contract = new hre.ethers.Contract(zrc20, ZRC20.abi, signer);
    symbol = await contract.symbol();
    chainID = hre.config.networks[args.chain]?.chainId;
    if (chainID === undefined) {
      throw new Error(`🚨 Chain ${args.chain} not found in hardhat config.`);
    }
  }

  // const contract = await factory.deploy(
  //   `Staking rewards for ${symbol}`,
  //   `R${symbol.toUpperCase()}`,
  //   chainID,
  //   systemContract
  // );
  // await contract.deployed();

  const owner = await signer.getAddress();

  const factory2 = await hre.ethers.getContractFactory("Profile");
  /*
         address connectorAddress, // 0x3963341dad121c9CD33046089395D66eBF20Fb03
        address zetaTokenAddress, // 0x0000c304D2934c00Db1d51995b9f6996AffD17c0
        address zetaConsumerAddress, // 0x301ED39771d8f1dD0b05F8C2D4327ce9C426E783
        bool useEven
  */
  const contract2 = await factory2.deploy(
    `${systemContract}`
  );
  await contract2.deployed();

  const factory3 = await hre.ethers.getContractFactory("World");
  const contract3 = await factory3.deploy(
    owner // owner
  );
  await contract3.deployed();

  /*
      address _world, 
        address _profile,
        address connectorAddress,
        address zetaTokenAddress,
        address zetaConsumerAddress
  */

  const factory4 = await hre.ethers.getContractFactory("Token");
    /*    address connectorAddress, // 0x3963341dad121c9CD33046089395D66eBF20Fb03
        address zetaTokenAddress, // 0x0000c304D2934c00Db1d51995b9f6996AffD17c0
        address zetaConsumerAddress, // 0x301ED39771d8f1dD0b05F8C2D4327ce9C426E783
        bool useEven
  */
  const contract4 = await factory4.deploy(
    `${contract3.address}`,
    `${contract2.address}`,
    `${systemContract}`
  );
  await contract4.deployed();

  const factory5 = await hre.ethers.getContractFactory("ERC4626Vault");
  /*
       IERC20 asset, 
        uint256 chainID_,
        address systemContractAddress
  */
  const contract5 = await factory5.deploy(
    `${contract4.address}`,
    chainID,
    `${systemContract}`
  );
  await contract5.deployed();

  const factory6 = await hre.ethers.getContractFactory("CraftSystem");
  const contract6 = await factory6.deploy(
    owner,
    `${contract3.address}`
  );
  await contract6.deployed();


  /*
  address _world, address _craft, string memory _itemURI
  */
  const factory7 = await hre.ethers.getContractFactory("Item");
  const contract7 = await factory7.deploy(
    `${contract3.address}`,
    `${contract6.address}`,
    ""
  );
  await contract7.deployed();

  console.log(`Profile:${contract2.address} World:${contract3.address} Token:${contract4.address} Vault:${contract5.address} Craft:${contract6.address} Item:${contract7.address} `);

//   if (args.json) {
//     console.log(JSON.stringify(contract));
//   } else {
//     console.log(`🔑 Using account: ${signer.address}

// 🚀 Successfully deployed contract on ZetaChain.
// 📜 Contract address: ${contract.address}
// 🌍 Explorer: https://athens3.explorer.zetachain.com/address/${contract.address}
// `);
//   }
};

task("deploy", "Deploy the contract", main)
  .addParam("chain", "Chain ID (use btc_testnet for Bitcoin Testnet)")
  .addFlag("json", "Output in JSON");
