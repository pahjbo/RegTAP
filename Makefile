# ivoatex Makefile.  The ivoatex/README for the targets available.

# short name of your document (edit $DOCNAME.tex; would be like RegTAP)
DOCNAME = RegTAP

# count up; you probably do not want to bother with versions <1.0
DOCVERSION = 1.0

# Publication date, ISO format; update manually for "releases"
DOCDATE = 2014-10-30

# What is it you're writing: NOTE, WD, PR, or REC
DOCTYPE = PR

# Source file for the TeX document (but the main file must always
# be called $(DOCNAME).tex
SOURCES = $(DOCNAME).tex

# List of image files to be included in submitted package 
# (whitespace-separated)
FIGURES = RegTAP-arch.png 

VECTORFIGURES = schema.pdffig

%.pdffig: %.psfig
	ps2pdf -dEPSCrop $*.psfig $*.pdffig

%.psfig: %.texfig
	tex $<
	dvips $*
	ps2epsi $*.ps $*.psfig
	rm $*.ps

include ivoatex/Makefile
