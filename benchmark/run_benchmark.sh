#!/bin/bash


RESULTS="results/benchmark_results.csv"
TIME_FILE="time.txt"

mkdir -p results

echo "work_unit,\treal_seconds,\tuser_seconds,\tsys_seconds,\tcpu_seconds,\tcpu_real_ratio" > "$RESULTS"

for WORK_UNIT in 1000 5000 10000 50000 100000
do
    echo "Testing work unit: $WORK_UNIT"

    /usr/bin/time -p \
        erl -noshell -pa ../ebin \
        -eval "bitcoin_benchmark:run([{4, $WORK_UNIT, 10000000}]), halt()." \
        > /dev/null 2> "$TIME_FILE"

    REAL=$(awk '/^real / {print $2}' "$TIME_FILE")
    USER=$(awk '/^user / {print $2}' "$TIME_FILE")
    SYS=$(awk '/^sys / {print $2}' "$TIME_FILE")

    CPU=$(awk -v u="$USER" -v s="$SYS" \
        'BEGIN {printf "%.3f", u+s}')

    RATIO=$(awk -v cpu="$CPU" -v real="$REAL" \
        'BEGIN {printf "%.3f", cpu/real}')

    echo "$WORK_UNIT,\t\t\t$REAL,\t\t\t$USER,\t\t\t$SYS,\t\t\t$CPU,\t\t\t$RATIO" >> "$RESULTS"

    echo "  Real: $REAL s"
    echo "  User: $USER s"
    echo "  Sys:  $SYS s"
    echo "  CPU:  $CPU s"
    echo "  Ratio: $RATIO"
done

echo "Results saved to $RESULTS"