PERSEUSDIR = $(HOME)/perseus
SEEDS = seed1 seed2 seed3 seed4 seed5

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

all: grc.traineddata

getdeps:
	curl -L https://community.dur.ac.uk/nick.white/grctraining/wordlist.bz2 | bzcat > wordlist
	curl -L https://community.dur.ac.uk/nick.white/grctraining/pngbox.tar.bz2 | bzcat | tar x
	touch $@

wordlist:
	wordlistfromperseus.sh $(PERSEUSDIR) > $@

extras/all-words extras/freq-words: wordlist
	mkdir -p extras
	wordlistparse.sh extras/all-words extras/freq-words < $<

garbage: allchars.txt extras/all-words $(SEEDS)
	mkdir -p extras
	makegarbage.sh allchars.txt extras/all-words $(SEEDS) > $@

unicharambigs.accent:
	accentambigs > $@

unicharambigs.breathing: charsforambigs.txt
	breathingambigs $< > $@

unicharambigs.rho: charsforambigs.txt
	rhoambigs $< > $@

unicharambigs.omicronzero: charsforambigs.txt
	omicronzeroambigs.sh $< > $@

extras/grc.unicharambigs: $(AMBIGS)
	mkdir -p extras
	echo v1 > $@
	cat $(AMBIGS) >> $@

$(SEEDS):
	dd if=/dev/urandom of=$@ bs=1024 count=1024

extras/grc.config: grc.config
	sed "2i# Built `date +%F` with `tesseract --version 2>&1|head -n 1`" < $< > $@

grc.traineddata: getdeps extras/all-words extras/freq-words extras/grc.unicharambigs extras/grc.config number-list punc-list
	cp number-list punc-list font_properties extras/
	combinetraining-v3.sh pngbox extras
	echo "Built training file $@"
