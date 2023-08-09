// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Character.sol";
import "../src/CharacterFactory.sol";

contract CharacterTest is Test {
    Character public char;
    CharacterFactory public charFactory;

    address system = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;
    address alice = makeAddr("alice");

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

    function testDeployFromSystemAddress() public {
        startHoax(system, system);
        address aliceCharAddress = charFactory.deployCharacterInstance(
            alice,
            0,
            12345
        );

        assertEq(charFactory.tokenIdToCharacterAddress(0), aliceCharAddress);
        assertEq(charFactory.characterAddressToOwner(aliceCharAddress), alice);
        Character aliceChar = Character(payable(aliceCharAddress));
        (uint256 sex, uint256 class) = aliceChar.tokenTraits();
        console.log("Alice Char Sex", sex);
        console.log("Alice Char Class", class);
    }

    function testCannotDeployFromNonSystemAddress() public {
        vm.expectRevert(CharacterFactory.CannotCreateCharacter.selector);
        address aliceCharAddress = charFactory.deployCharacterInstance(
            alice,
            0,
            12345
        );
    }

    function testCannotDeploySameIdTwice() public {
        startHoax(system, system);
        address aliceCharAddress = charFactory.deployCharacterInstance(
            alice,
            0,
            12345
        );

        assertEq(charFactory.tokenIdToCharacterAddress(0), aliceCharAddress);
        assertEq(charFactory.characterAddressToOwner(aliceCharAddress), alice);
        Character aliceChar = Character(payable(aliceCharAddress));
        (uint256 sex, uint256 class) = aliceChar.tokenTraits();
        console.log("Alice Char Sex", sex);
        console.log("Alice Char Class", class);

        vm.expectRevert(CharacterFactory.CharacterIdExists.selector);
        address aliceSecondCharAddress = charFactory.deployCharacterInstance(
            alice,
            0,
            12345
        );
    }
}
