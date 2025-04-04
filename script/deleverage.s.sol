// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./common/EScript.s.sol";
import {SonicLib} from "./common/SonicLib.sol";

contract DeleverageScript is EScript {
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
        logPositionInfo(COLLATERAL_VAULT, HEDGED_VAULT, LIABILITY_VAULT);
        uint256 deleverage_amount = assetsBalance(HEDGED_VAULT) / 4;

        (string memory swapJson, string memory verifyJson) = getRoutingData(
            HEDGED_VAULT, LIABILITY_VAULT, HEDGED_TOKEN, LIABILITY_TOKEN, deleverage_amount
        );

        broadcastBatch(batchSwapAndRepay(
            HEDGED_VAULT, LIABILITY_VAULT, deleverage_amount, swapJson, verifyJson)
        );

        logPositionInfo(COLLATERAL_VAULT, HEDGED_VAULT, LIABILITY_VAULT);
        
    }
}