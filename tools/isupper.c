/* See LICENSE file for copyright and license details. */

#define usage "isupper c\n\n" \
              "Returns 0 if c is uppercase, and 1 otherwise.\n"

#include <stdio.h>
#include "libutf/utf.h"
#include "util/runetype.h"

int main(int argc, char *argv[]) {
	Rune rune;

	if(argc != 2) {
		fputs(usage, stdout);
		return 2;
	}

	chartorune(&rune, argv[1]);
	if(rune == Runeerror) {
		fputs("Error: Invalid UTF-8.\n", stderr);
		return 2;
	}

	return !isupperrune(rune);
}
