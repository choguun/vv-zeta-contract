import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {
  const [signer] = await hre.ethers.getSigners();
  console.log(`🔑 Using account: ${signer.address}\n`);


  const factory = await hre.ethers.getContractFactory("World");
  const contract = factory.attach('0x0673F20FAB85Fd5d7a392436086c51038a483712');

  const tx1 = await contract.createQuest("dailyCheckIn", "Daily Check In", 250, 0);
  const receipt1 = await tx1.wait();

  console.log('dailyCheckIn receipt1: ', receipt1);

  // 2. daily play mini game
  const tx2 = await contract.createQuest("miniGame", "Play mini game", 500, 1);
  const receipt2 = await tx2.wait();

  console.log('miniGame receipt2: ', receipt2);

  // 3. daily do craft item
  const tx3 = await contract.createQuest("doCraft", "Do Craft", 300, 2);
  const receipt3 = await tx3.wait();

  console.log('doCraft receipt3: ', receipt3);

  console.log('======================== DONE ========================');
};

task("quest", "add quest", main);
