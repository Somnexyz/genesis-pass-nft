// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IGenesisERC721.sol";
import "./SomnexGenesisPassManager.sol";

contract SomnexGenesisSilverPassERC721 is ERC721Enumerable, ReentrancyGuard, IGenesisERC721 {
    string private _baseURI;
    IERC20 public paymentToken; // Payment token address
    uint8 public constant PASS_TYPE = 0; // 0 = Silver
    SomnexGenesisPassManager private passManager;
    
    // Initialize the pass manager in constructor
    constructor(address _paymentToken,  address _passManager) ERC721("Somnex Genesis Silver Pass NFT", "SSPT") {
        require(_paymentToken != address(0), "Payment token address cannot be zero");
        paymentToken = IERC20(_paymentToken);
        passManager = SomnexGenesisPassManager(_passManager);
    }

    function buy(uint256 amount, address to) public nonReentrant {
        uint256 currentSupply = totalSupply();
        (uint256 price, uint256 _maxSupply) = passManager.getParam(PASS_TYPE);
        require(currentSupply + amount <= _maxSupply, "Purchase exceeds max supply");
        require(amount > 0, "Purchase amount must be greater than zero");
        
        uint256 totalPrice = price * amount;
        
        // Transfer payment token from the caller's account directly to the team wallet
        require(paymentToken.transferFrom(msg.sender, passManager.team(), totalPrice), "Payment token transfer failed");
        
        // Mint the specified amount of NFTs to the buyer
        for (uint256 i = 0; i < amount; i++) {
            uint256 newTokenId = currentSupply + i + 1; // Start from current supply + 1
            require(newTokenId > 0 && newTokenId <= _maxSupply, "Token ID invalid");
            _mint(to, newTokenId);
        }
    }

    function maxSupply() public view returns (uint256) {
        return passManager.getMaxSupply(PASS_TYPE);
    }
    
    function setBaseURI(string memory baseURI_) external {
        require(msg.sender == address(passManager), "Only manager can set base URI");
        _baseURI = baseURI_;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, IGenesisERC721) returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI)) : "";
    }
}
