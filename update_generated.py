#!/usr/bin/env python
# Update all generated sections in RegTAP.html
#
# Generarated sections are between <!-- GENERATED: <command> -->
# and <!-- /GENERATED -->.  They are supposed to contain the output of
# <command>.  <command> get shell-expanded, but since it gets executed
# anyway, it's not even worth doing shell injection.
#
# When this script finishes, it either has updated all sections or
# stopped with an error message of a failed command, in which case the
# original file is unchanged.
#
# Why no processing instruction or the like?  Well, I didn't want
# some XML processor execute arbitrary commands.  This script, at least,
# will only be used on RegTAP.html, and even there probably
# not.

import re
import subprocess
import sys

S_NAME = "RegTAP.html" # and don't you dare make that generic...

def ExecError(Exception):
	def __init__(self, command, stderr):
		Exception.__init__("Failed command %s"%repr(command))
		self.command, self.stderr = command, stderr


def processOne(matchObj):
	command = matchObj.group("command")
	print "Executing %s"%command
	f = subprocess.Popen(command, shell=True,
		stdout=subprocess.PIPE, stderr=subprocess.PIPE,
		close_fds=True, bufsize=-1)
	stdout, stderr = f.communicate()

	if f.returncode!=0:
		raise ExecError(command, stderr)
	return ("<!-- GENERATED: %s -->\n"%(command.strip())
		+stdout
		+"\n<!-- /GENERATED -->")


def processAll(content):
	return re.sub(r"(?s)<!--\s+GENERATED:\s+(?P<command>.*?)-->"
		".*?"
		r"<!--\s+/GENERATED\s+-->", 
		processOne,
		content)


def main():
	with open(S_NAME) as f:
		content = f.read()
	
	try:
		content = processAll(content)
	except ExecError, ex:
		sys.stderr.write("Command %s failed.  Message below.  Aborting.\n"%
			ex.command)
		sys.stderr.write(ex.stderr+"\n")
		sys.exit(1)
	
	with open(S_NAME, "w") as f:
		f.write(content)


if __name__=="__main__":
	main()
