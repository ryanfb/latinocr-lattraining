#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0 allchars wordlist seed

Prints random words which contain each character, repeating
several times. Uses seeds for randomisation (use /dev/random
for real randomness)."

repeat=100

test $# -ne 3 && echo "$usage" && exit 1

charlist="$1"
wordlist="$2"
seed="$3"

tmpseed=`gmktemp`
seednum=0

# make a new random seed by copying a different chunk of the seed file
cp "$seed" "$tmpseed"

for i in `seq $repeat`; do
	# change the random seed by copying the start of the original seed to a different part of it
	seednum=`expr $seednum + 1`
	dd if="$seed" of="$tmpseed" bs=1 count=2048 skip=$seednum conv=notrunc 2> /dev/null
	gshuf --random-source="$tmpseed" "$charlist" | while read a; do

		# change the random seed by copying the start of the original seed to a different part of it
		seednum=`expr $seednum + 1`
		dd if="$seed" of="$tmpseed" bs=1 count=2048 skip=$seednum conv=notrunc 2> /dev/null
		words=`gshuf --random-source="$tmpseed" < "$wordlist" | grep "$a" 2>/dev/null`

		if test $? -eq 0; then
			word=`echo "$words" | gsed 1q`
			# . will match anything, so just print it at end of a random word
			if test "$a" = "."; then
				echo "$word" | awk '{printf "%s. ", $1}'
			else
				echo "$word" | awk '{printf "%s ", $1}'
			fi
		else
			# couldn't find word containing $a, print it on its own,
			# without spaces so it'll be part of other words
			if tools/isupper "$a";then
				# ensure a space before any uppercase letter and
				# append the end of a random word to it to ensure it
				# isn't isolated, as it will always be at the start
				# of a word.
				echo "$a" | awk '{printf " %s", $1}'

				# change the random seed by copying the start of the original seed to a different part of it
				seednum=`expr $seednum + 1`
				dd if="$seed" of="$tmpseed" bs=1 count=2048 skip=$seednum conv=notrunc 2> /dev/null

				word=`gshuf --random-source="$tmpseed" < "$wordlist" | gsed 1q`
				echo "$word" | awk '{printf "%s ", $1}'
			else
				echo "$a" | awk '{printf "%s", $1}'
			fi
		fi

	done
done

printf '\n'

rm -f "$tmpseed"
