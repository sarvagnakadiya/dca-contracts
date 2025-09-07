## DCA-contracts (v1 with 1inch)
```
0x8CeD8Dfa0C800cEa0DA3C67F623b1263AB9F255b
```

```shell
anvil --fork-url $FORK_URL
```

```shell
forge script script/deployDca.s.sol --private-key $PVT_KEY --rpc-url $RPC_URL --broadcast
```

```shell
forge test --rpc-url $RPC_URL -vvvv --match-path test/dca.t.sol
```

```shell
forge verify-contract --watch --chain base \
0x8CeD8Dfa0C800cEa0DA3C67F623b1263AB9F255b \
src/DCA.sol:DCAForwarder \
--verifier etherscan \
--etherscan-api-key $ETHERSCAN_API_KEY \
--constructor-args 000000000000000000000000111111125421ca6dc452d289314280a0f8842a65000000000000000000000000ea380ddc224497dffe5871737e12136d3968af15000000000000000000000000833589fcd6edb6e08f4c7c32d4f71b54bda02913000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004200000000000000000000000000000000000006
```

```
executeSwap
executeNativeSwap
executeSwapWithFee
executeNativeSwapWithFee
batchExecuteSwap
batchExecuteNativeSwap
batchExecuteSwapWithFee
batchExecuteNativeSwapWithFee
```

```
curl --location 'https://api.1inch.dev/swap/v6.0/8453/swap?src=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913&dst=0x4200000000000000000000000000000000000006&amount=100000&from=0x8CeD8Dfa0C800cEa0DA3C67F623b1263AB9F255b&origin=0xEA380ddC224497dfFe5871737E12136d3968af15&slippage=5&disableEstimate=true&referrer=0xe42c136730a9cfefb5514d4d3d06eb27baaf3f08&fee=3' \
--header 'Authorization: Bearer keydaloidhar' \
--header 'accept: application/json' \
--header 'content-type: application/json' \
--header 'Cookie: __cf_bm=COOKIEDALOIDHAR-1752465863-1.0.1.1-eh02HjBR4UdzKy0Ss6A5pS3Z2q7D.38qwi270OJDSQFw00tQLw0vc1zZmiOdShzajRYBLOSScAIzZDw0VxX2l0r0.r0CRMyi6VSajZuKUuw'
```


