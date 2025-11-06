## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


https://github.com/Cyfrin/security-and-auditing-full-course-s23
https://github.com/Cyfrin/foundry-upgrades-cu/blob/main/src/sublesson/SmallProxy.sol
https://docs.soliditylang.org/en/latest/cheatsheet.html

What is a smart contract audit?
https://aws.amazon.com/what-is/sdlc/
https://devguide.owasp.org/en/02-foundations/02-secure-development/
https://github.com/nascentxyz/simple-security-toolkit. 
the rekt test https://blog.trailofbits.com/2023/08/14/can-you-pass-the-rekt-test/
