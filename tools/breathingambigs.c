/* See LICENSE file for copyright and license details. */

#define usage "breathingambigs chars.txt\n\n" \
              "Outputs lines for a Tesseract unicharambigs file changing\n" \
              "any illegal breathing to a close accent. It does this by\n" \
              "ensuring that no character is followed by a breathing, except\n" \
              "in diphthongs at the start of words.\n\n" \
              "Replacements are according to these rules:\n" \
              "- Rough breathing is replaced with a grave accent\n" \
              "- Smooth breathing is replaced with an acute accent\n" \
              "- Any breathing with any accent is replaced with a circumflex\n"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libutf/utf.h"

#define LENGTH(X) (sizeof X / sizeof X[0])

#define newline 10
enum { alpha, epsilon, eta, iota, omicron, upsilon, omega,
       alphaiota, etaiota, omegaiota, VOWELEND };

typedef struct {
	int nobreathing;
	int breathings[9];
	int replacements[9];
	int uppernobreathing;
} Vowelvariants;

/* diphthongs are made of a hard vowel followed by a soft vowel
 * (or an upsilon followed by an iota, which needs to be special cased) */
int hardvowels[] = { alpha, epsilon, eta, omicron, omega, VOWELEND };
int softvowels[] = { iota, upsilon, VOWELEND };

Vowelvariants vowelalts[] = {
	{0x03B1, {0x1F00, 0x1F01, 0x1F02, 0x1F03,    /* alpha */
	          0x1F04, 0x1F05, 0x1F06, 0x1F07, 0},
	         {0x1F71, 0x1F70, 0x1FB6, 0x1FB6,
	          0x1FB6, 0x1FB6, 0x1FB6, 0x1FB6, 0},
	         0x0391},
	{0x03B5, {0x1F10, 0x1F11, 0x1F12, 0x1F13,    /* epsilon */
	          0x1F14, 0x1F15, 0, 0, 0},
	         {0x1F73, 0x1F72, 0x1F73, 0x1F72,
	          0x1F73, 0x1F72, 0, 0, 0},
	         0x0395},
	{0x03B7, {0x1F20, 0x1F21, 0x1F22, 0x1F23,    /* eta */
	          0x1F24, 0x1F25, 0x1F26, 0x1F27, 0},
	         {0x1F75, 0x1F74, 0x1FC6, 0x1FC6,
	          0x1FC6, 0x1FC6, 0x1FC6, 0x1FC6, 0},
	         0x039D},
	{0x03B9, {0x1F30, 0x1F31, 0x1F32, 0x1F33,    /* iota */
	          0x1F34, 0x1F35, 0x1F36, 0x1F37, 0},
                 {0x1F77, 0x1F76, 0x1FD6, 0x1FD6,
	          0x1FD6, 0x1FD6, 0x1FD6, 0x1FD6, 0},
	         0x0399}, 
	{0x03BF, {0x1F40, 0x1F41, 0x1F42, 0x1F43,   /* omicron */
	          0x1F44, 0x1F45, 0, 0, 0},
	         {0x1F79, 0x1F78, 0x1F79, 0x1F78,
	          0x1F79, 0x1F78, 0, 0, 0},
	         0x039F},
	{0x03C5, {0x1F50, 0x1F51, 0x1F52, 0x1F53,   /* upsilon */
	          0x1F54, 0x1F55, 0x1F56, 0x1F57, 0},
	         {0x1F7B, 0x1F7A, 0x1FE6, 0x1FE6,
	          0x1FE6, 0x1FE6, 0x1FE6, 0x1FE6, 0},
	         0x03A5},
	{0x03C9, {0x1F60, 0x1F61, 0x1F62, 0x1F63,   /* omega */
	          0x1F64, 0x1F65, 0x1F66, 0x1F67, 0},
                 {0x1F7D, 0x1F7C, 0x1FF6, 0x1FF6,
	          0x1FF6, 0x1FF6, 0x1FF6, 0x1FF6, 0},
	         0x03A9},
	{0x1FB3, {0x1F80, 0x1F81, 0x1F82, 0x1F83,   /* alphaiota */
	          0x1F84, 0x1F85, 0x1F86, 0x1F87, 0},
	         {0x1FB4, 0x1FB2, 0x1FB7, 0x1FB7,
	          0x1FB7, 0x1FB7, 0x1FB7, 0x1FB7, 0},
	         0x1FBC}, 
	{0x1FC3, {0x1F90, 0x1F91, 0x1F92, 0x1F93,   /* etaiota */
	          0x1F94, 0x1F95, 0x1F96, 0x1F97, 0},
	         {0x1FC4, 0x1FC2, 0x1FC7, 0x1FC7,
	          0x1FC7, 0x1FC7, 0x1FC7, 0x1FC7, 0},
	         0x1FCC},
	{0x1FF3, {0x1FA0, 0x1FA1, 0x1FA2, 0x1FA3,   /* omega-iota */
	          0x1FA4, 0x1FA5, 0x1FA6, 0x1FA7, 0},
	         {0x1FF4, 0x1FF2, 0x1FF7, 0x1FF7,
	          0x1FF7, 0x1FF7, 0x1FF7, 0x1FF7, 0},
	         0x1FFC},
};

