#!/usr/bin/env bash

rm -rf build-contract
mkdir -p build-contract
./bundle.sh ./contracts/TFCToken.sol > TFCToken-bundled.sol
solcjs --optimize --bin -o build-contract TFCToken-bundled.sol
solcjs --optimize --abi -o build-contract TFCToken-bundled.sol
