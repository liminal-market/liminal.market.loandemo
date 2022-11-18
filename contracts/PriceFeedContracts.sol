// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceFeedContracts is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    mapping(string => address) public symbols;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
    }

    function initialize() initializer public {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        symbols["AAPL"] = 0x7E7B45b08F68EC69A99AAb12e42FcCB078e10094;
        symbols["AMZN"] = 0xf9184b8E5da48C19fA4E06f83f77742e748cca96;
        symbols["MSFT"] = 0xC43081d9EA6d1c53f1F0e525504d47Dd60de12da;
        symbols["SE"] = 0xcc73e00db7a6FD589a30BbE2E957086b8d7D3331;
        symbols["TSLA"] = 0x567E67f456c7453c583B6eFA6F18452cDee1F5a8;
    }

    function getSymbolAddress(string memory symbol) public view returns (address) {
        return symbols[symbol];
    }

    function addSymbolAddress(string memory symbol, address addr) onlyRole(DEFAULT_ADMIN_ROLE) public {
        symbols[symbol] = addr;
    }

    /**
    * Returns the latest price
    */
    function getLatestPrice(string memory symbol) public view returns (uint) {
        address priceFeedAddress = symbols[symbol];
        /*
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (,int price,,,) = priceFeed.latestRoundData();
        return uint(price);
        */
        if (keccak256(abi.encodePacked("AAPL")) == keccak256(abi.encodePacked(symbol))) {
            return 150770000000000000000;
        }

        return  23959000000000000000;
    }

    function _authorizeUpgrade(address newImplementation) internal onlyRole(UPGRADER_ROLE) override
    {
        _upgradeTo(newImplementation);
    }
}