// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@zetachain/protocol-contracts/contracts/evm/tools/ZetaInteractor.sol";
import "@zetachain/protocol-contracts/contracts/evm/interfaces/ZetaInterfaces.sol";

contract Profile is ERC721, ZetaInteractor, ZetaReceiver {  
    mapping(uint256 => string) public profileHandle; // tokenId => handle
    mapping(string => uint256) public handleToTokenId; // handle => tokenId

    event CrossChainNFTEvent(address, uint256);
    event CrossChainNFTRevertedEvent(address, uint256);
 
    ZetaTokenConsumer private immutable _zetaConsumer;
    IERC20 internal immutable _zetaToken;
    uint256 private _tokenIds;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    constructor(
        address connectorAddress, // 0x3963341dad121c9CD33046089395D66eBF20Fb03
        address zetaTokenAddress, // 0x0000c304D2934c00Db1d51995b9f6996AffD17c0
        address zetaConsumerAddress, // 0x301ED39771d8f1dD0b05F8C2D4327ce9C426E783
        bool useEven
      ) 
      ERC721("Profile", "Profile") 
      ZetaInteractor(connectorAddress) {
        _zetaToken = IERC20(zetaTokenAddress);
        _zetaConsumer = ZetaTokenConsumer(zetaConsumerAddress);

        _tokenIds++;
        if (useEven) _tokenIds++;
    }

    function sendMessage(
        uint256 destinationChainId,
        address to,
        uint256 token
    ) external payable {
        if (!_isValidChainId(destinationChainId))
            revert InvalidDestinationChainId();
 
        uint256 crossChainGas = 2 * (10 ** 18);
        uint256 zetaValueAndGas = _zetaConsumer.getZetaFromEth{
            value: msg.value
        }(address(this), crossChainGas);
        _zetaToken.approve(address(connector), zetaValueAndGas);
 
        _burn(token);
 
        connector.send(
            ZetaInterfaces.SendInput({
                destinationChainId: destinationChainId,
                destinationAddress: interactorsByChainId[destinationChainId],
                destinationGasLimit: 300000,
                message: abi.encode(to, token, msg.sender),
                zetaValueAndGas: zetaValueAndGas,
                zetaParams: abi.encode("")
            })
        );
    }
 
    function onZetaMessage(
        ZetaInterfaces.ZetaMessage calldata zetaMessage
    ) external override isValidMessageCall(zetaMessage) {
        (address to, uint256 token) = abi.decode(
            zetaMessage.message,
            (address, uint256)
        );
 
        _safeMint(to, token);
 
        emit CrossChainNFTEvent(to, token);
    }
 
    function onZetaRevert(
        ZetaInterfaces.ZetaRevert calldata zetaRevert
    ) external override isValidRevertCall(zetaRevert) {
        (address to, uint256 token, address from) = abi.decode(
            zetaRevert.message,
            (address, uint256, address)
        );
 
        _safeMint(from, token);
 
        emit CrossChainNFTRevertedEvent(to, token);
    }
    
    function registerHandle(string memory username) external payable {
        mint(msg.sender, username);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
    }

    function mint(address _to, string memory username) public payable {
        require(handleToTokenId[username] == 0, "Handle already exists");
        require(this.balanceOf(_msgSender()) == 0, "Only one profile handle per wallet");

        _tokenIds++;
        _tokenIds++;

        _safeMint(_to, _tokenIds);
        handleToTokenId[username] = _tokenIds;
        profileHandle[_tokenIds] = username;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getTokenIdsOfOwner(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokens[to].push(tokenId);
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length - 1;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    // Optional: Implement token transfer and burn functions to maintain the enumeration
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we replace the token to be removed with the last one in the array
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-be-removed token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].pop();

        // Update the index for the removed token
        delete _ownedTokensIndex[tokenId];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we replace the token to be removed with the last one in the array
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _allTokens[lastTokenIndex];

            _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-be-removed token
            _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _allTokens.pop();

        // Update the index for the removed token
        delete _allTokensIndex[tokenId];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        if (from != address(0)) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }

        if (to != address(0)) {
            _addTokenToOwnerEnumeration(to, tokenId);
        } else {
            // If the token is being burned, remove it from the global enumeration
            _removeTokenFromAllTokensEnumeration(tokenId);
        }
    }
}