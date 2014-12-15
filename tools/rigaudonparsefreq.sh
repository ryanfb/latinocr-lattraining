#!/bin/sh
# See LICENSE file for copyright and license details.

usage='Usage: $0

Takes a wordlist in stdin, one word per line, and outputs the most
frequent words to stdout.'

test $# -ne 0 && echo "$usage" && exit 1

export LC_ALL=C # ensure reproducable sorting

awk -F, '{OFS=","; if ($2 > 1000) {print $1}}' | sort
