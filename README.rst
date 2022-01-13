Relational Registry, a.k.a., RegTAP
===================================

These are the sources for the IVOA standard used by clients to query the
VO Registry.

The document uses ivoatex_ to build; hence, a simple ``make`` should
give you a pdf, provided you have the ivoatex dependencies installed.

In addition to the usual ivoatex files, there is here, in particular:

* makeutypes.xslt -- the XSLT to generate utypes from VOResource input; there's
  a wrapper around this in the Makefile (this is included in the standard)
* check_examples.py -- runs the embedded examples and complains if
  the TAP server errors out or returns an empty response.  Not needed
  to build the document, see embeeded comments for details.
* gettables.sh, maketable.sh -- helper scripts for generated material
  in the document (make generate).  These assume a TAP server with the rr 
  schema at http://localhost:8080/tap
