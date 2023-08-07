// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/solmate/src/tokens/ERC721.sol";

contract UnnamedNft is ERC721 {

    event TokenMinted(address minter, address receiver, uint256 id, uint256 traits);

    uint256 totalSupply;
    // TODO: Max Supply (yes or no?)


    mapping (uint256 => uint256) public tokenIdToTraitString;

    constructor() ERC721("Unnamed", "UNMD") {}



    /// @notice mints a token to address given
    /// @dev if 'to' is a smart contract wallet the user has to make sure they are the owner of the wallet at that address on both L1 & L2
    /// @param to the address that will receive the NFT (and be in control of the linked L2 contract)
    function mint(address to) external payable {
        uint256 tokenId = totalSupply;

        tokenIdToTraitString[tokenId] = generateTraits(tokenId);
        _mint(to, tokenId);


        // TODO: add traits to event
         emit TokenMinted(msg.sender, to, tokenId, 0);
    }

    function generateTraits(uint256 id) internal returns(uint256) {
        // TODO: Create trait generation
        return 0;
    }

    //TODO: hook up real tokenUri
    function tokenURI(uint256 id) public override view returns(string memory) {
        uint256 tokenId = id;
        return "https://www.placeholder.com/";
    }
}