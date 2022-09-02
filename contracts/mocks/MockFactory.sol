pragma solidity ^0.8.11;

interface IPoolFees {
    function setPoolFees(address _pool, uint256[] calldata _feeRates) external;
}

contract MockFactory {
    mapping(address => bool) public pools;
    address public poolFeesContract;

    function setPoolFeesContract(address _poolFeesContract) external {
        poolFeesContract = _poolFeesContract;
    }

    function setPool(address _pool) external {
        pools[_pool] = true;
    }

    function setPoolFees(address _pool, uint256[] calldata _feeRates) external {
        IPoolFees(poolFeesContract).setPoolFees(_pool, _feeRates);
    }
}
