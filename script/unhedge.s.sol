// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./common/EScript.s.sol";
import {SonicLib} from "./common/SonicLib.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract UnhedgeScript is EScript {
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

        uint256 collateral_unhedge_amount = assetsBalance(COLLATERAL_VAULT);

        (string memory swapJson, string memory verifyJson) = getRoutingData(
            COLLATERAL_VAULT, HEDGED_VAULT, COLLATERAL_TOKEN, HEDGED_TOKEN, collateral_unhedge_amount
        );

        broadcastBatch(batchWithdrawAndSwap(
            COLLATERAL_VAULT, collateral_unhedge_amount, swapJson, verifyJson)
        );

        logPositionInfo(COLLATERAL_VAULT, HEDGED_VAULT, LIABILITY_VAULT);
    }
}