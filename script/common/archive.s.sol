    // function permitVault(address _vault, uint256 _amount) public returns (bytes memory permitData) {
    //     IERC20Permit token = IERC20Permit(EVault(_vault).asset());
    //     uint256 nonce = token.nonces(borrower);
    //     bytes32 domainSeparator = token.DOMAIN_SEPARATOR();

    //     bytes32 structHash = keccak256(abi.encode(
    //         keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
    //         borrower,
    //         _vault,
    //         _amount,
    //         nonce,
    //         block.timestamp + 1 days
    //     ));

    //     bytes32 digest = keccak256(abi.encodePacked(
    //         "\x19\x01",
    //         domainSeparator,
    //         structHash
    //     ));

    //     (uint8 v, bytes32 r, bytes32 s) = splitSignature(castSign(toHexString(abi.encodePacked(digest))));

    //     bytes memory permitData = abi.encodeWithSelector(
    //         IERC20Permit.permit.selector,
    //         borrower,
    //         _vault,
    //         _amount,
    //         block.timestamp + 1 days,
    //         v, r, s
    //     );
    // }

    // function castSign(string memory message) public returns (bytes memory signature) {
    //     string memory commandStart = "cast wallet sign ";
    //     string memory flags = string.concat("--no-hash --trezor --hd-paths ", "m/44'/60'/0'/0/11", " ");

    //     string[] memory inputs = new string[](3);
    //     inputs[0] = "bash";
    //     inputs[1] = "-c";
    //     inputs[2] = string.concat(commandStart, flags, message);

    //     signature = vm.ffi(inputs);
    // }
    // function add4(bytes memory _b) private pure returns (bytes memory) {
    //     require(_b.length > 0, "byte array must not be empty");

    //     uint256 lastByte = uint256(uint8(_b[_b.length - 1]));
    //     uint256 incrementedLastByte = lastByte + 4;

    //     if (incrementedLastByte > 255) {
    //         incrementedLastByte = 255;
    //     }

    //     _b[_b.length - 1] = bytes1(uint8(incrementedLastByte));

    //     return _b;
    // }
    // function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
    //     require(sig.length == 65, "Invalid signature length");

    //     assembly {
    //         r := mload(add(sig, 32))         // first 32 bytes
    //         s := mload(add(sig, 64))         // second 32 bytes
    //         v := byte(0, mload(add(sig, 96))) // final byte
    //     }

    //     // EIP-2 fix
    //     if (v < 27) {
    //         v += 27;
    //     }
    // }
    // function toHexString(bytes memory data) public pure returns (string memory) {
    //     bytes memory alphabet = "0123456789abcdef";
    //     bytes memory str = new bytes(2 + data.length * 2);
    //     str[0] = "0";
    //     str[1] = "x";

    //     for (uint i = 0; i < data.length; i++) {
    //         str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
    //         str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
    //     }

    //     return string(str);
    // }

    //     function batchApproval(address _vault, uint256 _amount) public returns (IEVC.BatchItem memory) {
    //     bytes memory permitData = permitVault(_vault, _amount);
    //     return IEVC.BatchItem({
    //         onBehalfOfAccount: e_account,
    //         targetContract: EVault(_vault).asset(),
    //         value: 0,
    //         data: permitData
    //     });
    // }