import "./tasks/deploy";
import "./tasks/setup-world";
import "./tasks/add-quest";
import "./tasks/add-recipe";
import "./tasks/add-gameitem";
import "./tasks/check-player";
import "@nomicfoundation/hardhat-toolbox";
import "@zetachain/toolkit/tasks";

import { getHardhatConfigNetworks } from "@zetachain/networks";
import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  networks: {
    ...getHardhatConfigNetworks(),
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999,
      },
    },
  },
};

export default config;
