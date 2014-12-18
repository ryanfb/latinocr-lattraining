RIGAUDONURL = https://github.com/brobertson/rigaudon/raw/master/Dictionaries/greek_and_latin.txt
CORPUSURL = http://www.perseus.tufts.edu/hopper/opensource/downloads/texts/hopper-texts-GreekRoman.tar.gz
# CORPUSURL = http://ancientgreekocr.org/archived/hopper-texts-GreekRoman.tar.gz # backup copy
UTFSRC = tools/libutf/rune.c tools/libutf/utf.c
OPENGREEKANDLATIN_REPOS = \
	csel-dev \
	patrologia_latina-dev

AMBIGS = \
	common.unicharambigs \
	long-s.unicharambigs \
	ligatures.unicharambigs \
	orthographic.unicharambigs

all: training_text.txt lat.freq.txt lat.word.txt lat.unicharambigs

corpus:
	mkdir -p $@
	cd $@ ; wget -O - $(CORPUSURL) \
	| zcat | tar x

opengreekandlatin:
	mkdir -p $@
	for i in $(OPENGREEKANDLATIN_REPOS); do \
		cd $@; wget -O - https://github.com/OpenGreekAndLatin/$$i/tarball/master | zcat | tar x; \
	done

greek_and_latin.txt:
	wget $(RIGAUDONURL)

wordlist.opengreekandlatin: tools/wordlistfromperseus.sh opengreekandlatin
	tools/wordlistfromperseus.sh opengreekandlatin "*.xml" > $@

lat.opengreekandlatin.freq.txt: tools/wordlistparsefreq.sh wordlist.opengreekandlatin
	tools/wordlistparsefreq.sh < wordlist.opengreekandlatin > lat.opengreekandlatin.freq.txt

wordlist.perseus: tools/wordlistfromperseus.sh corpus
	tools/wordlistfromperseus.sh corpus "*_lat.xml" > $@

wordlist.rigaudon: tools/wordlistfromrigaudon.sh greek_and_latin.txt
	tools/wordlistfromrigaudon.sh < greek_and_latin.txt > $@

lat.freq.txt: tools/rigaudonparsefreq.sh wordlist.rigaudon
	tools/rigaudonparsefreq.sh < wordlist.rigaudon > $@

lat.rigaudon.word.txt: tools/rigaudonparseword.sh wordlist.rigaudon
	tools/rigaudonparseword.sh < wordlist.rigaudon > $@

lat.perseus.word.txt: tools/wordlistparseword.sh wordlist.perseus
	tools/wordlistparseword.sh < wordlist.perseus > $@

lat.opengreekandlatin.word.txt: tools/wordlistparseword.sh wordlist.opengreekandlatin
	tools/wordlistparseword.sh < wordlist.opengreekandlatin > $@

lat.word.txt: lat.perseus.word.txt lat.rigaudon.word.txt
	LC_ALL=C cat $^ | sort | uniq > $@

lat.word.all.txt: lat.perseus.word.txt lat.rigaudon.word.txt lat.opengreekandlatin.word.txt
	LC_ALL=C cat $^ | sort | uniq > $@

seed:
	dd if=/dev/urandom of=$@ bs=1024 count=8192

training_text.txt: tools/makegarbage.sh tools/isupper allchars.txt lat.word.txt seed
	tools/makegarbage.sh allchars.txt lat.word.txt seed > $@

unicharambigs.accent: tools/accentambigs
	tools/accentambigs > $@

unicharambigs.breathing: tools/breathingambigs charsforambigs.txt
	tools/breathingambigs charsforambigs.txt > $@

unicharambigs.rho: tools/rhoambigs charsforambigs.txt
	tools/rhoambigs charsforambigs.txt > $@

unicharambigs.omicronzero: tools/omicronzeroambigs.sh charsforambigs.txt
	tools/omicronzeroambigs.sh charsforambigs.txt > $@

lat.unicharambigs: $(AMBIGS)
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
	rm -f training_text.txt lat.freq.txt lat.word.txt lat.unicharambigs
	rm -rf greek_and_latin.txt wordlist.rigaudon corpus wordlist.perseus
