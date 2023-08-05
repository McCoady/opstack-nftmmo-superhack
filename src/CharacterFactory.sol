// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Character.sol";
import "lib/openzeppelin-contracts/contracts//utils/Create2.sol";

contract CharacterFactory {
    error CannotCreateCharacter();

    uint256 public charactersNo;
    mapping(uint256 => address) public tokenidToCharacterAddress;
    mapping(address => address) characterAddressToOwner;

    address systemAddress = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;

    event CharacterCreated(
        address ownerAddress,
        uint256 id,
        uint256 traits,
        address characterAddress
    );

    /// @notice deploys an character instance
    /// @dev only callable by the L2 system address after an NFT is minted on L1
    /// @param owner the address that will control the contract
    /// @param id the token id linked to this contract
    /// @param traits the number representing the characters traits
    /// @return the address of the deployed character contract
    function deployCharacterInstance(
        address owner,
        uint256 id,
        uint256 traits
    ) external payable returns (address) {
        if (msg.sender != systemAddress) revert CannotCreateCharacter();

        bytes32 _salt = keccak256(
            abi.encodePacked(abi.encode(id, address(msg.sender)))
        );

        address characterAddress = payable(
            Create2.deploy(
                msg.value,
                _salt,
                abi.encodePacked(
                    type(Character).creationCode,
                    abi.encode(id, address(this))
                )
            )
        );

        Character char = Character(payable(characterAddress));
    character.initializer(owner, id, traits, address(this));

        emit CharacterCreated(owner, id, traits, address(char));

        return address(wallet);
    }

    /// @notice changes the address which controls the character contract
    /// @dev only callable by the L2 system address after the NFT is transferred on L1
    /// @param id the token id linked to this contract
    /// @param newOwner the address that will now control the contract
    function changeCharacterOwner(uint256 id, address newOwner) external {
        if (msg.sender != systemAddress) revert CannotCreateCharacter();

        address targetCharacter = tokenidToCharacterAddress(id);
        characterAddressToOwner[targetCharacter] = newOwner;
    }
}
