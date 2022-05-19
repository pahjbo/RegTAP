"""
Run all examples given in RegTAP.html and shout if any
of them raises an error or returns no records.

This assumes that the examples to run are in lstlisting environments
that are immediately preceded by a CHECK_HERE comment.  Everything
is 

This requires the pyvo.

Set the TAP_ACCESS_URL environment variable to a TAP server implementing
the relational registry.
"""

import os
import re
import sys
import warnings

import pyvo

TAP_ACCESS_URL = os.environ.get("TAP_ACCESS_URL", "https://dc.g-vo.org/tap")


def iter_examples(f):
	accumulator, state = [], "scanning"
	cur_subsection = None

	for ct, ln in enumerate(f.readlines()):
		if state=="scanning":
			if ln.startswith("%CHECK_HERE"):
				state = "skipping"
			elif ln.startswith("\\subsection"):
				cur_subsection = re.search(r"\{([^}]*)\}", ln).group(1)

		elif state=="skipping":
			if ln.startswith("\\begin{lstlisting}"):
				state = "accumulating"
			else:
				raise Exception("Line %d: Spurious CHECK_HERE"%ct)

		elif state=="accumulating":
			if ln.startswith("\end{lstlisting}"):
				state = "scanning"
				yield cur_subsection, "".join(accumulator)
				accumulator = []
			else:
				accumulator.append(ln)


def main():
	svc = pyvo.dal.TAPService(TAP_ACCESS_URL)
	with open("RegTAP.tex") as f:
		for title, sample_query in iter_examples(f):
			try:
				result = svc.run_sync(sample_query).to_table()
				if not len(result):
					print(f"WARNING: Example returned no records in sect. '{title}'")
			except Exception as ex:
				print(f"ERROR: Example went bad in sect. {title}")
				print(ex)
				sys.exit(1)
	

if __name__=="__main__":
	try:
		warnings.filterwarnings("ignore", category=pyvo.dal.DALOverflowWarning)
	except AttributeError:
		# not warning against overflows yet
		pass
	main()
