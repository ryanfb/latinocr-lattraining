/* See LICENSE file for copyright and license details */

#define usage "accentambigs\n\n" \
              "Outputs lines for a Tesseract unicharambigs file to state\n" \
              "that any accent or breathing on a character may be replaced\n" \
              "by any other at Tesseract's discretion.\n"

#include <stdio.h>
#include <stdlib.h>
#include "libutf/utf.h"

#define VOWELNUM 10

unsigned int vowelalts[VOWELNUM][20] = {
	{ 0x03B1,                           /* alpha */
	  0x1F00, 0x1F01, 0x1F02, 0x1F03,
	  0x1F04, 0x1F05, 0x1F06, 0x1F07,
	  0x1F70, 0x1F71, 
	  0x1FB0, 0x1FB1, 0x1FB6,
	  0,0,0,0,0,0},
	{ 0x03B5,                           /* epsilon */
	  0x1F10, 0x1F11, 0x1F12, 0x1F13,
	  0x1F14, 0x1F15,
	  0x1F72, 0x1F73,
	  0,0,0,0,0,0,0,0,0,0,0},
	{ 0x03B7,                           /* eta */
	  0x1F20, 0x1F21, 0x1F22, 0x1F23,
	  0x1F24, 0x1F25, 0x1F26, 0x1F27,
	  0x1F74, 0x1F75,
	  0x1FC6,
	  0,0,0,0,0,0,0,0},
	{ 0x03B9,                           /* iota */
	  0x1F30, 0x1F31, 0x1F32, 0x1F33,
	  0x1F34, 0x1F35, 0x1F36, 0x1F37,
          0x1F76, 0x1F77, 0x1FD6, 0x1FD6,
	  0x1FD0, 0x1FD1, 0x1FD2, 0x1FD3,
	  0x1FD6, 0x1FD7,
	  0},
	{ 0x03BF,                           /* omicron */
	  0x1F40, 0x1F41, 0x1F42, 0x1F43,
	  0x1F44, 0x1F45,
	  0x1F78, 0x1F79,
	  0,0,0,0,0,0,0,0,0,0,0},
	{ 0x03C5,                           /* upsilon */
	  0x1F50, 0x1F51, 0x1F52, 0x1F53,
	  0x1F54, 0x1F55, 0x1F56, 0x1F57,
	  0x1F7A, 0x1F7B,
	  0x1FE0, 0x1FE1, 0x1FE2, 0x1FE3,
	  0x1FE6, 0x1FE7,
	  0,0,0},
	{ 0x03C9,                           /* omega */
	  0x1F60, 0x1F61, 0x1F62, 0x1F63,
	  0x1F64, 0x1F65, 0x1F66, 0x1F67,
          0x1F7C, 0x1F7D,
	  0x1FF6,
	  0,0,0,0,0,0,0,0},
	{ 0x1F80, 0x1F81, 0x1F82, 0x1F83,   /* alpha-iota */
	  0x1F84, 0x1F85, 0x1F86, 0x1F87,
	  0x1FB2, 0x1FB3, 0x1FB4, 0x1FB7,
	  0,0,0,0,0,0,0,0},
	{ 0x1F90, 0x1F91, 0x1F92, 0x1F93,   /* eta-iota */
	  0x1F94, 0x1F95, 0x1F96, 0x1F97,
	  0x1FC2, 0x1FC3, 0x1FC4,
	  0x1FC6, 0x1FC7,
	  0,0,0,0,0,0,0},
	{ 0x1FF2, 0x1FF3, 0x1FF4,           /* omega-iota */
	  0x1FF6, 0x1FF7,
	  0x1FA0, 0x1FA1, 0x1FA2, 0x1FA3,   
	  0x1FA4, 0x1FA5, 0x1FA6, 0x1FA7,
	  0,0,0,0,0,0,0},
};

int main(int argc, char *argv[]) {
	int i;
	unsigned int *letter1, *letter2;
	char buf1[BUFSIZ], buf2[BUFSIZ];
	unsigned int l1, l2;

	if(argc != 1) {
		fputs("usage: " usage, stdout);
		return 1;
	}

	for(i=0; i<VOWELNUM; i++) {
		for(letter1 = vowelalts[i]; *letter1; letter1++) {
			for(letter2 = vowelalts[i]; *letter2; letter2++) {
				if(*letter2 == *letter1) {
					continue;
				}
				l1 = runetochar(buf1, letter1);
				l2 = runetochar(buf2, letter2);

				/* output in this format:
				 * 1	letter1 1	letter2	0 */
				fputs("1\t", stdout);
				fwrite(buf1, l1, 1, stdout);
				fputs("\t1\t", stdout);
				fwrite(buf2, l2, 1, stdout);
				fputs("\t0\n", stdout);
			}
		}
	}

	return 0;
}
