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

all: training_text.txt grc.word.txt grc.freq.txt grc.unicharambigs wordlist

corpus:
	mkdir -p $@
	cd $@ ; wget -O - $(CORPUSURL) \
	| zcat | tar x

wordlist: corpus
	wordlistfromperseus.sh corpus > $@

grc.word.txt grc.freq.txt: wordlist
	wordlistparse.sh grc.word.txt grc.freq.txt < $<

seed:
	dd if=/dev/urandom of=$@ bs=1024 count=1536

training_text.txt: allchars.txt grc.word.txt seed
	makegarbage.sh allchars.txt grc.word.txt seed > $@

unicharambigs.accent:
	accentambigs > $@

unicharambigs.breathing: charsforambigs.txt
	breathingambigs $< > $@

unicharambigs.rho: charsforambigs.txt
	rhoambigs $< > $@

unicharambigs.omicronzero: charsforambigs.txt
	omicronzeroambigs.sh $< > $@

grc.unicharambigs: $(AMBIGS)
	echo v1 > $@
	cat $(AMBIGS) >> $@
