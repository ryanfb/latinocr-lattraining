# Download UnicodeData.txt from:
# http://www.unicode.org/Public/<version>/ucd/UnicodeData.txt

AWK = awk
UNICODE = 6.1.0

runetypebody.h: mkrunetype.awk UnicodeData-$(UNICODE).txt
	$(AWK) -f mkrunetype.awk UnicodeData-$(UNICODE).txt > $@
