// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./CharacterFactory.sol";

struct CharacterTraits {
    uint256 sex;
    uint256 class;
}

// Can receive ERC721/ERC1155/ERC20
contract Character is IERC721Receiver, ERC1155Holder {
    error AlreadyInit();
    error BadSignature();
    error TxFailed();

    CharacterFactory factory;

    bool initialized;
    uint256 public nonce;
    uint256 public chainId;

    uint256 public tokenId;
    // TODO: parse token traits and store individually?
    CharacterTraits public tokenTraits;

    event EthDeposit(uint256 amount, address sender);
    event TxMade(address to, uint256 value, bytes txData);

    // TODO: add store for character levels/strengths (random on mint or all start lvl1)?
    constructor() payable {}

    /// @notice splits the uint256 traits into specific traits
    /// @dev sex (0 = male, 1 = female), class (0 = warrior, 1 = mage, 2 = archer, 3 = ...TODO:)
    /// @param traits uint256 from the L1 ERC721 contract
    /// @return CharacterTraits sex and class of the character
    function generateTraits(
        uint256 traits
    ) public view returns (CharacterTraits memory) {
        uint256 sex;
        uint256 class = traits % 7;
        if (traits % 2 == 0) {
            sex = 1;
        }
        return CharacterTraits(sex, class);
    }

    /// @notice intialize the character instance
    /// @param id the token id this character is linked to
    /// @param traits the number which corresponds to the characters traits
    /// @param factoryAddress the address of the factory contract which deployed this contract
    function initializer(
        uint256 id,
        uint256 traits,
        address factoryAddress
    ) external payable {
        if (initialized) revert AlreadyInit();
        tokenId = id;
        tokenTraits = generateTraits(traits);
        factory = CharacterFactory(factoryAddress);

        initialized = true;
    }

    /// @notice make a tx from the character
    /// @param to the destination for the transaction
    /// @param value the amount of ether sent with the
    /// @param transaction the tx data to be sent
    /// @param sig owner signature of hashed (transaction, deadline timestamp, nonce)
    function executeTx(
        address to,
        uint256 value,
        bytes calldata transaction,
        bytes calldata sig
    ) external {
        /// this could be replaced with account abstracted tx
        bytes32 ethMsg = getEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    block.chainid,
                    address(this),
                    to,
                    value,
                    transaction,
                    nonce
                )
            )
        );
        address signer = ECDSA.recover(ethMsg, sig);
        // check msg signer is current owner of the contract
        if (signer != factory.characterAddressToOwner(address(this)))
            revert BadSignature();

        ++nonce;
        (bool success, ) = to.call{value: value}(transaction);
        if (!success) revert TxFailed();

        emit TxMade(to, value, transaction);
    }

    /// @notice helper function to recreate an eth signed message hash
    /// @param messageHash the already hashed content of the message
    /// @return the hash of the message signed as an ethereum message
    function getEthSignedMessageHash(
        bytes32 messageHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    messageHash
                )
            );
    }

    /// @notice allows wallet to receive ERC721 tokens (desired?)
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice allows ether to be sent to the wallet (desired?)
    receive() external payable {
        emit EthDeposit(msg.value, msg.sender);
    }
}
