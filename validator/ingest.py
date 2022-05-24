"""
Ingests the data in res into the rr schema on the test database.

This must run in the record directory's parent.  It will only work if
the DaCHS test suite has run at least once, and its config matches the
one given in test-gavorc here.
"""

import os
import warnings
import shutil
import subprocess
import sys

opj = os.path.join


TEST_BASE = os.getcwd()
originalEnvironment = os.environ.copy()
os.environ["GAVOCUSTOM"] = "/invalid"
os.environ["GAVOSETTINGS"] = opj(TEST_BASE, "test-gavorc")
os.environ["GAVO_OOTTEST"] = "dontcare"

from gavo.helpers import testhelpers

from gavo import api
from gavo import utils
from gavo.protocols import oaiclient, tap

api.LoggingUI(api.ui)

RRSRC = "http://svn.ari.uni-heidelberg.de/svn/gavo/hdinputs/rr/"
FAKED_REGISTRY = "ivo://x-invalid-test/registry"


def ensureResdir():
	with utils.in_dir(api.getConfig("inputsDir")):
		if os.path.exists("rr"):
			with utils.in_dir("rr"):
				try:
					subprocess.check_call(["svn", "update"])
				except subprocess.CalledProcessError:
					warnings.warn("svn update on rr failed; using existing checkout.")
		else:
			subprocess.check_call(["svn", "checkout",
				RRSRC])

	dataDir = opj(api.getConfig("inputsDir"), "rr", "data")
	if not os.path.exists(dataDir):
		os.makedirs(dataDir)
		os.symlink(os.path.abspath("res"), opj(dataDir, "x-invalid-test"))


def importStuff():
	rd = api.getRD("rr/q")

	with api.getWritableAdminConn() as conn:
		api.makeData(rd.getById("create_registries"), connection=conn)
		conn.execute("insert into rr.registries (ivoid) values (%(ivoid)s)",
			{"ivoid": FAKED_REGISTRY})

		grammar = rd.getById("import").grammar
		grammar._initUserGrammar() # let us overwrite the data pack.
		# monkeypatch the custom grammar such that it just accepts our records
		grammar.dataPack = (
			{"x-invalid-test": FAKED_REGISTRY},
			{"x-invalid-test": FAKED_REGISTRY},
			oaiclient.getCanonicalPrefixes())

		api.makeData(rd.getById("create"), connection=conn)
		api.makeData(rd.getById("import"), connection=conn)
		tap.publishToTAP(rd, conn)


def buildUp():
	ensureResdir()
	importStuff()


def tearDown():
	try:
		rd = api.getRD("rr/q")
		from gavo.user import dropping

		class Opts:
			dropAll = True
			systemImport = False
			force = True

		with api.getWritableAdminConn() as conn:
			dropping._do_dropRD(Opts, "rr/q", conn)
	except Exception as ex:
		sys.stderr.write("Warning: Could not drop RD: %s, skipping teardown.\n"%ex)
	else:
		shutil.rmtree(opj(api.getConfig("inputsDir"), "rr"))


if __name__=="__main__":
	if len(sys.argv)>1 and sys.argv[1]=="-d":
		tearDown()
	else:
		buildUp()
