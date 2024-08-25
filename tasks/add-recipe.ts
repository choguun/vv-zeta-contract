import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  const [signer] = await hre.ethers.getSigners();
  console.log(`🔑 Using account: ${signer.address}\n`);


  const factory = await hre.ethers.getContractFactory("World");
  const contract = factory.attach('0xf778a16B7d27448e875C4330cf75abE6E2A1b678');

  const tx4 = await contract.addItems(0, 0);
  const receipt4 = await tx4.wait();
  console.log('Transaction receipt4: ', receipt4);

  const tx5 = await contract.addItems(1, 1);
  const receipt5 = await tx5.wait();
  console.log('Transaction receipt4: ', receipt5);

  const tx6 = await contract.addItems(2, 2);
  const receipt6 = await tx6.wait();
  console.log('Transaction receipt4: ', receipt6);

  // 2 PICKAXE = 1 METAL PICKAXE
  const tx1 = await contract.addRecipe([0], [2], 1);
  const receipt1 = await tx1.wait();

  console.log('Transaction receipt1: ', receipt1);

  // 2 METAL PICKAXE = 1 GOLDEN PICKAXE
  const tx2 = await contract.addRecipe([1], [2], 2);
  const receipt2 = await tx2.wait();

  console.log('Transaction receipt2: ', receipt2);

  console.log('======================== DONE ========================');
};

task("recipe", "add recipe", main);
