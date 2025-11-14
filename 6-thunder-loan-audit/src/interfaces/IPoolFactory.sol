// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;


//e this is probably interface to work with poolfactory
// qanswered why we are using tswap
//a we needed to get the value of token to  calculate the fees
interface IPoolFactory {
    function getPool(address tokenAddress) external view returns (address);
}
// ✅