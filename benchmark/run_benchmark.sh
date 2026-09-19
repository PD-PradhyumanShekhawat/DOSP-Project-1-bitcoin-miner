#!/bin/bash

cd "$(dirname "$0")/.."

RESULTS="docs/benchmark_results.csv"
TIME_FILE="benchmark/time.txt"

mkdir -p docs

echo "work_unit,real_seconds,user_seconds,sys_seconds,cpu_seconds,cpu_real_ratio" > "$RESULTS"

for WORK_UNIT in 1000 5000 10000 50000 100000
do
    echo "Testing work unit: $WORK_UNIT"

    /usr/bin/time -p \
        erl -noshell -pa ebin \
        -eval "bitcoin_benchmark:run([{4, $WORK_UNIT, 10000000}]), halt()." \
        > /dev/null 2> "$TIME_FILE"

    REAL=$(awk '/^real / {print $2}' "$TIME_FILE")
    USER=$(awk '/^user / {print $2}' "$TIME_FILE")
    SYS=$(awk '/^sys / {print $2}' "$TIME_FILE")

    CPU=$(awk -v u="$USER" -v s="$SYS" \
        'BEGIN {printf "%.3f", u+s}')

    RATIO=$(awk -v cpu="$CPU" -v real="$REAL" \
        'BEGIN {printf "%.3f", cpu/real}')

    echo "$WORK_UNIT,$REAL,$USER,$SYS,$CPU,$RATIO" >> "$RESULTS"

    echo "  Real: $REAL s"
    echo "  User: $USER s"
    echo "  Sys:  $SYS s"
    echo "  CPU:  $CPU s"
    echo "  Ratio: $RATIO"
    echo
done

echo "Results saved to $RESULTS"