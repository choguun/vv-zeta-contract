// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SystemContract} from "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import {zContract, zContext} from "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import {BytesHelperLib} from "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import {OnlySystem} from "@zetachain/toolkit/contracts/OnlySystem.sol";

import {IERC4626} from "./IERC4626.sol";


contract ERC4626Vault is ERC20, IERC4626, Ownable, zContract, OnlySystem {
    using SafeERC20 for IERC20;

    SystemContract public systemContract;
    uint256 public immutable chainID;
    uint256 constant BITCOIN = 18332;

    IERC20 private _asset;

    error WrongChain(uint256 chainID);
    error UnknownAction(uint8 action);
    error Overflow();
    error Underflow();
    error WrongAmount();
    error NotAuthorized();
    error NoRewardsToClaim();

    constructor(
        IERC20 asset, 
        uint256 chainID_,
        address systemContractAddress
        ) ERC20("Stake CUBE", "sCUBE")
    {
        _asset = asset;
        systemContract = SystemContract(systemContractAddress);
        chainID = chainID_;
    }

      function onCrossChainCall(
        zContext calldata context,
        address zrc20,
        uint256 amount,
        bytes calldata message
    ) external virtual override onlySystem(systemContract) {
        if (chainID != context.chainID) {
            revert WrongChain(context.chainID);
        }

        uint8 action = chainID == BITCOIN
            ? uint8(message[0])
            : abi.decode(message, (uint8));
        address sender = abi.decode(context.origin, (address));
        if (action == 1) {
            deposit(amount, sender);
        } else if (action == 2) {
            withdraw(amount, sender, sender);
        } else {
            revert UnknownAction(action);
        }
    }

    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        uint256 totalAssets = totalAssets();
        uint256 totalShares = totalSupply();
        if (totalShares == 0) {
            shares = assets;
        } else {
            shares = (assets * totalShares) / totalAssets;
        }

        _asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        return shares;
    }

    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256 shares) {
        uint256 totalAssets = totalAssets();
        uint256 totalShares = totalSupply();

        shares = (assets * totalShares) / totalAssets;

        if (msg.sender != owner) {
            uint256 currentAllowance = allowance(owner, msg.sender);
            require(currentAllowance >= shares, "ERC20: transfer amount exceeds allowance");
            _approve(owner, msg.sender, currentAllowance - shares);
        }

        _burn(owner, shares);
        _asset.safeTransfer(receiver, assets);

        return shares;
    }

    function totalAssets() public view override returns (uint256) {
        return _asset.balanceOf(address(this));
    }
}
