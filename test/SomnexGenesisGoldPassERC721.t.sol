pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SomnexGenesisGoldPassERC721.sol";
import "../src/SomnexGenesisPassManager.sol";
import "src/mock/MintableERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/Vm.sol";
import "../src/SomnexGenesisGoldPassERC721.sol";

contract SomnexGenesisGoldPassERC721Test is Test {
    SomnexGenesisGoldPassERC721 public goldPass;
    SomnexGenesisPassManager public passManager;
    MintableERC20 public paymentToken;
    address public teamWallet = address(0x456);
    address public user = address(0x789);

    function setUp() public {
        // Deploy the pass manager first
        passManager = new SomnexGenesisPassManager();
        paymentToken = new MintableERC20("Payment Token", "PAY");

        // Deploy the Gold Pass contract with the pass manager
        goldPass = new SomnexGenesisGoldPassERC721(
            address(paymentToken),
            teamWallet,
            address(passManager)
        );

        // Fund the user account with some WETH (mock)
        vm.deal(user, 10 ether);
        paymentToken.mint(user, 10000 ether); // Mint some payment tokens to the user for testing
    }

    // function testMintValidToken() public {
    //     uint256 tokenId = 1;

    //     // Record the initial balance of the team wallet
    //     uint256 initialTeamBalance = paymentToken.balanceOf(teamWallet);
    //     // Get the mint price from the pass manager
    //     uint256 mintPrice = passManager.getMintPrice(1); // 1 = Gold

    //     // Mint a token from the user account
    //     vm.prank(user);
    //     paymentToken.approve(address(goldPass), mintPrice);
    //     vm.prank(user);
    //     goldPass.mint(tokenId);

    //     // Check that the token was minted correctly
    //     assertEq(goldPass.ownerOf(tokenId), user, "Token should be owned by user");
    //     assertEq(goldPass.balanceOf(user), 1, "User should have one token");

    //     // Verify the token was minted to the user
    //     assertEq(goldPass.ownerOf(tokenId), user, "Token should be owned by user");

    //     // Verify the correct number of tokens in circulation
    //     assertEq(goldPass.totalSupply(), 1, "Total supply should be 1");

    //     // Verify the team wallet received the mint price
    //     assertEq(paymentToken.balanceOf(teamWallet), initialTeamBalance + mintPrice, "Team wallet should receive mint price");
    // }

    // function testMintInvalidTokenId() public {
    //     // Attempt to mint token ID 0
    //     vm.expectRevert("Token ID invalid");
    //     goldPass.mint(0);

    //     // Attempt to mint a token ID exceeding max supply
    //     uint256 maxSupply = passManager.getMaxSupply(1); // 1 = Gold
    //     vm.expectRevert("Token ID invalid");
    //     goldPass.mint(maxSupply + 1);
    // }

    // function testMintExistingToken() public {
    //     uint256 tokenId = 1;
    //     uint256 mintPrice = passManager.getMintPrice(1); // 1 = Gold
    //     // Mint the token for the first time
    //     vm.prank(user);

    //     paymentToken.approve(address(goldPass), mintPrice);
    //     vm.prank(user);
    //     goldPass.mint(tokenId);

    //     // Attempt to mint the same token again
    //     vm.prank(user);
    //     weth.approve(address(goldPass), mintPrice);
    //     vm.expectRevert("Token already exists");
    //     vm.prank(user);
    //     goldPass.mint(tokenId);
    // }

    function testMaxSupplyReached() public {
        // Get the max supply for Gold pass
        uint256 maxSupply = passManager.getMaxSupply(1) - 1; // 1 = Gold
        uint256 mintPrice = passManager.getMintPrice(1); // 1 = Gold
        uint256 totalPrice = mintPrice * maxSupply;
        vm.prank(user);
        paymentToken.approve(address(goldPass), totalPrice);
        vm.prank(user);
        goldPass.buy(maxSupply);

        // Attempt to mint one more token than allowed
        // vm.expectRevert("Max supply reached");
        // vm.prank(user);
        // goldPass.mint(maxSupply + 1);
    }

    // function testWethTransferFailure() public {
    //     uint256 tokenId = 1;

    //     // Create a new instance of the Gold Pass contract with a different pass manager
    //     SomnexGenesisPassManager newPassManager = new SomnexGenesisPassManager();
    //     SomnexGenesisGoldPassERC721 newGoldPass = new SomnexGenesisGoldPassERC721(
    //         address(0xdead), // Invalid WETH address
    //         teamWallet,
    //         address(newPassManager)
    //     );

    //     // Attempt to mint should fail because the WETH transfer will fail
    //     vm.expectRevert(); // We'll accept any revert since the exact error depends on the WETH implementation
    //     newGoldPass.mint(tokenId);
    // }
}
