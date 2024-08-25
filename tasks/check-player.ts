import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const main = async (args: any, hre: HardhatRuntimeEnvironment) => {

  const factory = await hre.ethers.getContractFactory("World");
  const contract = factory.attach('0x0673F20FAB85Fd5d7a392436086c51038a483712');

  const data = await contract.getPlayer('0x06d7a70c9b7771826Fd3FdaFb15bc627fA523c08');
  
  console.log(data);
};

task("player", "check player", main);
