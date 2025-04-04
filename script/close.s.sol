// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./common/EScript.s.sol";
import {SonicLib} from "./common/SonicLib.sol";

contract CloseScript is EScript {
    function run() public {
        borrower = msg.sender;
        e_account = getSubaccount(borrower, 2);
        evc = IEVC(SonicLib.EVC);

        address LIABILITY_VAULT = SonicLib.EULER_WS_VAULT;
        address HEDGED_VAULT = SonicLib.EULER_PT_STS_VAULT;
        address COLLATERAL_VAULT = SonicLib.EULER_USDC_VAULT;
        address LIABILITY_TOKEN = SonicLib.WS;
        address HEDGED_TOKEN = SonicLib.PT_STS;
        address COLLATERAL_TOKEN = SonicLib.USDC;

        uint256 hedged_balance = assetsBalance(HEDGED_VAULT);
        (string memory swapJson, string memory verifyJson) = getRoutingData(
            HEDGED_VAULT, LIABILITY_VAULT, HEDGED_TOKEN, LIABILITY_TOKEN, hedged_balance
        );

        broadcastBatch(batchSwapAndRepay(
            HEDGED_VAULT, LIABILITY_VAULT, hedged_balance,
            swapJson, verifyJson
        ));
        logPositionInfo(COLLATERAL_VAULT, HEDGED_VAULT, LIABILITY_VAULT);

        uint256 collateral_balance = assetsBalance(COLLATERAL_VAULT);
        uint256 liability_balance = assetsBalance(LIABILITY_VAULT);

        (swapJson, verifyJson) = getRoutingData(
            LIABILITY_VAULT, COLLATERAL_VAULT, LIABILITY_TOKEN, COLLATERAL_TOKEN, liability_balance
        );

        broadcastBatch(batchWithdrawAndSwap(
            LIABILITY_VAULT, liability_balance,
            swapJson, verifyJson)
        );
        logPositionInfo(COLLATERAL_VAULT, HEDGED_VAULT, LIABILITY_VAULT);
        console.log("COLLATERAL PROFIT: ", assetsBalance(COLLATERAL_VAULT) - collateral_balance);
    }
}