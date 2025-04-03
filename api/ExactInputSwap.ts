import { getParamsExactIn, getPayload, writeToJsonFile } from "./common";
import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';

async function main() {
    // Parse command line arguments
    const argv = await yargs(hideBin(process.argv))
        .options({
            'address': {
                type: 'string',
                description: 'The wallet address',
                demandOption: true
            },
            'amount': {
                type: 'string',
                description: 'Amount to swap in ether',
                demandOption: true
            },
            'input-vault': {
                type: 'string',
                description: 'Input vault address',
                demandOption: true
            },
            'output-vault': {
                type: 'string',
                description: 'Output vault address',
                demandOption: true
            },
            'input-token': {
                type: 'string',
                description: 'Input token address',
                demandOption: true
            },
            'output-token': {
                type: 'string',
                description: 'Output token address',
                demandOption: true
            },
        })
        .help()
        .argv;

    const swapParams = getParamsExactIn(
        argv.address,
        argv["input-vault"],
        argv["output-vault"],
        argv["input-token"],
        argv["output-token"],
        BigInt(argv.amount).toString()
    );

    const swapPayload = await getPayload(swapParams);

    const outputDir = argv["output-dir"];
    await writeToJsonFile(swapPayload.swap, `script/payloads/swapData.json`);
    await writeToJsonFile(swapPayload.verify, `script/payloads/verifyData.json`);

    console.log("Payloads written to files in:", `script/payloads`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});