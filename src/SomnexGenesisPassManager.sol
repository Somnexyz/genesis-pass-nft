// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title SomnexGenesisPassManager
 * @dev This contract manages the minting parameters for different pass types
 */
contract SomnexGenesisPassManager is Ownable2Step {
    // Structure to hold minting parameters
    struct MintParams {
        uint256 price;
        uint256 maxSupply;
    }

    // Constants for different pass types
    uint8 public constant PASS_TYPE_SILVER = 0;
    uint8 public constant PASS_TYPE_GOLD = 1;
    uint8 public constant PASS_TYPE_PLATINUM = 2;

    // Mapping from pass type to its minting parameters
    mapping(uint8 => MintParams) private _mintParams;
    uint256 public typeCount;

    /**
     * @dev Emitted when mint price is updated for a pass type
     */
    event MintPriceUpdated(uint8 indexed passType, uint256 newPrice);

    /**
     * @dev Emitted when max supply is updated for a pass type
     */
    event MaxSupplyUpdated(uint8 indexed passType, uint256 newSupply);

    /**
     * @dev Initializes the contract with default mint parameters
     */
    constructor() Ownable(msg.sender) {
        // Set default values for Silver pass
        _mintParams[PASS_TYPE_SILVER] = MintParams({
            price: 0.01 ether,
            maxSupply: 5000
        });

        // Set default values for Gold pass
        _mintParams[PASS_TYPE_GOLD] = MintParams({
            price: 0.018 ether,
            maxSupply: 10000
        });

        // Set default values for Platinum pass
        _mintParams[PASS_TYPE_PLATINUM] = MintParams({
            price: 0.03 ether,
            maxSupply: 2000
        });
        typeCount = 3; // Total number of pass types
    }

    /**
     * @dev Returns the mint price for a given pass type
     * @param passType The type of pass (0 = Silver, 1 = Gold, 2 = Platinum)
     */
    function getMintPrice(uint8 passType) public view returns (uint256) {
        return _mintParams[passType].price;
    }

    /**
     * @dev Returns the max supply for a given pass type
     * @param passType The type of pass (0 = Silver, 1 = Gold, 2 = Platinum)
     */
    function getMaxSupply(uint8 passType) public view returns (uint256) {
        return _mintParams[passType].maxSupply;
    }

    function getAllTypesMintParams() public view returns (MintParams[] memory) {
        MintParams[] memory mintParams_ = new MintParams[](typeCount);
        for (uint256 i = 0; i < typeCount; i++) {
            mintParams_[i] = _mintParams[uint8(i)];
        }
        return mintParams_;
    }
    
    /**
     * @dev Updates the mint price for a specific pass type
     * @param passType The type of pass (0 = Silver, 1 = Gold, 2 = Platinum)
     * @param newPrice The new mint price in wei
     */
    function setMintPrice(uint8 passType, uint256 newPrice) external onlyOwner {
        _mintParams[passType].price = newPrice;
        emit MintPriceUpdated(passType, newPrice);
    }

    /**
     * @dev Updates the max supply for a specific pass type
     * @param passType The type of pass (0 = Silver, 1 = Gold, 2 = Platinum)
     * @param newSupply The new max supply
     */
    function setMaxSupply(uint8 passType, uint256 newSupply) external onlyOwner {
        _mintParams[passType].maxSupply = newSupply;
        emit MaxSupplyUpdated(passType, newSupply);
    }
}
