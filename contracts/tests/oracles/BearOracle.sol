// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../interfaces/IVendorOracle.sol";

contract BearOracle is IVendorOracle {
    mapping(address => int256) prices;

    function setPrice(address token, int256 price) public {
        prices[token] = price;
    }

    function getPriceUSD(address base) external view returns (int256) {
        return prices[base];
    }
}

contract MockOracle is IVendorOracle {
    mapping(address => int256) prices;

    function setPrice(address token, int256 price) public {
        prices[token] = price;
    }

    function getPriceUSD(address base) external view returns (int256) {
        return -1;
    }
}
