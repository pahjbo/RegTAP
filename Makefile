# ivoatex Makefile.  The ivoatex/README for the targets available.

# short name of your document (edit $DOCNAME.tex; would be like RegTAP)
DOCNAME = RegTAP

# count up; you probably do not want to bother with versions <1.0
DOCVERSION = 1.2

# Publication date, ISO format; update manually for "releases"
DOCDATE = 2022-05-19

# What is it you're writing: NOTE, WD, PR, or REC
DOCTYPE = WD

# Source file for the TeX document (but the main file must always
# be called $(DOCNAME).tex
SOURCES = $(DOCNAME).tex role_diagram.pdf gitmeta.tex

# List of image files to be included in submitted package 
# (whitespace-separated)
FIGURES = 

VECTORFIGURES = schema.pdf

AUX_FILES = makeutypes.xslt

all: $(DOCNAME).pdf

schema.pdf: schema.psfig
	ps2pdf -dALLOWPSTRANSPARENCY -dEPSCrop $< $@

%.psfig: %.texfig
	etex $<
	dvips $*
	ps2eps -f $*.ps
	mv  $*.eps $*.psfig
	rm $*.ps $*.dvi $*.log

AUTHOR_EMAIL=msdemlei@ari.uni-heidelberg.de

-include ivoatex/Makefile

ivoatex/Makefile:
	@echo "*** ivoatex submodule not found.  Initialising submodules."
	@echo
	git submodule update --init


# These tests require python3 and pyvo (Debian: python3-pyvo)
test:
	@TAP_ACCESS_URL=http://dc.g-vo.org/tap python3 check_examples.py
