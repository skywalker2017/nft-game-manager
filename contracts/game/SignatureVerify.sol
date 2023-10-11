// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/IEntryPoint.sol";

contract SignatureVerify {

    address public signer;
    IEntryPoint entryPoint;

    constructor(address _signer, IEntryPoint _entryPoint){
        signer = _signer;
        entryPoint = _entryPoint;
    }

    function validateSignature(address from, address to, uint256 value, bytes memory signature) public view returns (bool) {
        // This is a simple example, you might want to add more complex logic
        bytes32 messageHash = keccak256(abi.encodePacked(from, to, value, signer));
        // getNonce
        uint256 myUint256 = uint256(messageHash);
        uint192 key = uint192(myUint256 >> 64);
        uint256 nonce = entryPoint.getNonce(from, key);

        // Construct the message hash
        bytes32 signHash = keccak256(abi.encodePacked(from, to, value, nonce));

        // Recover the signer's address from the signature
        address recoveredAddress = ECDSA.recover(signHash, signature);

        // Compare the recovered address to the `from` address
        return (recoveredAddress == signer);
    }
}
