#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0 chars.txt

Outputs lines for a Tesseract unicharambigs file changing
any 0 in a word to an omicron character."

test $# -ne 1 && echo "$usage" && exit 1

omicron="ο"

cat "$1" | while read i; do
	printf "2\t0 $i\t2\t$omicron $i\t1\n"
	printf "2\t$i 0\t2\t$i $omicron\t1\n"
done
