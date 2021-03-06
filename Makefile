# CORPUSURL = http://www.perseus.tufts.edu/hopper/opensource/downloads/texts/hopper-texts-GreekRoman.tar.gz
# CORPUSURL = http://ancientgreekocr.org/archived/hopper-texts-GreekRoman.tar.gz # backup copy
UTFSRC = tools/libutf/rune.c tools/libutf/utf.c

PERSEUS_CORPUS_GIT_URL = https://github.com/PerseusDL/canonical-latinLit
PERSEUS_CORPUS_GIT_COMMIT = d64416dc084c9fd7d61d5aedf4c465296dc171ae
CLTK_LATIN_PROPER_NAMES_GIT_COMMIT = 771c9fb50c82e73a2287499905a8a8577643b2ce
RIGAUDON_GIT_COMMIT = 3f6292f656bd2920fc8980893ad57fa111153837
RIGAUDON_URL = https://github.com/brobertson/rigaudon/raw/$(RIGAUDON_GIT_COMMIT)/Dictionaries/greek_and_latin.txt

OPENGREEKANDLATIN_REPOS = \
	csel-dev \
	patrologia_latina-dev

all: lat.training_text lat.training_text.unigram_freqs lat.wordlist

corpus:
	rm -rf corpus
	git clone $(PERSEUS_CORPUS_GIT_URL) corpus
	cd corpus && git checkout $(PERSEUS_CORPUS_GIT_COMMIT)

opengreekandlatin:
	mkdir -p $@
	for i in $(OPENGREEKANDLATIN_REPOS); do \
		cd $@; wget -O - https://github.com/OpenGreekAndLatin/$$i/tarball/master | zcat | tar x; \
	done

greek_and_latin.txt:
	wget $(RIGAUDON_URL)

wordlist.opengreekandlatin: tools/wordlistfromperseus.sh tools/striplineswithnonmatchingchars.sh opengreekandlatin
	tools/wordlistfromperseus.sh opengreekandlatin "*.xml" | tools/striplineswithnonmatchingchars.sh allchars.txt > $@

lat.opengreekandlatin.freq.txt: tools/wordlistparsefreq.sh wordlist.opengreekandlatin
	tools/wordlistparsefreq.sh < wordlist.opengreekandlatin > lat.opengreekandlatin.freq.txt

wordlist.perseus: tools/wordlistfromperseus.sh tools/striplineswithnonmatchingchars.sh corpus
	tools/wordlistfromperseus.sh corpus "*-lat*.xml" | tools/striplineswithnonmatchingchars.sh allchars.txt > $@

wordlist.rigaudon: tools/wordlistfromrigaudon.sh greek_and_latin.txt
	tools/wordlistfromrigaudon.sh < greek_and_latin.txt > $@

lat.rigaudon.freq.txt: tools/rigaudonparsefreq.sh wordlist.rigaudon
	tools/rigaudonparsefreq.sh < wordlist.rigaudon > $@

lat.training_text.unigram_freqs: lat.freq.outer.csv
	cut -d',' -f1 $^ | head -n 10000 > $@

lat.rigaudon.word.txt: tools/rigaudonparseword.sh wordlist.rigaudon
	tools/rigaudonparseword.sh < wordlist.rigaudon > $@

lat.perseus.word.txt: tools/wordlistparseword.sh wordlist.perseus
	tools/wordlistparseword.sh < wordlist.perseus > $@

lat.cltk.names.txt:
	curl 'https://raw.githubusercontent.com/cltk/latin_proper_names_cltk/$(CLTK_LATIN_PROPER_NAMES_GIT_COMMIT)/proper_names.txt' | grep -v _ > $@

lat.wordlist: lat.perseus.word.txt lat.rigaudon.word.txt lat.pleiades.word.txt lat.cltk.names.txt
	LC_ALL=C cat $^ | sort | uniq | perl -ane '{ if(!m/[[:^ascii:]]/) { print  } }' > $@

most-common-latin-words.txt:
	wget 'http://kyle-p-johnson.com/assets/most-common-latin-words.txt'

lat.opengreekandlatin.freq.csv: wordlist.opengreekandlatin
	sort < wordlist.opengreekandlatin | uniq -c | awk '{print $$2 "," $$1}' > $@

lat.perseus.freq.csv: wordlist.perseus
	sort < wordlist.perseus | uniq -c | awk '{print $$2 "," $$1}' > $@

lat.rigaudon.freq.csv: wordlist.rigaudon
	cp wordlist.rigaudon lat.rigaudon.freq.csv

lat.cltk.freq.csv: most-common-latin-words.txt
	tr "\\t" , < $^ > $@

lat.freq.csv: lat.cltk.freq.csv lat.rigaudon.freq.csv lat.perseus.freq.csv
	csvjoin -c 1,1,1 $^ | awk -F, '{sum = $$2 + $$4 + $$6 + $$8 ; print $$1 "," sum}' | sort -g -r -t, -k2,2 > $@

lat.freq.outer.csv: lat.cltk.freq.csv lat.rigaudon.freq.csv lat.perseus.freq.csv
	csvjoin --outer -c 1,1,1 $^ | sed -e 's/,,//g' | awk -F, '{sum = $$2 + $$4 + $$6 + $$8 ; print $$1 "," sum}' | sort -g -r -t, -k2,2 > $@

lat.freq.ogl.csv: lat.cltk.freq.csv lat.rigaudon.freq.csv lat.perseus.freq.csv lat.opengreekandlatin.freq.csv
	csvjoin -c 1,1,1,1 $^ | awk -F, '{sum = $$2 + $$4 + $$6 + $$8 ; print $$1 "," sum}' | sort -g -r -t, -k2,2 > $@

lat.freq.ogl.outer.csv: lat.cltk.freq.csv lat.rigaudon.freq.csv lat.perseus.freq.csv lat.opengreekandlatin.freq.csv
	csvjoin --outer -c 1,1,1,1 $^ | sed -e 's/,,//g' | awk -F, '{sum = $$2 + $$4 + $$6 + $$8 ; print $$1 "," sum}' | sort -g -r -t, -k2,2 > $@

lat.opengreekandlatin.word.txt: tools/wordlistparseword.sh wordlist.opengreekandlatin
	tools/wordlistparseword.sh < wordlist.opengreekandlatin > $@

lat.word.all.txt: lat.perseus.word.txt lat.rigaudon.word.txt lat.opengreekandlatin.word.txt lat.pleiades.word.txt lat.cltk.names.txt
	LC_ALL=C cat $^ | sort | uniq | perl -ane '{ if(!m/[[:^ascii:]]/) { print  } }' > $@

seed:
	dd if=/dev/urandom of=$@ bs=1024 count=8192

lat.training_text: tools/makegarbage.sh tools/isupper allchars.txt lat.wordlist seed
	tools/makegarbage.sh allchars.txt lat.wordlist seed > $@

tools/isupper: tools/isupper.c
	$(CC) $(UTFSRC) tools/util/runetype.c $@.c -o $@

clean:
	rm -f lat.training_text lat.training_text.unigram_freqs lat.wordlist
	rm -rf greek_and_latin.txt wordlist.rigaudon corpus wordlist.perseus
