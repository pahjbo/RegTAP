"""
Run all examples given in RegTAP.html and shout if any
of them raises an error or returns no records.

This assumes that the examples to run are in lstlisting environments
that are immediately preceded by a CHECK_HERE comment.  Everything
is 

This requires the GAVO VOTable package (http://soft.g-vo.org).

Set the TAP_ACCESS_URL environment variable to a TAP server implementing
the relational registry.
"""

import os
import re

from gavo import votable
from gavo.votable import tapquery


TAP_ACCESS_URL = os.environ.get("TAP_ACCESS_URL", "http://dc.g-vo.org/tap")


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
	with open("RegTAP.tex") as f:
		for title, ex in iter_examples(f):
			try:
				job = votable.ADQLSyncJob(TAP_ACCESS_URL, ex)
				data, metadata = votable.load(job.run().openResult())
				if not data:
					print "(Example returned no records: '%s')"%title
			except tapquery.WrongStatus:
				print "************ Example went bad"
				print "Last title:", title
				print "Error message:", job.getErrorFromServer()[:1000]
	

if __name__=="__main__":
	main()
