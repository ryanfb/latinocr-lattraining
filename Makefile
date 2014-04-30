CORPUSURL = http://www.perseus.tufts.edu/hopper/opensource/downloads/texts/hopper-texts-GreekRoman.tar.gz
# CORPUSURL = http://ancientgreekocr.org/archived/hopper-texts-GreekRoman.tar.gz # backup copy
UTFSRC = tools/libutf/rune.c tools/libutf/utf.c

AMBIGS = \
	unicharambigs.accent \
	unicharambigs.anoteleiaaccent \
	unicharambigs.apostrophe \
	unicharambigs.breathing \
	unicharambigs.rho \
	unicharambigs.deltaomicron \
	unicharambigs.misc \
	unicharambigs.omicroniotaalpha \
	unicharambigs.omicronzero \
	unicharambigs.quoteaccent

all: training_text.txt grc.freq.txt grc.word.txt grc.unicharambigs

corpus:
	mkdir -p $@
	cd $@ ; wget -O - $(CORPUSURL) \
	| zcat | tar x

wordlist: tools/wordlistfromperseus.sh tools/betacode2utf8.sh corpus
	tools/wordlistfromperseus.sh corpus > wordlist-betacode
	tools/betacode2utf8.sh wordlist-betacode > $@
	rm wordlist-betacode

grc.freq.txt: tools/wordlistparsefreq.sh wordlist
	tools/wordlistparsefreq.sh < wordlist > $@

grc.word.txt: tools/wordlistparseword.sh wordlist
	tools/wordlistparseword.sh < wordlist > $@

seed:
	dd if=/dev/urandom of=$@ bs=1024 count=1536

training_text.txt: tools/makegarbage.sh tools/isupper allchars.txt grc.word.txt seed
	tools/makegarbage.sh allchars.txt grc.word.txt seed > $@

unicharambigs.accent: tools/accentambigs
	tools/accentambigs > $@

unicharambigs.apostrophe: tools/apostropheambigs.sh
	tools/apostropheambigs.sh > $@

unicharambigs.breathing: tools/breathingambigs charsforambigs.txt
	tools/breathingambigs charsforambigs.txt > $@

unicharambigs.rho: tools/rhoambigs charsforambigs.txt
	tools/rhoambigs charsforambigs.txt > $@

unicharambigs.omicronzero: tools/omicronzeroambigs.sh charsforambigs.txt
	tools/omicronzeroambigs.sh charsforambigs.txt > $@

grc.unicharambigs: $(AMBIGS)
	echo v1 > $@
	cat $(AMBIGS) >> $@

tools/accentambigs: tools/accentambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/breathingambigs: tools/breathingambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/rhoambigs: tools/rhoambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/isupper: tools/isupper.c
	$(CC) $(UTFSRC) tools/util/runetype.c $@.c -o $@

clean:
	rm -f tools/accentambigs tools/breathingambigs tools/rhoambigs tools/isupper
	rm -f unicharambigs.accent unicharambigs.breathing unicharambigs.rho unicharambigs.omicronzero
	rm -f training_text.txt grc.freq.txt grc.word.txt grc.unicharambigs
	rm -rf corpus wordlist wordlist-betacode
