#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0 perseusdir filepattern

Outputs a list of all Latin words encountered in a Perseus
corpus, with their frequency."

test $# -ne 2 && echo "$usage" && exit 1

export LC_ALL=C # ensure reproducable sorting

if [[ "$(uname)" == "Darwin" ]] && command -v gsed >/dev/null 2>&1; then
  GPREFIX="g"
fi

CHARS_REGEX="[^$(${GPREFIX}sed -e ':a;N;$!ba;s/\n//g' -e 's!\([]\*\$\/&[]\)!!g' allchars.txt)]\+"
# >&2 echo $CHARS_REGEX

find "$1" -type f -name "$2" | sort | while read i; do
	# Strip XML, separate by word
	cat "$i" \
	| perl -pe 's|<foreign.*?</foreign>||g' \
	| ${GPREFIX}sed '1,/<body>/ d; /<\/body>/,$ d' \
	| ${GPREFIX}sed 's/<note>/ /g; s/<[^>]*>//g; s/\&[^;]*;//g' \
	| awk '{for(i=1;i<=NF;i++) {printf("%s\n", $i)}}' \
	| ${GPREFIX}sed '/[0-9]/d; /\[/d; /\]/d' \
	| ${GPREFIX}sed '/[-\/'"'"'@(){}=~|½£«+*;,.:!?"“”<>ое\r]/d'
done | LC_ALL="" grep -v "$CHARS_REGEX"
