// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;


//e this is probably interface to work with poolfactory
//q why we are using tswap
interface IPoolFactory {
    function getPool(address tokenAddress) external view returns (address);
}
// ✅