import localhostContractAddresses from './localhost-contract-addresses';
import ContractAddresses from "./ContractAddresses";
import {HardhatRuntimeEnvironment} from "hardhat/types";
import {BaseContract} from "ethers";


export default class ContractInfo {


    public static getContractInfo(networkName?: string): ContractAddresses {
        let contractInfos: any = {
            localhostContractAddresses
        };
        if (networkName == 'hardhat') networkName = 'localhost';

        const contractInfoType = contractInfos[networkName + 'ContractAddresses'];
        return new contractInfoType();
    }

    public static async getContract<T extends BaseContract>(hre : HardhatRuntimeEnvironment, contractName : string, address: string) {
        const Contract = await hre.ethers.getContractFactory(contractName);
        return Contract.attach(address) as T;
    }


}
