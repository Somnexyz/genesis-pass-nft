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
    }

    /**
     * @dev Multi-buy function to purchase multiple NFT types in one transaction
     * @param purchases Array of purchase parameters
     * @param weth Address of the WETH token
     * @param passManager Address of the pass manager contract
     */
    function multiBuy(
        PurchaseParams[] calldata purchases,
        IERC20 weth,
        SomnexGenesisPassManager passManager,
        address to
    ) public {
        require(purchases.length > 0, "No purchases specified");
        
        // Calculate total cost first
        uint256 totalCost = 0;
        uint256[] memory mintPrices = new uint256[](purchases.length);
        
        for (uint256 i = 0; i < purchases.length; i++) {
            PurchaseParams calldata purchase = purchases[i];
            require(purchase.amount > 0, "Purchase amount must be greater than zero");
            
            // Get pass type from the NFT contract
            (bool success, bytes memory data) = purchase.nftContract.staticcall(
                abi.encodePacked(bytes4(keccak256(bytes("PASS_TYPE()")))));
                
            require(success, "Failed to get pass type from contract");
            
            uint256 price = passManager.getMintPrice(abi.decode(data, (uint8)));
            mintPrices[i] = price;
            totalCost += price * purchase.amount;
        }

        weth.transferFrom(msg.sender, address(this), totalCost);
        
        // Execute all purchases
        for (uint256 i = 0; i < purchases.length; i++) {
            PurchaseParams calldata purchase = purchases[i];
            
            weth.approve(purchase.nftContract, purchase.amount * mintPrices[i]);
            // Call the buy function on the specific NFT contract
            (bool success, ) = purchase.nftContract.call(
                abi.encodeWithSignature("buy(uint256,address)", purchase.amount, to)
            );
            
            require(success, "Failed to execute buy");
        }
    }
    
    /**
     * @dev Get team wallet address from an NFT contract
     * @param nftContract Address of the NFT contract
     */
    function getTeamWallet(address nftContract) private view returns (address) {
        (bool success, bytes memory data) = nftContract.staticcall(
            abi.encodePacked(bytes4(keccak256(bytes("team()")))));
            
        if (success) {
            return abi.decode(data, (address));
        }
        
        return address(0);
    }
}
