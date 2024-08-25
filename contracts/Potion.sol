// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {SystemContract} from "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import {zContract, zContext} from "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import {BytesHelperLib} from "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import {OnlySystem, IZRC20} from "@zetachain/toolkit/contracts/OnlySystem.sol";

contract Potion is ERC1155, Ownable {
    uint256 public constant STAMINA_POTION = 0;
    uint256 public constant HP_POTION = 1;

    address public world;

    constructor(address _initialOwner, address _world, string memory _itemURI) 
    ERC1155(_itemURI)
    {
        transferOwnership(_initialOwner);
        world = _world;
    }

    modifier onlyWorld() {
        require(_msgSender() == world, "Only world can call this function");
        _;
    }

    function mint(address _to, uint256 _id, uint256 _amount) public onlyWorld {
        _mint(_to, _id, _amount, "");
    }

    function burn(address _to, uint256 _id, uint256 _amount) public onlyWorld {
        _burn(_to, _id, _amount);
    }
}
