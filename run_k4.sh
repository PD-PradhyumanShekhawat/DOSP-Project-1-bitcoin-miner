#!/bin/bash

set -e

/usr/bin/time -p erl \
    -pa ebin \
    -s crypto \
    -noshell \
    -eval 'bitcoin:main(["4"]).' \
    -s init stop