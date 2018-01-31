
# TradeFinanceCoin Token (TFC) contract

The TradeFinanceCoin Token (TFC) is used by the Trade Finance Market Network for trade financing.

TFC is an ERC20-compatible token built on OpenZeppelin's VestedToken.

### Build

```
$ ./clean.sh

$ ./build.sh

$ ls -al build-contract/
total 176
drwxr-xr-x  18 brad  staff    612 Sep  9 07:38 .
drwxr-xr-x  25 brad  staff    850 Sep  9 07:38 ..
-rw-r--r--   1 brad  staff    743 Sep  9 07:38 TFCToken-bundled_sol_BasicToken.abi
-rw-r--r--   1 brad  staff   1182 Sep  9 07:38 TFCToken-bundled_sol_BasicToken.bin
-rw-r--r--   1 brad  staff   1586 Sep  9 07:38 TFCToken-bundled_sol_ERC20.abi
-rw-r--r--   1 brad  staff      0 Sep  9 07:38 TFCToken-bundled_sol_ERC20.bin
-rw-r--r--   1 brad  staff    731 Sep  9 07:38 TFCToken-bundled_sol_ERC20Basic.abi
-rw-r--r--   1 brad  staff      0 Sep  9 07:38 TFCToken-bundled_sol_ERC20Basic.bin
-rw-r--r--   1 brad  staff  11060 Sep  9 07:38 TFCToken-bundled_sol_TFCToken.abi
-rw-r--r--   1 brad  staff  19670 Sep  9 07:38 TFCToken-bundled_sol_TFCToken.bin
-rw-r--r--   1 brad  staff   1815 Sep  9 07:38 TFCToken-bundled_sol_LimitedTransferToken.abi
-rw-r--r--   1 brad  staff      0 Sep  9 07:38 TFCToken-bundled_sol_LimitedTransferToken.bin
-rw-r--r--   1 brad  staff      2 Sep  9 07:38 TFCToken-bundled_sol_SafeMath.abi
-rw-r--r--   1 brad  staff    164 Sep  9 07:38 TFCToken-bundled_sol_SafeMath.bin
-rw-r--r--   1 brad  staff   1614 Sep  9 07:38 TFCToken-bundled_sol_StandardToken.abi
-rw-r--r--   1 brad  staff   2522 Sep  9 07:38 TFCToken-bundled_sol_StandardToken.bin
-rw-r--r--   1 brad  staff   4316 Sep  9 07:38 TFCToken-bundled_sol_VestedToken.abi
-rw-r--r--   1 brad  staff  10570 Sep  9 07:38 TFCToken-bundled_sol_VestedToken.bin
```



### Testing

```
$ testrpc

$ truffle test

 Contract: TFCToken
    ✓ initialize contract (1838ms)
    ✓ should start with 0 eth
    ✓ totalSupply is right
    ✓ pre-buy state: cannot send ETH in exchange for tokens
    ✓ pre-buy state: cannot send ETH in exchange for tokens from non-prebuy acc (394ms)
    ✓ pre-buy state: can pre-buy (addr1), vested tokens are properly vested (1009ms)
    ✓ pre-buy state: can pre-buy (addr2), vested tokens are properly vested (982ms)
    ✓ pre-buy state: can pre-buy (addr3), vested tokens are properly vested (1006ms)
    ✓ Change time to crowdsale open
    ✓ Should allow to send ETH in exchange of Tokens (148ms)
    ✓ Shouldnt allow to transfer tokens before end of crowdsale (1432ms)
    ✓ Change time to 40 days after crowdsale
    ✓ should track raised eth
    ✓ Should allow to transfer tokens after end of crowdsale (1430ms)
    ✓ call grantVested() (122ms)
    ✓ vesting schedule - check cliff & vesting afterwards (advances time) (555ms)

  Contract: TFCToken
    ✓ initialize contract (3551ms)
    ✓ should start with 0 eth (51ms)
    ✓ Should allow to send ETH in exchange of Tokens (163ms)
    ✓ Shouldnt allow to transfer tokens before end of crowdsale (1411ms)
    ✓ Reach the hard cap (59ms)
    ✓ Should allow to transfer tokens after end of crowdsale (1427ms)

  Contract: TFCToken
    ✓ initialize contract (3517ms)
    ✓ should start with 0 eth
    ✓ Should allow to send ETH in exchange of Tokens - first day (63ms)
    ✓ Change time to first week bonus
    ✓ Should allow to send ETH in exchange of Tokens - first week (51ms)
    ✓ Change time to first month
    ✓ Should allow to send ETH in exchange of Tokens - regular price (66ms)
    ✓ Change time to end of crowdsale


  30 passing (20s)

```

## Acknowledgements

This project have been influenced by the [AdEx](https://github.com/AdExBlockchain/adex-token) token.


## Email

- TODO

## Slack

- TODO
