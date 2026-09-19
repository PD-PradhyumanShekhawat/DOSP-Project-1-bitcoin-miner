#!/bin/bash

set -e

erlc -o ../ebin \
    ../src/utils/bitcoin_utils.erl \
    ../src/core/bitcoin_miner.erl \
    ../src/actors/bitcoin_worker.erl \
    ../src/actors/bitcoin_boss.erl \
    bitcoin_benchmark.erl

erl -noshell \
    -pa ../ebin \
    -s crypto \
    -s bitcoin_benchmark run \
    -s init stop