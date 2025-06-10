# deployed from remix
```shell
0x44e567a0c93f49e503900894ecc508153e6fb77c
```
[Basescan](https://basescan.org/address/0x44e567a0c93f49e503900894ecc508153e6fb77c)

# verify command
```shell
forge verify-contract --watch --chain base \
0x44e567a0c93f49e503900894ecc508153e6fb77c \
src/DCAExecutor.sol:DCAExecutor \
--verifier etherscan \
--etherscan-api-key <key> \
--constructor-args 0x0000000000000000000000002626664c2603336e57b271c5c0b26f421741e4810000000000000000000000000000000000000000000000000000000000000064
```

📦src
 ┣ 📂Interfaces
 ┃ ┣ 📜[IDCAExecutor.sol](https://github.com/sarvagnakadiya/dca-contracts/blob/main/src/Interfaces/IDCAExecutor.sol)
 ┃ ┣ [📜ISwapRouter.sol](https://github.com/sarvagnakadiya/dca-contracts/blob/main/src/Interfaces/ISwapRouter.sol)
 ┃ ┗ [📜IWETH9.sol](https://github.com/sarvagnakadiya/dca-contracts/blob/main/src/Interfaces/IWETH9.sol)
 ┗ 📜[DCAExecutor.sol](https://github.com/sarvagnakadiya/dca-contracts/blob/main/src/DCAExecutor.sol)
