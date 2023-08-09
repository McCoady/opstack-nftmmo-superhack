// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/UnnamedNft.sol";

contract UnnamedNftTest is Test {
    UnnamedNft public nft;

    address alice = makeAddr("alice");

    function setUp() public {
        nft = new UnnamedNft(address(this));
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

    function testOwnerWithdraw() public {
        for (uint256 i; i < 10; ++i) {
            nft.mint{value: 0.05 ether}(address(this));
        }

        uint256 balance = address(this).balance;
        nft.withdraw();
        assertEq(address(this).balance, balance + 0.25 ether);
        assertEq(address(nft).balance, 0.25 ether);
    }

    function testCannotNonOwnerWithdraw() public {
        for (uint256 i; i < 10; ++i) {
            nft.mint{value: 0.05 ether}(address(this));
        }
        startHoax(alice, alice);
        vm.expectRevert("UNAUTHORIZED");
        nft.withdraw();
    }

    function testCannotOwnerWithdrawTwice() public {
        for (uint256 i; i < 10; ++i) {
            nft.mint{value: 0.05 ether}(address(this));
        }

        uint256 balance = address(this).balance;
        nft.withdraw();
        assertEq(address(this).balance, balance + 0.25 ether);
        assertEq(address(nft).balance, 0.25 ether);
        
        vm.expectRevert(UnnamedNft.WithdrawComplete.selector);
        nft.withdraw();
    }

    receive() external payable {}
}
