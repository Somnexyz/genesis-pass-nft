// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "./SomnexGenesisPassManager.sol"; // 引入管理合约

contract SomnexGenesisSilverPassERC721 is ERC721Enumerable {
    IERC20 public weth; // WETH token address
    address public team; // Team wallet address
    uint8 private constant PASS_TYPE = 0; // 0 = Silver
    SomnexGenesisPassManager private passManager;
    
    // Initialize the pass manager in constructor
    constructor(address _weth, address _team, address _passManager) ERC721("Somnex Genesis Silver Pass NFT", "SSPT") {
        require(_weth != address(0), "WETH address cannot be zero");
        require(_team != address(0), "Team wallet address cannot be zero");
        weth = IERC20(_weth);
        team = _team;
        passManager = SomnexGenesisPassManager(_passManager);
    }

    function mint(uint256 tokenId) public virtual {
        require(totalSupply() < passManager.getMaxSupply(PASS_TYPE), "Max supply reached");
        require(tokenId > 0 && tokenId <= passManager.getMaxSupply(PASS_TYPE), "Token ID invalid");
        require(!exists(tokenId), "Token already exists");
        
        // Transfer WETH from the caller's account directly to the team wallet
        require(weth.transferFrom(msg.sender, team, passManager.getMintPrice(PASS_TYPE)), "WETH transfer failed");
        
        _mint(msg.sender, tokenId);
    }
    
    // Check if the specified tokenId already exists
    function exists(uint256 tokenId) public view returns (bool) {
        return ownerOf(tokenId) != address(0);
    }

    function maxSupply() public view returns (uint256) {
        return passManager.getMaxSupply(PASS_TYPE);
    }
    
}
