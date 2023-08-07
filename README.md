# opstack-nftmmo-superhack
OPStack build allowing an ERC721 contract deployed on L1 to build it's own L2 MMO universe.

## The Stack:
An ERC721 contract with onchain trait data (deployed on L1)

OPStack with the L1 deposit contract replaced with the aforementioned ERC721. The op-node then tracks mint & transfer events.

A smart contract wallet (deployed on the L2) to be controlled by the address of the minter on L1. Contract stores the tokens traits & skills.  Ownership of the SC wallet follows the ownership of the token on L1.

Quests/Marketplaces/Games can be deployed on the L2 that the users can then interact with via their 'character' contract instance.

### BONUS
Account abstraction - transactions could be dealt with the games site backend and takes a small fee from the smart contract wallet when making the transaction to cover tx fee.
This could streamline UX for the player, not have to sign a bunch of wallet transactions and possibly be able to play from different devices without having to import their private key
