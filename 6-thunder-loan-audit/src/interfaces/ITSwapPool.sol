// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;


//qanswerd why are we using only price of pool token in weth?
//a we shoulent be! This is a bug? 
interface ITSwapPool {
    function getPriceOfOnePoolTokenInWeth() external view returns (uint256);
}
