#!/bin/bash
# See LICENSE file for copyright and license details.

usage="Usage: $0 perseusdir

Outputs a list of all Latin words encountered in a Perseus
corpus, with their frequency."

test $# -ne 1 && echo "$usage" && exit 1

export LC_ALL=C # ensure reproducable sorting

if [[ "$(uname)" == "Darwin" ]]; then
  command -v gsed >/dev/null 2>&1 && export GPREFIX="g"
fi

find "$1" -type f -name '*_lat.xml' | sort | while read i; do
	# Strip XML, separate by word
	cat "$i" \
	| perl -pe 's|<foreign.*?</foreign>||g' \
	| ${GPREFIX}sed '1,/<body>/ d; /<\/body>/,$ d' \
	| ${GPREFIX}sed 's/<note>/ /g; s/<[^>]*>//g; s/\&[^;]*;//g' \
	| awk '{for(i=1;i<=NF;i++) {printf("%s\n", $i)}}' \
	| ${GPREFIX}sed '/[0-9]/d; /\[/d; /\]/d' \
	| ${GPREFIX}sed '/[-\/'"'"'@(){}=~|½£«+*;,.:!?"“”<>ое\r]/d' \
	| ${GPREFIX}sed '/καὶ/d'
done
