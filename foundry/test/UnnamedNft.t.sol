// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/UnnamedNft.sol";

contract UnnamedNftTest is Test {
   UnnamedNft public nft;

    function setUp() public {
        nft = new UnnamedNft(address(this)  );
    }

    function testMint() public {
        nft.mint{value: 0.05 ether}(address(this));
        assertEq(nft.totalSupply(), 1);
        assertEq(nft.ownerOf(0), address(this));
        console.log(nft.tokenIdToTraitString(0));
    }

    function testCannotMintLowPrice() public {
        vm.expectRevert(UnnamedNft.PriceError.selector);
        nft.mint{value: 0.01 ether}(address(this));
    }
    function testCannotMintHighPrice() public {
        vm.expectRevert(UnnamedNft.PriceError.selector);
        nft.mint{value: 0.1 ether}(address(this));
    }
}
