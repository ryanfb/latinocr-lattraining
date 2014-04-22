CORPUSURL = http://www.perseus.tufts.edu/hopper/opensource/downloads/texts/hopper-texts-GreekRoman.tar.gz

AMBIGS = \
	unicharambigs.accent \
	unicharambigs.anoteleiaaccent \
	unicharambigs.breathing \
	unicharambigs.rho \
	unicharambigs.deltaomicron \
	unicharambigs.misc \
	unicharambigs.omicroniotaalpha \
	unicharambigs.omicronzero \
	unicharambigs.quoteaccent

all: training_text.txt grc.word.txt grc.unicharambigs wordlist

corpus:
	mkdir -p $@
	cd $@ ; wget -O - $(CORPUSURL) \
	| zcat | tar x

wordlist: corpus
	wordlistfromperseus.sh corpus > wordlist-betacode
	betacode2utf8.sh wordlist-betacode > $@
	rm wordlist-betacode

# also generates grc.freq.txt
grc.word.txt: wordlist
	wordlistparse.sh grc.word.txt grc.freq.txt < wordlist

seed:
	dd if=/dev/urandom of=$@ bs=1024 count=1536

training_text.txt: allchars.txt grc.word.txt seed
	makegarbage.sh allchars.txt grc.word.txt seed > $@

unicharambigs.accent:
	accentambigs > $@

unicharambigs.breathing: charsforambigs.txt
	breathingambigs charsforambigs.txt > $@

unicharambigs.rho: charsforambigs.txt
	rhoambigs charsforambigs.txt > $@

unicharambigs.omicronzero: charsforambigs.txt
	omicronzeroambigs.sh charsforambigs.txt > $@

grc.unicharambigs: $(AMBIGS)
	echo v1 > $@
	cat $(AMBIGS) >> $@
