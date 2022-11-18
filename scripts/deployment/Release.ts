import {HardhatRuntimeEnvironment} from "hardhat/types";
import Deployment from "./Deployment";
import {LoanContract, PriceFeedContracts, USDS} from "../../typechain-types";
import ContractInfo from "../addresses/ContractInfo";

export default class Release {
    hre: HardhatRuntimeEnvironment;

    constructor(hre: HardhatRuntimeEnvironment) {
        this.hre = hre;
    }

    public async Execute() {
        const contractInfo = ContractInfo.getContractInfo(this.hre.network.name);
        let deployment = new Deployment(this.hre);

        let [loanContract] = await deployment.deployOrUpgradeContract('LoanContract', contractInfo.LoanContract);
        let [PriceFeedContracts] = await deployment.deployOrUpgradeContract('PriceFeedContracts', contractInfo.PriceFeedContracts);
        let [usds] = await deployment.deployOrUpgradeContract('USDS', contractInfo.USDS);

        console.log('setAddresses');
        await deployment.setAddresses(usds as USDS, PriceFeedContracts as PriceFeedContracts, loanContract as LoanContract);

    }
}