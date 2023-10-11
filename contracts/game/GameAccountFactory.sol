// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {SimpleAccount} from "./SimpleAccount.sol";
import {IEntryPoint} from "../interfaces/IEntryPoint.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SimpleAccount.sol";



/**
 * A sample factory contract for SimpleAccount
 * A UserOperations "initCode" holds the address of the factory, and a method call (to createAccount, in this sample factory).
 * The factory's createAccount returns the target account address even if it is already installed.
 * This way, the entryPoint.getSenderAddress() can be called either before or after the account is created.
 */
//TODO abstract as a interface
contract GameAccountFactory is Ownable {
    SimpleAccount public immutable accountImplementation;
    uint256 public donateLimit = 500;
    mapping(address => address) public ownerMap;
    address public manager;
    address public beneficiary;

    event SimpleAccountCreated(address indexed entryPoint, address indexed simpleAccount);

    constructor(address _entryPoint, address _beneficiary) {
        accountImplementation = new SimpleAccount(IEntryPoint(_entryPoint));
        beneficiary = _beneficiary;
    }

    function setDonateLimit(uint256 _donateLimit) external onlyOwner {
        donateLimit = _donateLimit;
    }

    function setBeneficiary(address _beneficiary) external onlyOwner {
        beneficiary = _beneficiary;
    }

    function getBeneficiary() external onlyOwner view returns (address) {
        return beneficiary;
    }

    /**
     * enroll an user, should donate eth with amount of donateLimit to the contract
     * returns address even if the account is already enrolled
     */
    function enroll(address owner, uint256 salt) external payable returns (SimpleAccount ret) {
        console.log("owner, salt", owner, salt);
        //check is in ownerMap
        address addr = getAddress(owner, salt);
        address accountOwner = ownerMap[addr];
        if (accountOwner != address(0)) {
            return SimpleAccount(payable((accountOwner)));
        }
        uint256 amount = msg.value;
        require(amount > donateLimit, "create account balance not enough");
        ret = createAccount(owner, salt);
        ownerMap[address(ret)] = owner;
        payable(beneficiary).transfer(amount);
        emit SimpleAccountCreated(address(accountImplementation.entryPoint()), address(ret));
    }

    /**
     * create an account, and return its address.
     * returns the address even if the account is already deployed.
     * Note that during UserOperation execution, this method is called only if the account is not deployed.
     * This method returns an existing account address so that entryPoint.getSenderAddress() would work even after account creation
     */
    function createAccount(address owner, uint256 salt) public payable returns (SimpleAccount ret) {
        console.log("owner, salt", owner, salt);
        //check is in ownerMap
        address addr = getAddress(owner, salt);
        uint codeSize = addr.code.length;
        if (codeSize > 0) {
            return SimpleAccount(payable(addr));
        }
        ret = SimpleAccount(payable(new ERC1967Proxy{salt : bytes32(salt)}(
                address(accountImplementation),
                abi.encodeCall(SimpleAccount.initialize, (owner))
            )));
        emit SimpleAccountCreated(address(accountImplementation.entryPoint()), address(ret));
    }

    /**
     * calculate the counterfactual address of this account as it would be returned by createAccount()
     */
    function getAddress(address owner, uint256 salt) public view returns (address) {
        return Create2.computeAddress(bytes32(salt), keccak256(abi.encodePacked(
                type(ERC1967Proxy).creationCode,
                abi.encode(
                    address(accountImplementation),
                    abi.encodeCall(SimpleAccount.initialize, (owner))
                )
            )));
    }
}
