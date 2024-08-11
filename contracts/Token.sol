// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Profile} from "./Profile.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import "@zetachain/toolkit/contracts/OnlySystem.sol";

contract Token is zContract, ERC20, OnlySystem {
    SystemContract public systemContract;
    error CallerNotOwnerNotApproved();
    uint256 constant BITCOIN = 18332;

    mapping(uint256 => uint256) public tokenAmounts;
    mapping(address => uint256) public tokenChains;

    address public profile;
    address public world;

    constructor(   
        address _world, 
        address _profile,
        address systemContractAddress
        ) ERC20("CUBE Token", "CUBE") {
        systemContract = SystemContract(systemContractAddress);
        profile = _profile;
        world = _world;
    }

    function onCrossChainCall(
        zContext calldata context,
        address zrc20,
        uint256 amount,
        bytes calldata message
    ) external override onlySystem(systemContract) {
        address recipient;

        if (context.chainID == BITCOIN) {
            recipient = BytesHelperLib.bytesToAddress(message, 0);
        } else {
            recipient = abi.decode(message, (address));
        }

        _mintToken(recipient, context.chainID, amount);
    }

    function _mintToken(
        address recipient,
        uint256 chainId,
        uint256 amount
    ) private {
        _mint(recipient, amount);
        tokenChains[recipient] = chainId;
    }

    function burnToken(bytes calldata recipient, uint256 amount) public {
        // if (!_isApprovedOrOwner(_msgSender(), tokenId)) {
        //     revert CallerNotOwnerNotApproved();
        // }
        address zrc20 = systemContract.gasCoinZRC20ByChainId(
            tokenChains[msg.sender]
        );

        (, uint256 gasFee) = IZRC20(zrc20).withdrawGasFee();

        IZRC20(zrc20).approve(zrc20, gasFee);
        IZRC20(zrc20).withdraw(recipient, amount - gasFee);

        _burn(BytesHelperLib.bytesToAddress(recipient, 0), amount);
    }
  
    modifier onlyUser() {
        require(Profile(profile).balanceOf(_msgSender()) > 0, "Only user can call this function");
        _;
    }

    modifier onlyWorld() {
        require(_msgSender() == world, "Only world can call this function");
        _;
    }

    function setWorld(address _world) public {
        world = _world;
    }

    function mint(address to, uint256 _amount) public onlyWorld {
        _mint(to, _amount);
    }

    function burn(address from, uint256 _amount) public onlyWorld {
        _burn(from, _amount);
    }
}