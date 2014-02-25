"""
Run all examples given in RegTAP.html and shout if any
of them raises an error or returns no records.

This requires the GAVO VOTable package (http://soft.g-vo.org).

Set the TAP_ACCESS_URL environment variable to a TAP server implementing
the relational registry.
"""

import os

from gavo.utils import StartEndHandler
from gavo import votable
from gavo.votable import tapquery


TAP_ACCESS_URL = os.environ.get("TAP_ACCESS_URL", "http://dc.g-vo.org/tap")


class ExampleChecker(StartEndHandler):

	lastDT = None

	def _end_pre(self, name, attrs, content):
		if attrs.get("class")!="samplequery":
			return
		try:
			job = votable.ADQLSyncJob(TAP_ACCESS_URL, content)
			data, metadata = votable.load(job.run().openResult())
			if not data:
				print "(Example returned no records: '%s')"%self.lastDT
		except tapquery.WrongStatus:
			print "************ Example went bad"
			print "Last title:", self.lastDT
			print "Error message:", job.getErrorFromServer()[:1000]
	
	def _start_div(self, name, attrs):
		if attrs.get("class")=="query-example":
			self.lastDT = attrs["id"]


def main():
	with open("RegTAP.html") as f:
		ExampleChecker().parse(f)

if __name__=="__main__":
	main()
