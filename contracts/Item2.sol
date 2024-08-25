// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {SystemContract} from "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import {zContract, zContext} from "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import {BytesHelperLib} from "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import {OnlySystem, IZRC20} from "@zetachain/toolkit/contracts/OnlySystem.sol";

contract Item2 is ERC1155, zContract, OnlySystem, Ownable {
    SystemContract public systemContract;
    error CallerNotOwnerNotApproved();
    uint256 constant BITCOIN = 18332;

    mapping(uint256 => uint256) public tokenAmounts;
    mapping(uint256 => uint256) public tokenChains;

    uint256 public constant PICKAXE = 0;
    uint256 public constant METAL_PICKAXE = 1;
    uint256 public constant GOLDEN_PICKAXE = 2;

    address public world;
    address public craft;

    constructor(address _world, address _craft, string memory _itemURI, address systemContractAddress) 
    ERC1155(_itemURI)
    {
        systemContract = SystemContract(systemContractAddress);
        world = _world;
        craft = _craft;
    }

    function onCrossChainCall(
        zContext calldata context,
        address zrc20,
        uint256 amount,
        bytes calldata message
    ) external override onlySystem(systemContract) {
        address recipient;
        uint256 id;

        if (context.chainID == BITCOIN) {
            recipient = BytesHelperLib.bytesToAddress(message, 0);
        } else {
            (recipient, id) = abi.decode(message, (address, uint256));
        }

        _mintNFT(recipient, id, context.chainID, amount);
    }

    modifier onlyWorld() {
        require(_msgSender() == world, "Only world can call this function");
        _;
    }

    modifier onlyCraft() {
        require(_msgSender() == craft, "Only craft can call this function");
        _;
    }

    function _mintNFT(
        address recipient,
        uint256 _id,
        uint256 chainId,
        uint256 amount
    ) private {
        // _safeMint(recipient, tokenId);
        _mint(recipient, _id, amount, "");
        tokenChains[_id] = chainId;
        tokenAmounts[_id] = amount;
    }

    function burnNFT(uint256 id, uint256 amount, bytes memory recipient) public {
    // Check if the caller is approved or has enough balance
        require(this.balanceOf(_msgSender(), id) == amount, "CallerNotOwnerNotApproved");
        address zrc20 = systemContract.gasCoinZRC20ByChainId(tokenChains[id]);

        (, uint256 gasFee) = IZRC20(zrc20).withdrawGasFee();

        IZRC20(zrc20).approve(zrc20, gasFee);
        IZRC20(zrc20).withdraw(recipient, tokenAmounts[id] - gasFee);

        // Burn the specified amount of the tokenId
        _burn(_msgSender(), id, amount);

        // Clean up the token data
        delete tokenAmounts[id];
        delete tokenChains[id];
    }


    function mint(address _to, uint256 _id, uint256 _amount) public onlyWorld {
        _mint(_to, _id, _amount, "");
    }

    function burn(address _to, uint256 _id, uint256 _amount) public onlyWorld {
        _burn(_to, _id, _amount);
    }

    function mintbyCraftSystem(address _to, uint256 _id, uint256 _amount) public onlyCraft {
        _mint(_to, _id, _amount, "");
    }

    function burnbyCraftSystem(address _to, uint256 _id, uint256 _amount) public onlyCraft {
        _burn(_to, _id, _amount);
    }
}
