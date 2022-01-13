# ivoatex Makefile.  The ivoatex/README for the targets available.

# short name of your document (edit $DOCNAME.tex; would be like RegTAP)
DOCNAME = RegTAP

# count up; you probably do not want to bother with versions <1.0
DOCVERSION = 1.1

# Publication date, ISO format; update manually for "releases"
DOCDATE = 2019-10-11

# What is it you're writing: NOTE, WD, PR, or REC
DOCTYPE = REC

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
	ps2pdf -dEPSCrop $< $@

%.psfig: %.texfig
	etex $<
	dvips $*
	ps2epsi $*.ps $*.psfig
	rm $*.ps $*.dvi $*.log

AUTHOR_EMAIL=msdemlei@ari.uni-heidelberg.de

-include ivoatex/Makefile

ivoatex/Makefile:
	@echo "*** ivoatex submodule not found.  Initialising submodules."
	@echo
	git submodule update --init
