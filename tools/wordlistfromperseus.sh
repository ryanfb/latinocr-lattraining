#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0 perseusdir

Outputs a list of all Greek words encountered in a Perseus
corpus, with their frequency."

test $# -ne 1 && echo "$usage" && exit 1

export LC_ALL=C # ensure reproducable sorting

find "$1" -type f -name '*_gk.xml' | sort | while read i; do
	# Strip XML, separate by word, and feed through tlgu
	# Note this betacode is lowercase, so we uppercase it for tlgu's sake
	cat "$i" \
	| perl -pe 's|<foreign.*?</foreign>||g' \
	| sed '1,/<body>/ d; /<\/body>/,$ d' \
	| sed 's/<[^>]*>//g; s/\&[^;]*;//g' \
	| awk '{for(i=1;i<=NF;i++) {printf("%s\n", $i)}}' \
	| sed '/[0-9]/d; /\[/d; /\]/d' \
	| sed '/[!?"“”<>\r]/d' \
	| sed '/†/d; /ϝ/d' \
	| tr a-z A-Z
done
