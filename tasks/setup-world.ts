import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  const [signer] = await hre.ethers.getSigners();
  console.log(`🔑 Using account: ${signer.address}\n`);


  const factory = await hre.ethers.getContractFactory("World");
  const contract = factory.attach('0xE84e47891B28f8a29ab2f1aAAF047A361852620F');

  const item = "0x93129A93974b4EbE7F11C457b47bAF1b8BBD7C64";
  const token = "0xA3D093821e81eddaF43a6091EC308831dE9bf056";
  const profile = "0x47A9D4613b93B3aF955C918E1379A61B7b5392B9";
  const craft = "0xC987c9A034227C40D35E6BebaF0f9391531D2BAC";
  const vault = "0xAF98CEB505c16dD4d7d0404104d02A5A17f7a774";

  const tx1 = await contract.setProfile(profile);
  const receipt1 = await tx1.wait();
  console.log(receipt1);

  const tx2 = await contract.setToken(token);
  const receipt2 = await tx2.wait();
  console.log(receipt2);

  const tx3 = await contract.setItem(item);
  const receipt3 = await tx3.wait();
  console.log(receipt3);

  const tx4 = await contract.setCraft(craft);
  const receipt4 = await tx4.wait();
  console.log(receipt4);

  const tx5 = await contract.setVault(vault);
  const receipt5 = await tx5.wait();
  console.log(receipt5);

  const CraftContract = await hre.ethers.getContractFactory("CraftSystem");
  const deployedCraftContract = await CraftContract.attach(craft);

  const tx6 = await deployedCraftContract.setItem(item);
  const receipt6 = await tx6.wait();
  console.log(receipt6);

  console.log('======================== DONE ========================');
};

task("setup", "setup world", main);
