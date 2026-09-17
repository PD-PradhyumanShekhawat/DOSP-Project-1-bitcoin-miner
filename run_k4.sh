#!/bin/bash

mkdir -p docs

OUTPUT="docs/k4_output.txt"
TIME_FILE="docs/k4_time.txt"
SUMMARY="docs/k4_summary.txt"

echo "Running final k=4 benchmark..."
echo

/usr/bin/time -p \
    erl -noshell -pa ebin \
    -eval 'bitcoin:main(["4"]), halt().' \
    > "$OUTPUT" 2> "$TIME_FILE"

REAL=$(awk '/^real / {print $2}' "$TIME_FILE")
USER=$(awk '/^user / {print $2}' "$TIME_FILE")
SYS=$(awk '/^sys / {print $2}' "$TIME_FILE")

CPU=$(awk -v u="$USER" -v s="$SYS" \
    'BEGIN {printf "%.3f", u+s}')

RATIO=$(awk -v cpu="$CPU" -v real="$REAL" \
    'BEGIN {printf "%.3f", cpu/real}')

COIN_COUNT=$(grep -c '^pr\.shekhawat;' "$OUTPUT")

awk '
/^pr\.shekhawat;[0-9]+[[:space:]]+[0-9a-f]{64}$/ {
    hash=$2
    zeros=0

    for (i=1; i<=length(hash); i++) {
        if (substr(hash,i,1) == "0")
            zeros++
        else
            break
    }

    if (zeros > max_zeros) {
        max_zeros=zeros
        best=$0
    }
}
END {
    print max_zeros > "docs/k4_highest_zero.txt"
    print best >> "docs/k4_highest_zero.txt"
}
' "$OUTPUT"

cat > "$SUMMARY" <<SUMMARY
Final k=4 Results
=================

Coins found: $COIN_COUNT

Real time: $REAL seconds
User time: $USER seconds
System time: $SYS seconds
CPU time: $CPU seconds
CPU/REAL ratio: $RATIO

Highest-zero coin:
SUMMARY

cat docs/k4_highest_zero.txt >> "$SUMMARY"

echo
echo "========================================"
echo "FINAL k=4 RESULTS"
echo "========================================"
cat "$SUMMARY"
echo
echo "Full mining output: $OUTPUT"
echo "Timing data:        $TIME_FILE"
echo "Summary:            $SUMMARY"
