// SPDX-License-Identifier: No License
/**
 * @title Vendor Factory Contract
 * @author JeffX
 * The legend says that you'r pipi shrinks and boobs get saggy if you fork this contract.
 */
pragma solidity ^0.8.11;

import "../interfaces/IPoolFactory.sol";
import "../interfaces/ILendingPool.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract FeesManagerV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    event ChangeFee(address _pool, uint48 _feeRate, uint256 _type);

    /// @notice Error for if address is not a pool
    error NotAPool();
    /// @notice Error for if pool is closed
    error PoolClosed();
    /// @notice Error for if address is not the pool factory or the pool address that is being modified
    error NotPoolFactoryOrPoolItself();
    /// @notice Error for if array length is invalid
    error InvalidType();

    /// @notice Pool Factory
    IPoolFactory public factory;
    /// @notice If an address has constant fee or linear decaying fee
    mapping(address => uint256) public rateFunction; // 1 for constant, 2 annualized
    /// @notice A pool address to its starting fee and floor fee, if decaying fee
    mapping(address => uint48) public feeRates;

    uint48 private constant SECONDS_IN_YEAR = 31536000;

    /// @notice          Sets the address of the factory
    /// @param _factory  Address of the Vendor Pool Factory
    function initialize(IPoolFactory _factory) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        factory = _factory;
    }

    /// @notice           During deployment of pool sets fee details
    /// @param _pool      Address of pool
    /// @param _feeRate  Rate value
    /// @param _type     Type of the fee: 1 for constant, 2 annualized
    function setPoolFees(
        address _pool,
        uint48 _feeRate,
        uint256 _type
    ) external {
        if (_type < 1 || _type > 2) revert InvalidType();
        if (rateFunction[_pool] != 0 && rateFunction[_pool] != _type)
            revert InvalidType();
        if (msg.sender == address(factory) || _pool == msg.sender) {
            feeRates[_pool] = _feeRate;
            rateFunction[_pool] = _type;
            emit ChangeFee(_pool, _feeRate, _type);
        } else {
            revert NotPoolFactoryOrPoolItself();
        }
    }

    /// @notice                  Returns the fee for a pool for a given amount
    /// @param _pool             Address of pool
    /// @param _rawPayoutAmount  Raw amount of payout tokens before fee
    function getFee(address _pool, uint256 _rawPayoutAmount)
        external
        view
        returns (uint256)
    {
        if (!factory.pools(_pool)) revert NotAPool();
        ILendingPool pool = ILendingPool(_pool);
        if (block.timestamp > pool.expiry()) revert PoolClosed();

        if (rateFunction[_pool] == 2) {
            return
                (_rawPayoutAmount * getCurrentRate(address(_pool))) / 1000000;
        }

        return (_rawPayoutAmount * feeRates[_pool]) / 1000000;
    }

    ///@notice get the fee rate in % of the given pool 1% = 10000
    ///@param _pool that we would like to get the rate of
    function getCurrentRate(address _pool) public view returns (uint48) {
        if (ILendingPool(_pool).expiry() <= block.timestamp) return 0;
        if (rateFunction[_pool] == 2) {
            return
                (feeRates[_pool] *
                    uint48((ILendingPool(_pool).expiry() - block.timestamp))) /
                SECONDS_IN_YEAR;
        }
        return feeRates[_pool];
    }

    function version() external pure returns (uint256) {
        return 2;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
