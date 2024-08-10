import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  const [signer] = await hre.ethers.getSigners();
  console.log(`🔑 Using account: ${signer.address}\n`);


  const factory = await hre.ethers.getContractFactory("World");
  const contract = factory.attach('0xE84e47891B28f8a29ab2f1aAAF047A361852620F');

  const tx1 = await contract.createItem(0, "PICKAXE", "PICKAXE", 100);
    const receipt1 = await tx1.wait();
  
    console.log('Transaction receipt1: ', receipt1);

    const tx2 = await contract.createItem(1, "METAL PICKAXE", "METAL PICKAXE", 250);
    const receipt2 = await tx2.wait();
  
    console.log('Transaction receipt2: ', receipt2);

    const tx3 = await contract.createItem(2, "GOLDEN PICKAXE", "GOLDEN PICKAXE", 600);
    const receipt3 = await tx3.wait();
  
    console.log('Transaction receipt2: ', receipt3);
  
    console.log('======================== DONE ========================');
};

task("item", "add item", main);
