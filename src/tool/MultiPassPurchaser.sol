// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../SomnexGenesisPassManager.sol";

/**
 * @title MultiPassPurchaser
 * @dev This contract allows purchasing multiple NFT types in a single transaction
 */
contract MultiPassPurchaser {
    // Structure to hold purchase parameters
    struct PurchaseParams {
        address nftContract;  // Address of the NFT contract
        uint256 amount;       // Number of NFTs to purchase
        address to;           // Recipient address
    }

    /**
     * @dev Multi-buy function to purchase multiple NFT types in one transaction
     * @param purchases Array of purchase parameters
     */
    function multiBuy(
        PurchaseParams[] calldata purchases
    ) public {
        require(purchases.length > 0, "No purchases specified");
        
        
        // Execute all purchases
        for (uint256 i = 0; i < purchases.length; i++) {
            PurchaseParams calldata purchase = purchases[i];
            
            // Call the buy function on the specific NFT contract
            (bool success, ) = purchase.nftContract.call(
                abi.encodeWithSignature("buy(uint256,address)", purchase.amount, purchase.to)
            );
            
            require(success, "Failed to buy");
        }
    }
    
}
