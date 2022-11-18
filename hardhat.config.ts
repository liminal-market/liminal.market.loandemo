import {HardhatUserConfig, task} from "hardhat/config";
import Release from "./scripts/deployment/Release";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';


task('release', '', async (task, hre) => {
  await hre.run('compile');
  let release = new Release(hre);
  await release.Execute();
})

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  paths: {
    sources: './contracts/',
    tests: './test/contracts/'
  },
};



export default config;
