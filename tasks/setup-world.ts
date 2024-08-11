import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  const [signer] = await hre.ethers.getSigners();
  console.log(`🔑 Using account: ${signer.address}\n`);

  /*
    Profile:0xa3D6F8f0455250d3679C5A9d418Fb190c8FBA6e5 World:0x0673F20FAB85Fd5d7a392436086c51038a483712 Token:0x026e6C5d10fB2655f39a5B367C2Ff80af9215AC5 Vault:0x6F1C92FB8c0ebed02C0be7018B7EFCA5414f0326 Craft:0x9b989635a70C17f487617F779d3f6F324978B0cF Item:0x4Aab7FeA44E174Da739C3A4c53e6554A1018b1d3 
  */

  const factory = await hre.ethers.getContractFactory("World");
  const contract = factory.attach('0x0673F20FAB85Fd5d7a392436086c51038a483712');

  const item = "0x4Aab7FeA44E174Da739C3A4c53e6554A1018b1d3";
  const token = "0x026e6C5d10fB2655f39a5B367C2Ff80af9215AC5";
  const profile = "0xa3D6F8f0455250d3679C5A9d418Fb190c8FBA6e5";
  const craft = "0x9b989635a70C17f487617F779d3f6F324978B0cF";
  const vault = "0x6F1C92FB8c0ebed02C0be7018B7EFCA5414f0326";

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
