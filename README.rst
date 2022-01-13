Relational Registry/RegTAP Source Distribution
==============================================

What's what?

* RegTAP.tex -- the document source code.  This is what you
  should be editing
* makeutypes.xslt -- the XSLT to generate utypes from VOResource input; there's
  a wrapper around this in the Makefile (this is included in the standard)
* Makefile -- document date, version, and status are defined in there.
* check_examples.py -- runs the embedded examples and complains if
  the TAP server errors out or returns an empty response.  Not needed
  to build the document, see embeeded comments for details.
* gettables.sh, maketable.sh -- helper scripts for generated material
  in the document (make generate).  These assume a server with rr at
  http://localhost:8080/tap
