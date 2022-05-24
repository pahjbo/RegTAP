=================
RegTAP Validation
=================

:Release: 2022-06
:Author: Markus Demleitner
:Email: gavo@ari.uni-heidelberg.de


This is a validation suite for a Relational Registry engine.

**Important**: Do *not* ingest these records into a live, public searchable
registry.  While they contain completely bogus information, they are
derived from actual records and might be found by all kinds of sensible
queries.

The intended use is to ingest the records into an *empty* relational
registry on a private development system and run the validation queries
against this service.

The validation suite consists of a set of (fake) VOResource records
wrapped into OAI-PMH responses and a set of queries and expected
responses, serialized into JSON.

We recommend ingesting the sample records using the same mechanism as
used by the live registry; in that way, the validation works as
designed, i.e., testing both several aspects of the ingestion and of the
ADQL engine.

This software is maintained in the IVOA's repo on github,
https://github.com/ivoa-std/RegTAP/tree/master/validator

It can also be found on the web at https://docs.g-vo.org/regtap-val

Contact the authors for write privileges.


Releases
--------

* `2019-04 <http://docs.g-vo.org/regtap-val/regtapval-2019-04.tar.gz>`_ 
  – updates for various securityMethod changes
* `2018-07 <http://docs.g-vo.org/regtap-val/regtapval-2018-07.tar.gz>`_ 
  – the first validator for RegTAP 1.1; this will fail on a 1.0 service
* `2014-06 <http://docs.g-vo.org/regtap-val/regtapval-2014-06.tar.gz>`_ 
  – the last validator for RegTAP 1.0 services
* `2014-03 <http://docs.g-vo.org/regtap-val/regtapval-2014-03.tar.gz>`_
* `2014-02 <http://docs.g-vo.org/regtap-val/regtapval-2014-02.tar.gz>`_


Tests Description
-----------------

The tests description is a json-serialized sequence of test suites.
Each suite is an object consisting of a *title* and an array of *tests*.
The current test runner disregards the suites; they're convenient
nevertheless to provide some thematic grouping to the tests.

Each *test* is an object consisting of a *title* (string; that's the
main way of identifying the test, so it unique and descriptive), a
*query* (which is a string containing ADQL to be handed through to the
TAP server), as well as the expected result.

The expected result is a bit more complicated.  For one, it must be
handled as containing unicode.  Then, there is a key *expected*, that
is an array of arrays.  The semantics here is that each inner array is a
tuple, and each tuple in the result must be present in the expectation
and vice versa.  This rule reflects that fact that the order of rows
coming back from a database is not in general predictable (and we did
not want to require ordering on all our queries).  The python test
runner implements this by converting rows to tuples and comparing sets
of those.

But RegTAP has some optional features, which complicate testing quite a
bit.  To accomodate these, tests can also contain a *expected-optional*.
With these, the following algorithm applies::

  for each row in the database result:
    if row is in expected:
      remove row from expected
    else:
      if row is not in expected-optional:
        fail with "unexpected result"
      
  if expected is not empty:
    fail with "extra rows returned"


The Test Runner
---------------

The distribution includes a test runner based on python's unittest
framework and TAP.  It depends on GAVO's VOTable package, downloadable
at http://soft.g-vo.org/subpkgs#votable (Debian package:
python-gavovotable; cf. http://soft.g-vo.org/repo)

To run this, simply pass the access URL of the test TAP service.  You
can additionally pass tags.  This is handy when developing tests or
debugging your service -- simply add a::

  "tag": "cur",

to a test definition; after that, you can run::

  python runtests.py http://localhost:8080/tap cur

and only execute the tagged test(s).


Limitations
-----------

* There should be more complex queries exercising the system as a whole.
* As in current RegTAP itself, we only distinguish NULLs and empty
  strings in very few cases.
* No attempt is made to check for dealing with third-party validations.
* Tests involving floats assume one of binary or decimal float
  representation.
* We do not check against any of the common problems occurring with
  incremental harvesting.
* Some of the less-used, optional res_detail keys may still not be
  exercised.
* Nothing around extended_type and extended_schema is exercised
  (examples, anyone?)


Changelog
---------

Since 2014-03:

* RegTAP 1.1 additions and changes; a RegTAP 1.0 service will no longer
  pass these tests.

Since 2014-02:

* Changed test "region of regard is a float" to use more compatible
  two-argument form of round, and to actually yield an interesting
  value.
* Changed test "non-ascii in merged authors" to match required separator
  ";"
* Several changes to be robust against transports confusing empty
  strings and NULLs

Since 2014-03:

* Validation test no longer assumes cap_index enumeration scheme.  Split
  the test in two for clarity and independence of null fiduciality in
  transport.

Since 2014-04:

* Added tests for RegTAP 1.1 features; also rights and security method
  (which are arguably incompatible changes) now are tested against
  1.1 rules rather than 1.0.  To validate 1.0 services, use 2014-04.

Since 2018-07:

* test records actually have non-trivial security methods, and after
  a bit of back and forth there's finally a check for
  authenticated_only.
* Minor editorial changes (like, erm, samle documents that are actually
  XSD-valid...)


License
-------

Copyright 2014-2022 The GAVO Project.

All data and code within this validation suite is released under the
GNU General Public License Version 3, or, at your option, any later
version.

If this actually matters to you, some further cleanup of the resource
records might be required.  Fragments of that material written by third
parties might still be copyrightable.  But they probably are not.

.. vim:tw=72:et:sta
