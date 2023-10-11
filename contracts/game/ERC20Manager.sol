// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;


import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
//import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./GameAccountFactory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./SignatureVerify.sol";
import "hardhat/console.sol";


contract ERC20Manager {

    GameAccountFactory public gameAccountFactory;
    SignatureVerify public signatureVerify;

    IERC20 public erc20;

    event Deposit(address indexed toAddress, address indexed fromAddress, uint256 amount);
    event Withdraw(address indexed toAddress, address indexed fromAddress, uint256 amount);

    constructor(address _gameAccountFactory, address _entryPoint, address _erc20, address _signer) {
        gameAccountFactory = GameAccountFactory(_gameAccountFactory);
        erc20 = IERC20(_erc20);
        signatureVerify = new SignatureVerify(_signer, IEntryPoint(_entryPoint));
    }

    /**
 * @dev The _entryPoint member is immutable, to reduce gas consumption.  To upgrade EntryPoint,
     * a new implementation of GameAccount must be deployed with the new EntryPoint address, then upgrading
      * the implementation by calling `upgradeTo()`
     */
    /*function initialize(address _gameAccountFactory, address _entryPoint, address _erc20, address _signer) public initializer {
        gameAccountFactory = GameAccountFactory(_gameAccountFactory);
        erc20 = IERC20(_erc20);
        signatureVerify = new SignatureVerify(_signer, IEntryPoint(_entryPoint));
        __Ownable_init();
    }*/
    //deposit approval before transfer
    //toAddress should be created by gameAccountFactory
    function deposit(address toAddress, uint256 amount) external onlyInFactory(toAddress) {
        //check is approved
        uint256 allowAmount = erc20.allowance(msg.sender, address(this));
        require(allowAmount >= amount, "allowed balance not enough");
        //burn the value
        bool success = erc20.transferFrom(msg.sender, address(this), amount);
        require(success, "burn failed");
        emit Deposit(msg.sender, toAddress, amount);
    }

    //withdraw approval before transfer
    //msg.sender should be created by gameAccountFactory
    function withdraw(address toAddress, uint256 amount, bytes calldata signature) external onlyInFactory(toAddress) {

        require(signatureVerify.validateSignature(msg.sender, toAddress, amount, signature), "verify signature failed");
        //mint the value
        bool success = erc20.transferFrom(address(this), toAddress, amount);
        require(success, "transfer failed");
        emit Withdraw(toAddress, msg.sender, amount);
    }


    function _onlyInFactory(address _toCheck) internal view {
        address owner = gameAccountFactory.ownerMap(_toCheck);
        require(owner != address(0), "address not in factory");
    }

    modifier onlyInFactory(address _toCheck) {
        _onlyInFactory(_toCheck);
        _;
    }
}