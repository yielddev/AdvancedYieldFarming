import axios from "axios";
import * as fs from "fs";
import * as dotenv from 'dotenv';
import { resolve } from 'path';

// Load environment variables from .env file
dotenv.config({ path: resolve(__dirname, '../.env') });
const SWAP_API_URL = "https://swap.euler.finance";
// Get params for an exact in swap to close a position
// funds are delivered to the liability Vault
export function getParamsExactIn(
    account: string,
    inputVaultAddress: string,
    outputVaultAddress: string,
    inputToken: string,
    outputToken: string,
    amountIn: string,
) {
    const queryParams = {
        chainId: "146",
        tokenIn: inputToken,
        tokenOut: outputToken,
        amount: amountIn, // the amount to swap 
        targetDebt: "0", // irrelevant in this exactIn flow
        currentDebt: amountIn, // irrelevant in this exactIn flow
        receiver: outputVaultAddress,
        vaultIn: inputVaultAddress, // left over tokenIn goes here, irrelevent for exactIn flow
        origin: account, // account executing the tx
        accountIn: account, // account holding the collateral
        accountOut: account, // account to swap to, the account that skim will deliver to 
        slippage: "0.3", // 0.15% slippage
        deadline: String(Math.floor(Date.now() / 1000) + 10 * 60), // 10 minutes from now
        swapperMode: "0", // exact input mode = 0 
        isRepay: "false", // we will manually add a call to repay the debt
    };
    return queryParams;
}

// Get payload for an exact in swap to close a position
export async function getPayload(queryParams: any) {

    const { data: response } = await axios.get(
        `${SWAP_API_URL}/swap`,
        {
            params: queryParams
        }
    );

    return response.data
}

export async function writeToJsonFile(data: any, filename: string) {
    fs.writeFileSync(filename, JSON.stringify(data, null, 2));
}