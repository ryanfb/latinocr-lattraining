/* See LICENSE file for copyright and license details. */

#define usage "rhoambigs chars.txt\n\n" \
              "Outputs lines for a Tesseract unicharambigs file removing\n" \
              "any illegal breathing on a rho. A rho at the start of a word\n" \
              "should always have a hard breathing, and a double-rho in the\n" \
              "middle of a word may have soft then hard breathing marks over\n" \
              "them.\n\n" \
              "These rules are enforced by ensuring that a rho with a rough\n" \
              "breathing isn't following anything, except a rho with a soft\n" \
              "breathing, and that a rho with a soft breathing must have a\n" \
              "rho with a hard breathing following it.\n\n" \
              "This misses two cases, which is unavoidable due to the inability\n" \
              "to specify word boundries in unicharambigs: the case of\n" \
              "a smooth rho at the end of a word, and the case of a rho at the\n" \
              "at start of a word not having a breathing.\n" 

#include <stdio.h>
#include <stdlib.h>
#include "libutf/utf.h"

unsigned int rho = 0x03C1;
unsigned int smoothrho = 0x1FE4;
unsigned int roughrho = 0x1FE5;

int main(int argc, char *argv[]) {
	unsigned int i, n;
	unsigned int *letter1;
	unsigned int runenum, runepos;
	char buf1[BUFSIZ], buf2[BUFSIZ], buf3[BUFSIZ];
	unsigned int l1, l2, l3;
	FILE *f;
	Rune *runes = NULL;

	if(argc != 2) {
		fputs("usage: " usage, stdout);
		return 1;
	}

	if((f = fopen(argv[1], "r")) == NULL) {
		fprintf(stderr, "Can't open char file: %s\n", argv[1]);
		return 1;
	}
	
	/* copy characters to runes */
	runenum = 0;
	runepos = 0;
	for(i = 0; (n = fread(&buf1[i], 1, sizeof buf1 - i, f)); i = n-i) {
		runenum += utflen(buf1);
		runes = realloc(runes, sizeof(*runes) * (runenum + 1));
		for(n += i, i = 0; (l1 = charntorune(&runes[runepos], &buf1[i], n-i)); i += l1, runepos++);
	}
	runes = realloc(runes, sizeof(*runes) * (runenum + 1));
	runes[runenum] = 0;

	fclose(f);

	/* replace <smoothrho><anything> with <rho><anything> unless
	 * <anything> is <hardrho> */
	for(letter1=&runes[0]; *letter1; letter1++, i++) {
		if(*letter1 == roughrho)
			continue;

		l1 = runetochar(buf1, letter1);
		if(buf1[0] == '\n')
			continue;

		l2 = runetochar(buf2, &smoothrho);
		l3 = runetochar(buf3, &rho);
	
		/* output in this format:
		 * 2	smoothrho letter 2	rho letter	1 */
		fputs("2\t", stdout);
		fwrite(buf2, l2, 1, stdout);
		fputc(' ', stdout);
		fwrite(buf1, l1, 1, stdout);
		fputs("\t2\t", stdout);
		fwrite(buf3, l3, 1, stdout);
		fputc(' ', stdout);
		fwrite(buf1, l1, 1, stdout);
		fputs("\t1\n", stdout);
	}

	/* replace <anything><roughrho> with <anything><rho> unless
	 * <anything> is <smoothrho> */
	for(letter1=&runes[0]; *letter1; letter1++, i++) {
		if(*letter1 == smoothrho)
			continue;

		l1 = runetochar(buf1, letter1);
		if(buf1[0] == '\n')
			continue;

		l2 = runetochar(buf2, &roughrho);
		l3 = runetochar(buf3, &rho);
	
		/* output in this format:
		 * 2	letter roughrho	2	letter rho	1 */
		fputs("2\t", stdout);
		fwrite(buf1, l1, 1, stdout);
		fputc(' ', stdout);
		fwrite(buf2, l2, 1, stdout);
		fputs("\t2\t", stdout);
		fwrite(buf1, l1, 1, stdout);
		fputc(' ', stdout);
		fwrite(buf3, l3, 1, stdout);
		fputs("\t1\n", stdout);
	}

	return 0;
}
