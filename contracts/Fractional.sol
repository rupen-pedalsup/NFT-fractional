// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./FractionalStorage.sol";

contract Fractional is FractionalStorage, ERC721URIStorage {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private tokenIds;

    constructor() ERC721("MyNFTToken", "MNT") {}

    function _create(
        address receiver,
        string memory _tokenURI
    ) internal returns (uint256) {
        uint256 newTokenId = tokenIds.current();

        _mint(receiver, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        track[receiver] = newTokenId;
        tokenIds.increment();

        return newTokenId;
    }

    function _transferNFT(
        address _sender,
        address _receiver,
        uint256 _tokenId,
        string memory _tokenURI
    ) internal {
        _transfer(_sender, _receiver, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);

        delete track[_sender];
        track[_receiver] = _tokenId;
    }

    function createNFT(string memory _tokenURI, uint256 price) public {
        uint256 tokenId = _create(msg.sender, _tokenURI);
        idToOwner[tokenId] = payable(msg.sender);
        idToPrice[tokenId] = price * 1e18;
        idToNFT[tokenId] = NFT(tokenId, idToOwner[tokenId], idToPrice[tokenId]);
    }

    function lockNFT(
        uint256 _tokenId,
        string memory _tokenURI,
        uint256 _sharesAmount
    ) public {
        _transferNFT(msg.sender, address(this), _tokenId, _tokenURI);

        string memory tokenId = Strings.toString(_tokenId);
        string memory _tokenName = "FractionNFT";
        string memory tokenName = string(abi.encodePacked(_tokenName, tokenId));
        string memory _tokenSymbol = "FNFT";
        string memory tokenSymbol = string(
            abi.encodePacked(_tokenSymbol, tokenId)
        );

        ERC20 fractionalToken = new ERC20(
            tokenName,
            tokenSymbol,
            _sharesAmount
        );

        idToShare[_tokenId] = fractionalToken;
        uint256 _price = idToPrice[_tokenId];
        idToShareValue[_tokenId] = _price.div(_sharesAmount);
    }

    function buyFractionalShares(
        uint256 _tokenId,
        uint256 _totalShares
    ) public payable {
        require(msg.value >= idToShareValue[_tokenId].mul(_totalShares));

        address payable nftOwner = idToOwner[_tokenId];
        uint256 _amount = idToShareValue[_tokenId].mul(_totalShares);
        nftOwner.transfer(_amount);

        idToShare[_tokenId].transfer(msg.sender, _totalShares);
    }

    function fetchNFTs() public view returns (NFT[] memory) {
        uint256 totalItemCount = tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        NFT[] memory items = new NFT[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToNFT[i + 1].owner == msg.sender) {
                items[currentIndex] = idToNFT[i + 1];
                currentIndex += 1;
            }
        }

        return items;
    }
}
