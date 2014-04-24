#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0 all-words freq-words

Takes a wordlist in stdin, one word per line, and outputs two
files, all-words, containing all words, and freq-words,
containing the most frequent words."

test $# -ne 2 && echo "$usage" && exit 1

export LC_ALL=C # ensure reproducable sorting

a=`sort | uniq -c | sort -n`

echo "$a" | awk '{print $2}' | sort > "$1"
echo "$a" | awk '{if ($1 > 1000) {print $2}}' | sort > "$2"
