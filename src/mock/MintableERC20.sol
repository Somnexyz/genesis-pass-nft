// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract MintableERC20 is ERC20Permit {
	address public minter;

	constructor(
		string memory name,
		string memory symbol
	) ERC20Permit(name) ERC20(name, symbol) {
		minter = msg.sender;
	}

	/**
	 * @dev Function to mint tokens by minter
	 * @param to The account to mint tokens.
	 * @param value the amount of tokens to mint.
	 * @return A boolean that indicates if the operation was successful.
	 */
	function mint(address to, uint256 value) public returns (bool) {
    require(minter == msg.sender, "Only minter can mint tokens");
		_mint(to, value);
    return true;
	}
}
