// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./common/EScript.s.sol";
import {SonicLib} from "./common/SonicLib.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
contract OpenScript is EScript {
    function run() public {
        borrower = msg.sender;
        e_account = getSubaccount(borrower, 0);
        evc = IEVC(SonicLib.EVC);

        address LIABILITY_VAULT = SonicLib.EULER_WS_VAULT;
        address HEDGED_VAULT = SonicLib.EULER_PT_STS_VAULT;
        address COLLATERAL_VAULT = SonicLib.EULER_USDC_VAULT;

        address LIABILITY_TOKEN = SonicLib.WS;
        address HEDGED_TOKEN = SonicLib.PT_STS;
        address COLLATERAL_TOKEN = SonicLib.USDC;

        vm.label(LIABILITY_TOKEN, "LIABILITY_TOKEN");
        vm.label(HEDGED_TOKEN, "HEDGED_TOKEN");
        vm.label(COLLATERAL_TOKEN, "COLLATERAL_TOKEN");
        vm.label(LIABILITY_VAULT, "LIABILITY_VAULT");
        vm.label(HEDGED_VAULT, "HEDGED_VAULT");
        vm.label(COLLATERAL_VAULT, "COLLATERAL_VAULT");
        vm.label(e_account, "e_account");
        vm.label(borrower, "borrower");
        vm.label(address(evc), "evc");

        uint256 collateral_balance = IERC20(COLLATERAL_TOKEN).balanceOf(borrower);
        console.log("collateral_balance", collateral_balance);
        
        uint256 maxDebt = collateral_balance * 2e12 * 7;

        requestPayload(
            LIABILITY_VAULT,
            HEDGED_VAULT,
            LIABILITY_TOKEN,
            HEDGED_TOKEN,
            maxDebt
        );

        string memory swapJson = getJsonFile("./script/payloads/swapData.json");
        string memory verifyJson = getJsonFile("./script/payloads/verifyData.json");

        vm.label(vm.parseJsonAddress(swapJson, ".swapperAddress"), "swapperAddress");
        vm.label(vm.parseJsonAddress(verifyJson, ".verifierAddress"), "verifierAddress");

        IEVC.BatchItem[] memory batchItems = new IEVC.BatchItem[](7);

        batchItems[0] = enableCollateral(COLLATERAL_VAULT);
        batchItems[1] = enableCollateral(HEDGED_VAULT);
        batchItems[2] = enableController(LIABILITY_VAULT);

        batchItems[3] = batchDeposit(COLLATERAL_VAULT, collateral_balance);
        batchItems[4] = batchBorrowTo(LIABILITY_VAULT, maxDebt, vm.parseJsonAddress(swapJson, ".swapperAddress"));

        batchItems[5] = batchPayload(vm.parseJsonAddress(swapJson, ".swapperAddress"), vm.parseJsonBytes(swapJson, ".swapperData"));
        batchItems[6] = batchPayload(vm.parseJsonAddress(verifyJson, ".verifierAddress"), vm.parseJsonBytes(verifyJson, ".verifierData"));

        vm.startBroadcast();

        IERC20(COLLATERAL_TOKEN).approve(COLLATERAL_VAULT, collateral_balance);
        evc.batch(batchItems);

        vm.stopBroadcast();

        console.log("LIABILITY TOKEN DEBT: ", debtBalance(LIABILITY_VAULT));
        console.log("HEDGED TOKEN BALANCE: ", assetsBalance(HEDGED_VAULT));
        console.log("COLLATERAL TOKEN BALANCE: ", assetsBalance(COLLATERAL_VAULT));


    }
}