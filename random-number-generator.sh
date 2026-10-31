#!/bin/bash
# Version 1.0 Writes rows of random numbers to file.txt
# Version 1.1 Fixed undefined variable and overwritten loop counter, numbers now come from /dev/urandom

OUTFILE="file.txt"
ROWS=20
MAX_PER_ROW=7

for ((i = 1; i <= ROWS; i++)); do
    # 1..MAX_PER_ROW numbers in this row
    count=$(( $(od -An -N2 -tu2 /dev/urandom) % MAX_PER_ROW + 1 ))

    # 4 random bytes per number from /dev/urandom, xargs joins them with single spaces
    od -An -N$((count * 4)) -tu4 /dev/urandom | xargs >> "$OUTFILE"
done

echo "Written $ROWS rows to $OUTFILE"
