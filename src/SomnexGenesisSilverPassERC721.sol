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

    function buy(uint256 amount, address to) public virtual {
        uint256 currentSupply = totalSupply();
        (uint256 price, uint256 _maxSupply) = passManager.getParam(PASS_TYPE);
        require(currentSupply + amount <= _maxSupply, "Purchase exceeds max supply");
        require(amount > 0, "Purchase amount must be greater than zero");
        
        uint256 totalPrice = price * amount;
        
        // Transfer WETH from the caller's account directly to the team wallet
        require(weth.transferFrom(msg.sender, team, totalPrice), "WETH transfer failed");
        
        // Mint the specified amount of NFTs to the buyer
        for (uint256 i = 0; i < amount; i++) {
            uint256 newTokenId = currentSupply + i + 1; // Start from current supply + 1
            require(newTokenId > 0 && newTokenId <= _maxSupply, "Token ID invalid");
            require(!exists(newTokenId), "Token already exists");
            _mint(to, newTokenId);
        }
    }
    
    // Check if the specified tokenId already exists
    function exists(uint256 tokenId) public view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function maxSupply() public view returns (uint256) {
        return passManager.getMaxSupply(PASS_TYPE);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafkreiajolqvg6kofe3wzjvvvsbelq2c3yu73k4c7h6othvmtjvgtba34e";
    }
    
}
