// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import "evc/interfaces/IEthereumVaultConnector.sol";
import { EVault } from "evk/EVault/EVault.sol";

contract EScript is Script {
    IEVC evc;
    address borrower; // eoa
    address e_account; // subaccount

    function getSubaccount(address _account, uint256 _index) public returns (address) {
        return address(uint160(uint160(_account)^_index));
    }

    function getJsonFile(string memory _filePath) internal view returns (string memory) {
        return vm.readFile(_filePath);
    } 

    function enableCollateral(address _vault) public view returns (IEVC.BatchItem memory) {
        return IEVC.BatchItem({
            onBehalfOfAccount: address(0),
            targetContract: address(evc),
            value: 0,
            data: abi.encodeWithSelector(
                IEVC.enableCollateral.selector,
                e_account,
                _vault
            )
        });
    }

    function enableController(address _vault) public view returns (IEVC.BatchItem memory) {
        return IEVC.BatchItem({
            onBehalfOfAccount: address(0),
            targetContract: address(evc),
            value: 0,
            data: abi.encodeWithSelector(
                IEVC.enableController.selector,
                e_account,
                _vault
            )
        });
    }

    function batchPayload(address _target, bytes memory _data) public view returns (IEVC.BatchItem memory) {
        return IEVC.BatchItem({
            onBehalfOfAccount: e_account,
            targetContract: _target,
            value: 0,
            data: _data
        });
    }

    function batchBorrowTo(address _vault, uint256 _amount, address _to) public view returns (IEVC.BatchItem memory) {
        return IEVC.BatchItem({
            onBehalfOfAccount: e_account,
            targetContract: _vault,
            value: 0,
            data: abi.encodeWithSelector(EVault.borrow.selector, _amount, _to)
        });
    }

    function batchDeposit(address _vault, uint256 _amount) public view returns (IEVC.BatchItem memory) {
        return IEVC.BatchItem({
            onBehalfOfAccount: e_account,
            targetContract: _vault,
            value: 0,
            data: abi.encodeWithSelector(EVault.deposit.selector, _amount, e_account)
        });
    }

    function sharesBalance(address _vault) public view returns (uint256) {
        return EVault(_vault).balanceOf(e_account);
    }

    function assetsBalance(address _vault) public view returns (uint256) {
        return EVault(_vault).convertToAssets(EVault(_vault).balanceOf(e_account));
    }

    function debtBalance(address _vault) public view returns (uint256) {
        return EVault(_vault).debtOf(e_account);
    }

    function requestPayload(
        address _inputVault,
        address _outputVault,
        address _inputToken,
        address _outputToken,
        uint256 _amount
    ) public {
        string[] memory inputs = new string[](14);
        inputs[0] = "ts-node";
        inputs[1] = "api/ExactInputSwap.ts";
        inputs[2] = "--address";
        inputs[3] = vm.toString(e_account);
        inputs[4] = "--input-vault";
        inputs[5] = vm.toString(_inputVault);
        inputs[6] = "--output-vault";
        inputs[7] = vm.toString(_outputVault);
        inputs[8] = "--input-token";
        inputs[9] = vm.toString(_inputToken);
        inputs[10] = "--output-token";
        inputs[11] = vm.toString(_outputToken);
        inputs[12] = "--amount";
        inputs[13] = vm.toString(_amount);
        
        vm.ffi(inputs);
    }

}