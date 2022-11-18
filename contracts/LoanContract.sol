//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.16;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "hardhat/console.sol";

import "./USDS.sol";
import "./PriceFeedContracts.sol";

interface StakingPool {
    struct StakingInfo {
        address service;
        uint quantity;
        Status status;
    }
    enum Status { STAKED, MARGIN_CALL, RELEASE}

    function stake(address wallet, string memory symbol, uint quantity) external;
    function unstake(address wallet, string memory symbol, uint quantity) external;
    function liquidate(address wallet) external;

    function getStakingInfo(address wallet, string memory symbol) external view returns (StakingInfo memory);
    function getSymbols(address wallet) external view returns (string[] memory);
}

contract LoanContract is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    USDS public usds;
    StakingPool public stakingPool;
    PriceFeedContracts public priceFeeds;
    uint internal marginPercentage;
    mapping(address => uint) loan;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() external initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        marginPercentage = 130;
    }

    function setAddresses(USDS usdsAddress, StakingPool stakingPoolAddress, PriceFeedContracts priceFeedsAddress) public {
        usds = usdsAddress;
        stakingPool = stakingPoolAddress;
        priceFeeds = priceFeedsAddress;
    }

    function stake(string memory symbol, uint quantity) public {
        console.log("staking pool address:", address(stakingPool));

        stakingPool.stake(msg.sender, symbol, quantity);
    }

    function unstake(string memory symbol, uint quantity) public {
        stakingPool.unstake(msg.sender, symbol, quantity);
    }

    function mint(uint amount) public returns (bool) {
        uint totalValue = getTotalValueStaked(msg.sender);
        if (!isWithinMargin(amount, totalValue)) {
            console.log("Not withing margin - amount", amount);
            console.log("totalValue:", totalValue);
            return false;
        }
        usds.mint(msg.sender, amount);
        loan[msg.sender] += amount;
        return true;
    }

    function burn(uint amount) public {
        usds.burn(msg.sender, amount);
        loan[msg.sender] -= amount;
    }

    function isWithinMargin(uint amount, uint totalValue) pure private returns (bool) {
        return (amount < totalValue);
    }

    function liquidate(address wallet) public {
        uint balance = usds.balanceOf(wallet);
        uint totalValue = getTotalValueStaked(msg.sender);
        if (balance > totalValue) {
            stakingPool.liquidate(wallet);
        }
    }

    function getLoan(address wallet) public view returns (uint) {
        return loan[wallet];
    }

    function getStakingInfo(address wallet, string memory symbol) public view returns (StakingPool.StakingInfo memory){
        return stakingPool.getStakingInfo(wallet, symbol);
    }

    function getTotalValueStaked(address wallet) private view returns (uint) {
        string[] memory symbols = stakingPool.getSymbols(wallet);
        uint totalValue = 0;

        for (uint i=0;i<symbols.length;i++) {
            StakingPool.StakingInfo memory stakingInfo = stakingPool.getStakingInfo(wallet, symbols[i]);
            if (stakingInfo.service == address(this)) {
                uint price = priceFeeds.getLatestPrice(symbols[i]);
                totalValue += stakingInfo.quantity * price;
            }
        }
        return totalValue;
    }


    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal onlyRole(UPGRADER_ROLE) onlyProxy override {
        _upgradeTo(newImplementation);
    }
}
