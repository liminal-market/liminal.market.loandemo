import ContractAddresses from "./ContractAddresses";

export default class localhostContractAddresses implements ContractAddresses {
    ChainId = "31337";
    NetworkName = "localhost";
    IsTestNetwork = true;

    LoanContract = "0x120baBBf81cBB9E6768B8356eEB073AB35e2Dc8e";
    PriceFeedContracts = "0x441447f40351076d2955e1074d1dF9AD6A51c201";
    USDS = "0x3A683816Ab5A8CA8a3c72B94E6386405F4304de2";

}