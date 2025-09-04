pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SomnexGenesisSilverPassERC721.sol";
import "../src/SomnexGenesisPassManager.sol";

contract SomnexGenesisSilverPassERC721Test is Test {
    SomnexGenesisSilverPassERC721 public silverPass;
    SomnexGenesisPassManager public passManager;
    address public paymentTokenAddress = address(0x123);
    address public teamWallet = address(0x456);
    address public user = address(0x789);

    function setUp() public {
        // Deploy the pass manager first
        passManager = new SomnexGenesisPassManager();
        
        // Deploy the Silver Pass contract with the pass manager
        silverPass = new SomnexGenesisSilverPassERC721(paymentTokenAddress, teamWallet, address(passManager));
        
        // Fund the user account with some WETH (mock)
        vm.deal(user, 10 ether);
    }

    function testMintValidToken() public {
        uint256 tokenId = 1;
        
        // Record the initial balance of the team wallet
        uint256 initialTeamBalance = address(teamWallet).balance;
        
        // Get the mint price from the pass manager (0 = Silver)
        uint256 mintPrice = passManager.getMintPrice(0);
        
        // Mint a token from the user account
        vm.prank(user);
        vm.expectEmit(true, true, true, true);
        silverPass.mint(tokenId);
        
        // Verify the token was minted to the user
        assertEq(silverPass.ownerOf(tokenId), user, "Token should be owned by user");
        
        // Verify the correct number of tokens in circulation
        assertEq(silverPass.totalSupply(), 1, "Total supply should be 1");
        
        // Verify the team wallet received the mint price
        assertEq(address(teamWallet).balance, initialTeamBalance + mintPrice, "Team wallet should receive mint price");
    }

    function testMintInvalidTokenId() public {
        // Attempt to mint token ID 0
        vm.expectRevert("Token ID invalid");
        silverPass.mint(0);
        
        // Attempt to mint a token ID exceeding max supply
        uint256 maxSupply = passManager.getMaxSupply(0); // 0 = Silver
        vm.expectRevert("Token ID invalid");
        silverPass.mint(maxSupply + 1);
    }

    function testMintExistingToken() public {
        uint256 tokenId = 1;
        
        // Mint the token for the first time
        vm.prank(user);
        silverPass.mint(tokenId);
        
        // Attempt to mint the same token again
        vm.expectRevert("Token already exists");
        silverPass.mint(tokenId);
    }

    function testMaxSupplyReached() public {
        // Get the max supply for Silver pass
        uint256 maxSupply = passManager.getMaxSupply(0); // 0 = Silver
        
        // Mint all available tokens
        for (uint256 i = 1; i <= maxSupply; i++) {
            vm.prank(user);
            silverPass.mint(i);
        }
        
        // Attempt to mint one more token than allowed
        vm.expectRevert("Max supply reached");
        vm.prank(user);
        silverPass.mint(maxSupply + 1);
    }

    function testWethTransferFailure() public {
        uint256 tokenId = 1;
        
        // Create a new instance of the Silver Pass contract with a different pass manager
        SomnexGenesisPassManager newPassManager = new SomnexGenesisPassManager();
        newSilverPass = new SomnexGenesisSilverPassERC721(
            address(0xdead), // Invalid payment token address
            teamWallet,
            address(newPassManager)
        );
        
        // Attempt to mint should fail because the WETH transfer will fail
        vm.expectRevert("WETH transfer failed");
        newSilverPass.mint(tokenId);
    }
}
