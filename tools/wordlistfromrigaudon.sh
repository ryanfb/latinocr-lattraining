#!/bin/sh
# See LICENSE file for copyright and license details.

usage='Usage: $0

Takes a dictionary in stdin, and outputs all lines after the first line
starting with "et,", inclusive.'

test $# -ne 0 && echo "$usage" && exit 1

export LC_ALL=C # ensure reproducable sorting

awk '{if (hit > 0) {print;}} /^et,/ {print; hit = 1}'
