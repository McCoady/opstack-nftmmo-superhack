// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Character.sol";
import "../src/CharacterFactory.sol";

contract CharacterTest is Test {
    Character public char;
    CharacterFactory public charFactory;

    function setUp() public {
        char = new Character();
        charFactory = new CharacterFactory();
    }

    function testInitTraits() public {
        char.initializer(0, 123456, address(charFactory));
        (uint256 sex, uint256 traits) = char.tokenTraits();
        console.log(sex);
        console.log(traits);
    }

    function testCannotInitTwice() public {
        char.initializer(0, 123456, address(charFactory));
        vm.expectRevert(Character.AlreadyInit.selector);
        char.initializer(0, 123456, address(charFactory));
    }
}
