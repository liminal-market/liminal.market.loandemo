import {HardhatRuntimeEnvironment} from "hardhat/types";
import {BaseContract, Contract, ContractFactory, Signer} from "ethers";
import {FakeContract} from "@defi-wonderland/smock";
import {LoanContract, PriceFeedContracts, USDS} from "../../typechain-types";

export default class Deployment {

    hre: HardhatRuntimeEnvironment;
    contractFactory?: ContractFactory;
    static Deployed = 'deployed';
    static Upgraded = 'upgraded';

    constructor(hre: HardhatRuntimeEnvironment) {
        this.hre = hre;

    }

    public async deployOrUpgradeContract(contractName: string,
                                         preexistingAddress: string): Promise<[Contract, string]> {

console.log(contractName);
        this.contractFactory = await this.hre.ethers.getContractFactory(contractName);

        console.log('deployment for contractName:' + contractName + ' | preexistingAddress:' + preexistingAddress);
        if (this.hre.network.name == 'hardhat') {
            //throw new Error("Should not deploy on hardhat. Did you forget to set --network localhost?")
        }

        let contract;
        let status = Deployment.Deployed;

        let upgrade = (preexistingAddress == "") ? false : await this.contractExistsOnChain(contractName, preexistingAddress);
        console.log('upgrade:', upgrade);

        if (upgrade) {
            contract = await this.hre.upgrades.upgradeProxy(preexistingAddress, this.contractFactory, {timeout: 0});
            status = Deployment.Upgraded;
        } else {
            contract = await this.hre.upgrades.deployProxy(this.contractFactory, undefined, {timeout: 0});
        }

        await contract.deployed();
        console.log(contractName + " " + status + ":", contract.address);
        if (status == Deployment.Upgraded && contract.address != preexistingAddress) {
            throw new Error("Upgraded contract doesn't have same address. This is BAD!!! preexistingAddress:" + preexistingAddress + " | new address:" + contract.address)
        }

        return [contract, status];
    }

    public async contractExistsOnChain(contractName: string, address: string): Promise<boolean> {

        let contract = await this.contractFactory?.attach(address) as BaseContract // ContractInfo.getContract(this.hre, contractName, address);
        if (!contract) return false;
        try {
            await contract.deployed();
            return true;
        } catch (e: any) {
            if (e.toString().indexOf('contract not deployed') != -1) {
                return false;
            }
            throw e;
        }
    }

    public async setAddresses(usds : USDS, priceFeed : PriceFeedContracts, loanContract : LoanContract) {
        await loanContract.setAddresses(usds.address, '0x9B946889657e8f2D943A3841282fBf5751241E85', priceFeed.address);
        await usds.grantRole(await usds.MINTER_ROLE(), loanContract.address);
    }



}