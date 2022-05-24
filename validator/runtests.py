"""
A simple runner for json-based tests against an ADQL/TAP server.

This needs pyVO.
"""

import datetime
import json
import unittest

import pyvo


class QueryTest(unittest.TestCase):
	"""A test running a TAP query against a remote server.

	The serverURL is the "base" access URL, i.e., the parent of sync, async,
	and friends.
	"""
	def __init__(self, serverURL, title, query, expected, 
			expectedOptional=None):
		self.service = pyvo.dal.TAPService(serverURL)
		self.title, self.query = title, query.encode("utf-8")

		self.expected = set(tuple(r) for r in expected)
		if expectedOptional is None:
			self.expectedOptional = expectedOptional
		else:
			self.expectedOptional = set(tuple(r) for r in expectedOptional)

		unittest.TestCase.__init__(self)

	def shortDescription(self):
		return self.title

	def runTest(self):
		found = self.service.run_sync(self.query).to_table()
		data = set(
				tuple(f.isoformat() if isinstance(f, datetime.datetime) else f 
					for f in rec) 
			for rec in found)

		if self.expectedOptional is None:
			self.assertEqual(self.expected, data)

		else:
			expected = self.expected.copy()
			for row in data:
				if row in expected:
					expected.remove(row)
				elif row not in self.expectedOptional:
					raise AssertionError(
						"Extra row(s) from database. Example: %s"%repr(row))

			if expected:
				raise AssertionError("Missing row(s) from database: %s"%repr(expected))


def loadTests(serverURL, srcFile="tests.json", tags=None):
	"""reads test descriptions from srcFile and returns a test suite for 
	them.

	The test descriptions are json-encoded, with the following data structure:

		sequence of suites, each being:
			a dict of "title" 
			and a sequence of "tests", each being:
				a dict of "title"
				and the "query" to run
				and the "expected" result as a sequence of dicts.
	"""
	suite = unittest.TestSuite()

	with open(srcFile) as f:
		for suiteDesc in json.load(f):
			for testDesc in suiteDesc["tests"]:
				if tags and not testDesc.get("tag") in tags:
					continue

				suite.addTest(
					QueryTest(serverURL, 
						testDesc["title"], testDesc["query"], testDesc["expected"],
						testDesc.get("expected-optional")))
	
	return suite


def parseCommandLine():
	import argparse
	parser = argparse.ArgumentParser(
		description="Run tests against a TAP server")
	parser.add_argument("serverURL", type=str, help="TAP access URL of"
		" the server to run the tests against.")
	parser.add_argument("tags", type=str, nargs='*', help="Only process"
		" tests with this tag")
	return parser.parse_args()


def main():
	args = parseCommandLine()
	if args.tags:
		tags = set(args.tags)
	else:
		tags = None

	suite = loadTests(args.serverURL, tags=tags)
	runner = unittest.TextTestRunner()
	runner.run(suite)


if __name__=="__main__":
	main()
