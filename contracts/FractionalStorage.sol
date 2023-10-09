// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract FractionalStorage {
    struct NFT {
        uint256 tokenId;
        address payable owner;
        uint256 price;
    }

    mapping(address => uint256) public track;
    mapping(uint256 => NFT) public idToNFT;
    mapping(uint256 => address payable) public idToOwner;
    mapping(uint256 => uint256) public idToPrice;
    mapping(uint256 => uint256) public idToShareValue;
    mapping(uint256 => ERC20) public idToShare;
}