int isdiphthong(int letter1, int letter2) {
	int *hard, *soft;
	int *breath;

	for(hard = hardvowels; *hard != VOWELEND; hard++) {
		if(letter1 == vowelalts[*hard].nobreathing ||
		   letter1 == vowelalts[*hard].uppernobreathing) {
			for(soft = softvowels; *soft != VOWELEND; soft++) {
				for(breath = vowelalts[*soft].breathings; *breath; breath++) {
					if(letter2 == *breath) {
						return 1;
					}
				}
			}
		}
	}

	/* case of upsilon iota doesn't follow hard-soft rule */
	if(letter1 == vowelalts[upsilon].nobreathing ||
	   letter1 == vowelalts[upsilon].uppernobreathing) {
		for(breath = vowelalts[iota].breathings; *breath; breath++) {
			if(letter2 == *breath) {
				return 1;
			}
		}
	}

	return 0;
}

/* returns number of runes */
int runestoambigstr(Rune *runes, char *str) {
	int i, l;
	char tmp[BUFSIZ];
	Rune *r;

	for(i=0, r = runes, str[0] = 0; *r; r++, i++) {
		l = runetochar(tmp, r);
		
		if(i != 0) {
			strncat(str, " ", 1);
		}
		strncat(str, tmp, l);
	}

	return i;
}

void printrule(Rune *originals, Rune *replacements) {
	int origlen, repllen;
	char origstr[BUFSIZ], replstr[BUFSIZ];

	origlen = runestoambigstr(originals, origstr);
	repllen = runestoambigstr(replacements, replstr);

	printf("%d	%s	%d	%s	1\n",
	       origlen, origstr, repllen, replstr);
}

int main(int argc, char *argv[]) {
	unsigned int a, i, n;
	int *letter1, *letter2, *replace2;
	int *soft, *hard;
	unsigned int runenum, runepos;
	char buf1[BUFSIZ];
	unsigned int l1;
	FILE *f;
	Rune *runes = NULL;
	Rune origrunes[3], replrunes[3];

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

	/* replace <anything><breathing> with <anything><replacement>
	 * unless <anything><breathing> make a valid diphthong or digraph */
	for(letter1=&runes[0]; *letter1; letter1++, i++) {
		if(*letter1 == newline) {
			continue;
		}

		for(a=0; a<VOWELEND; a++) {
			for(letter2 = vowelalts[a].breathings, replace2 = vowelalts[a].replacements;
			    *letter2 && *replace2; letter2++, replace2++) {

				if(isdiphthong(*letter1, *letter2))
					continue;

				origrunes[0] = *letter1;
				origrunes[1] = *letter2;
				origrunes[2] = 0;

				replrunes[0] = *letter1;
				replrunes[1] = *replace2;
				replrunes[2] = 0;

				printrule(origrunes, replrunes);
			}
		}
	}

	/* replace <char><diphthong-with-breathing> with
	  <char><diphthong-without-breathing> */
	for(letter1=&runes[0]; *letter1; letter1++, i++) {
		if(*letter1 == newline) {
			continue;
		}

		for(hard = hardvowels; *hard != VOWELEND; hard++) {
			for(soft = softvowels; *soft != VOWELEND; soft++) {
				for(a=0; a<LENGTH(vowelalts[*soft].breathings); a++) {
					if(vowelalts[*soft].breathings[a] == 0)
						break;

					origrunes[0] = *letter1;
					origrunes[1] = vowelalts[*hard].nobreathing;
					origrunes[2] = vowelalts[*soft].breathings[a];
					origrunes[3] = 0;

					replrunes[0] = *letter1;
					replrunes[1] = vowelalts[*hard].nobreathing;
					replrunes[2] = vowelalts[*soft].replacements[a];
					replrunes[3] = 0;

					printrule(origrunes, replrunes);
				}
			}
		}

		/* case of upsilon iota doesn't follow hard-soft rule */
		for(a=0; a<LENGTH(vowelalts[iota].breathings); a++) {
			if(vowelalts[iota].breathings[a] == 0)
				break;

			origrunes[0] = *letter1;
			origrunes[1] = vowelalts[upsilon].nobreathing;
			origrunes[2] = vowelalts[iota].breathings[a];
			origrunes[3] = 0;

			replrunes[0] = *letter1;
			replrunes[1] = vowelalts[upsilon].nobreathing;
			replrunes[2] = vowelalts[iota].replacements[a];
			replrunes[3] = 0;

			printrule(origrunes, replrunes);
		}
	}

	return 0;
}
