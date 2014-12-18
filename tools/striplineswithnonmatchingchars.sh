#!/bin/sh

usage="Usage: $0 charsfile

Strips lines which contain any chars other than those in charsfile."

test $# -ne 1 && echo "$usage" && exit 1

if [[ "$(uname)" == "Darwin" ]] && command -v gsed >/dev/null 2>&1; then
  GPREFIX="g"
fi

CHARS_REGEX="[^$(${GPREFIX}sed -e ':a;N;$!ba;s/\n//g' -e 's!\([]()·<>«»,.\*\$\/&[]\)!!g' -e 's!-!!g' $1)]\+"
>&2 echo $CHARS_REGEX
LC_ALL="" grep -v "$CHARS_REGEX"
