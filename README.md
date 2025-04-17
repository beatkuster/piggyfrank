## PiggyFrank

**PiggyFrank is an onchain piggy bank that supports achieving saving goals and advances financial literacy for younger generations.**

PiggyFrank consists of:

-   **PiggyBank**: PiggyFrank's smart contract implementation of a piggy bank.
-   **PiggyBankFactory**: Smart contract to deploy piggy banks.

***This project is a prototype and for demonstration purposes only. This code has NOT been security audited. Do not use in production and at your own risk.***

## Usage

### Start local Anvil instance

```shell
$ anvil
```

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

### Deploy

```shell
$ forge script script/DeployPiggyBankFactory.s.sol --rpc-url <your_rpc_url> --broadcast --sender <your_cast_wallet_address>
```

### Cast

```shell
$ cast call <piggybankfactory_address> "getPgbCount()(uint256)"
```