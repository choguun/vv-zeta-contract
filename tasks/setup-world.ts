import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  const [signer] = await hre.ethers.getSigners();
  console.log(`🔑 Using account: ${signer.address}\n`);

  /*
    Profile:0x464baD40aAdB6A46038250ab6E7854895040d5b5 World:0xf778a16B7d27448e875C4330cf75abE6E2A1b678 Token:0xaaD8c8f1CD8432f870972fcec109B3beFF2Af0E6 Vault:0x044b20F8a1Bd0e0862aa94a0836898bf09a84c34 Craft:0x28be7AF55E21BbD21Bea65537Fc7535450e10f3B Item:0xBe20C660f29664C138819c9DB3B235490A8af6Ec Potion:0x93288d1e46C2FE7515E6F532E86C1e3Ac982F9f9
  */

  const factory = await hre.ethers.getContractFactory("World");
  const contract = factory.attach('0xf778a16B7d27448e875C4330cf75abE6E2A1b678');

  const item = "0xBe20C660f29664C138819c9DB3B235490A8af6Ec";
  const token = "0xaaD8c8f1CD8432f870972fcec109B3beFF2Af0E6";
  const profile = "0x464baD40aAdB6A46038250ab6E7854895040d5b5";
  const craft = "0x28be7AF55E21BbD21Bea65537Fc7535450e10f3B";
  const vault = "0x044b20F8a1Bd0e0862aa94a0836898bf09a84c34";
  const potion = "0x93288d1e46C2FE7515E6F532E86C1e3Ac982F9f9";

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

  const tx7 = await contract.setPotion(potion);
  const receipt7 = await tx7.wait();
  console.log(receipt7);

  console.log('======================== DONE ========================');
};

task("setup", "setup world", main);
