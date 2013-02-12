PERSEUSDIR = $HOME/perseus

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
	curl https://www.dur.ac.uk/nick.white/grctraining/wordlist.bz2 | bzcat > wordlist
	curl https://www.dur.ac.uk/nick.white/grctraining/pngbox.tar.bz2 | bzcat | tar x
	touch $@

wordlist:
	wordlistfromperseus.sh $(PERSEUSDIR) > $@

extras/all-words extras/freq-words: wordlist
	mkdir -p extras
	wordlistparse.sh extras/all-words extras/freq-words < $<

garbage: allchars.txt extras/all-words
	mkdir -p extras
	makegarbage.sh allchars.txt extras/all-words > $@

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

grc.traineddata: getdeps extras/all-words extras/freq-words extras/grc.unicharambigs grc.config number-list punc-list
	cp grc.config number-list punc-list font_properties extras/
	combinetraining-v3.sh pngbox extras
	echo "Built training file $@"
