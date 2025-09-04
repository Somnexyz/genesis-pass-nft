// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGenesisERC721 {
    function PASS_TYPE() external view returns (uint8);
    function buy(uint256 amount, address to) external;
    function maxSupply() external view returns (uint256);
    function setBaseURI(string memory baseURI_) external;
    function tokenURI(uint256 tokenId) external view returns (string memory);
}