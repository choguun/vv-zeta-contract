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

  const owner = await signer.getAddress();

  const factory2 = await hre.ethers.getContractFactory("Profile");

  const contract2 = await factory2.deploy(
    `${systemContract}`
  );
  await contract2.deployed();

  const factory3 = await hre.ethers.getContractFactory("World");
  const contract3 = await factory3.deploy(
    owner // owner
  );
  await contract3.deployed();

  const factory4 = await hre.ethers.getContractFactory("Token");
 
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

  const factory8 = await hre.ethers.getContractFactory("Potion");
  const contract8 = await factory8.deploy(
    `${contract3.address}`,
    `${contract6.address}`,
    ""
  );
  await contract8.deployed();

  const factory9 = await hre.ethers.getContractFactory("SwapToAnyToken");
  const contract9 = await factory9.deploy(
    `${systemContract}`
  );
  await contract9.deployed();

  const factory10 = await hre.ethers.getContractFactory("Item2");
  const contract10 = await factory10.deploy(
    `${contract3.address}`,
    `${contract2.address}`,
    "",
    `${systemContract}`
  );
  await contract10.deployed();

  console.log(`Profile:${contract2.address} World:${contract3.address} Token:${contract4.address} Vault:${contract5.address} Craft:${contract6.address} Item:${contract7.address} Potion:${contract8.address} SwapAnytoken:${contract9.address} Item2:${contract10.address}`);
};

task("deploy", "Deploy the contract", main)
  .addParam("chain", "Chain ID (use btc_testnet for Bitcoin Testnet)")
  .addFlag("json", "Output in JSON");
