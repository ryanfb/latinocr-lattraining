#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0 chars.txt

Outputs lines for a Tesseract unicharambigs file changing
any final sigma follewed by a character (and therefore not
at the end of a word) to a normal sigma."

test $# -ne 1 && echo "$usage" && exit 1

cat "$1" | while read i; do
	printf "2\t%s %s\t2\t%s %s\t1\n" 'ς' $i 'σ' $i
done
