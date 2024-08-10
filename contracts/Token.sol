// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Profile} from "./Profile.sol";
import "@zetachain/protocol-contracts/contracts/evm/tools/ZetaInteractor.sol";
import "@zetachain/protocol-contracts/contracts/evm/interfaces/ZetaInterfaces.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is ERC20, ERC20Burnable, ZetaInteractor, ZetaReceiver {
    address public profile;
    address public world;

    error InsufficientBalance();
    event CrossChainERC20Event(address, uint256);
    event CrossChainERC20RevertedEvent(address, uint256);
    ZetaTokenConsumer private immutable _zetaConsumer;
    IERC20 internal immutable _zetaToken;

    constructor(
        address _world, 
        address _profile,
        address connectorAddress,
        address zetaTokenAddress,
        address zetaConsumerAddress
        ) ERC20("CUBE Token", "CUBE") ZetaInteractor(connectorAddress) { 
        _zetaToken = IERC20(zetaTokenAddress);
        _zetaConsumer = ZetaTokenConsumer(zetaConsumerAddress);

        profile = _profile;
        world = _world;
    }

    function sendMessage(
        uint256 destinationChainId,
        address to,
        uint256 value
    ) external payable {
        if (!_isValidChainId(destinationChainId))
            revert InvalidDestinationChainId();
        uint256 crossChainGas = 2 * (10 ** 18);
        uint256 zetaValueAndGas = _zetaConsumer.getZetaFromEth{
            value: msg.value
        }(address(this), crossChainGas);
        _zetaToken.approve(address(connector), zetaValueAndGas);
        if (balanceOf(msg.sender) < value) revert InsufficientBalance(); 
        _burn(msg.sender, value);
        connector.send(
            ZetaInterfaces.SendInput({
                destinationChainId: destinationChainId,
                destinationAddress: interactorsByChainId[destinationChainId],
                destinationGasLimit: 300000,
                message: abi.encode(to, value, msg.sender),
                zetaValueAndGas: zetaValueAndGas,
                zetaParams: abi.encode("")
            })
        );
    }
    function onZetaMessage(
        ZetaInterfaces.ZetaMessage calldata zetaMessage
    ) external override isValidMessageCall(zetaMessage) {
        (address to, uint256 value) = abi.decode(
            zetaMessage.message,
            (address, uint256)
        );
        _mint(to, value); 
        emit CrossChainERC20Event(to, value);
    }
    function onZetaRevert(
        ZetaInterfaces.ZetaRevert calldata zetaRevert
    ) external override isValidRevertCall(zetaRevert) {
        (address to, uint256 value, address from) = abi.decode( 
            zetaRevert.message,
            (address, uint256, address)
        );
        _mint(from, value); 
        emit CrossChainERC20RevertedEvent(to, value);
    }

    modifier onlyUser() {
        require(Profile(profile).balanceOf(_msgSender()) > 0, "Only user can call this function");
        _;
    }

    modifier onlyWorld() {
        require(_msgSender() == world, "Only world can call this function");
        _;
    }

    function setWorld(address _world) public onlyOwner {
        world = _world;
    }

    function mint(address to, uint256 _amount) public onlyWorld {
        _mint(to, _amount);
    }

    function burn(address from, uint256 _amount) public onlyWorld {
        _burn(from, _amount);
    }
}