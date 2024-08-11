// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import "@zetachain/toolkit/contracts/OnlySystem.sol";

contract Profile is zContract, ERC721, OnlySystem {
    SystemContract public systemContract;
    error CallerNotOwnerNotApproved();
    uint256 constant BITCOIN = 18332;

    mapping(uint256 => uint256) public tokenAmounts;
    mapping(uint256 => uint256) public tokenChains;
    mapping(uint256 => string) public profileHandle; // tokenId => handle
    mapping(string => uint256) public handleToTokenId; // handle => tokenId
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;
    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;
    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;
    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    uint256 private _nextTokenId;

    constructor(address systemContractAddress) ERC721("Profile", "Profile") {
        systemContract = SystemContract(systemContractAddress);
        _nextTokenId = 0;
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

        _mintNFT(recipient, context.chainID, amount);
    }

    function _mintNFT(
        address recipient,
        uint256 chainId,
        uint256 amount
    ) private {
        uint256 tokenId = _nextTokenId;
        _safeMint(recipient, tokenId);
        tokenChains[tokenId] = chainId;
        tokenAmounts[tokenId] = amount;
        _nextTokenId++;
    }

    function registerHandle(string memory username, uint256 chainId) external payable {
        _mintNFT(msg.sender, chainId, 1);
        handleToTokenId[username] = _nextTokenId - 1;
        profileHandle[_nextTokenId-1] = username;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    }

    function burnNFT(uint256 tokenId, bytes memory recipient) public {
        if (!_isApprovedOrOwner(_msgSender(), tokenId)) {
            revert CallerNotOwnerNotApproved();
        }
        address zrc20 = systemContract.gasCoinZRC20ByChainId(
            tokenChains[tokenId]
        );

        (, uint256 gasFee) = IZRC20(zrc20).withdrawGasFee();

        IZRC20(zrc20).approve(zrc20, gasFee);
        IZRC20(zrc20).withdraw(recipient, tokenAmounts[tokenId] - gasFee);

        _burn(tokenId);
        delete tokenAmounts[tokenId];
        delete tokenChains[tokenId];
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
