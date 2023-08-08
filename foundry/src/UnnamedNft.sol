// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/solmate/src/tokens/ERC721.sol";
import "lib/solmate/src/auth/Owned.sol";

contract UnnamedNft is ERC721, Owned {
    error PriceError();
    error WithdrawComplete();

    event TokenMinted(address minter, address receiver, uint256 id, uint256 traits);

    uint256 public totalSupply;
    bool public withdrawn;

    mapping (uint256 => uint256) public tokenIdToTraitString;

    constructor(address owner) ERC721("Unnamed", "UNMD") Owned(owner){}

    /// @notice mints a token to address given
    /// @dev if 'to' is a smart contract wallet the user has to make sure they are the owner of the wallet at that address on both L1 & L2
    /// @param to the address that will receive the NFT (and be in control of the linked L2 contract)
    function mint(address to) external payable {
        if (msg.value != 0.05 ether) revert PriceError();
        uint256 tokenId = totalSupply;

        uint256 traits = generateTraits(tokenId);
        tokenIdToTraitString[tokenId] = traits;
        _mint(to, tokenId);

        ++totalSupply;

         emit TokenMinted(msg.sender, to, tokenId, traits);
    }

    /// @notice creates a pseudorandom nubmer that will be used for the characters traits
    /// @param id the token id of the character
    /// @return pseudorandom trait number
    function generateTraits(uint256 id) internal returns(uint256) {
        // TODO: Replace with better pseudorandom
        return uint256(keccak256(abi.encodePacked(msg.sender, id, block.timestamp))) % 1000000;
    }

    //TODO: hook up real tokenUri
    function tokenURI(uint256 id) public override view returns(string memory) {
        uint256 tokenId = id;
        return "https://www.placeholder.com/";
    }

    /// @notice allows owner to withdraw 50% of the funds raised (other 50% bridged to L2 chain)
    function withdraw() external onlyOwner {
        if (withdrawn) revert WithdrawComplete();
        uint256 withdrawAmount = address(this).balance / 2 - 1;
        (bool sent, bytes memory data) = msg.sender.call{value: withdrawAmount}("");
        require(sent, "Failed to send Ether");
    }

}