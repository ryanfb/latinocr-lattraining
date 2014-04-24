#!/bin/sh
# See LICENSE file for copyright and license details.

usage='Usage: $0

Takes a wordlist in stdin, one word per line, and outputs the most
frequent words to stdout.'

test $# -ne 0 && echo "$usage" && exit 1

export LC_ALL=C # ensure reproducable sorting

sort | uniq -c | sort -n | awk '{if ($1 > 1000) {print $2}}' | sort
