#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0

Outputs lines for a Tesseract unicharambigs file changing
any apostrophe follewed by a vowel without diacritics to a
vowel with a soft breathing mark."

test $# -ne 0 && echo "$usage" && exit 1

omicron="ο"

vowels='
Α Ἀ
Ε Ἐ
Η Ἠ
Ι Ἰ
Ο Ὀ
Ω Ὠ
α ἀ
ε ἐ
η ἠ
ι ἰ
ο ὀ
υ ὐ
'

echo "$vowels" | while read i; do
	test "$i" = "" && continue
	orig=`echo $i | awk '{print $1}'`
	repl=`echo $i | awk '{print $2}'`

	printf "2\t%s %s\t1\t%s\t1\n" '’' $orig $repl
done
