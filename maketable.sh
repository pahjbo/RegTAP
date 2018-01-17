#!/bin/bash
# dump an HTML table containing the major TAP_SCHEMA.column values of the
# table given in the argument to stdout

TAP_ACCESS_URL=${TAP_ACCESS_URL:=http://localhost:8080/tap}
QUERY="SELECT column_name, utype,
	datatype, arraysize, description, xtype
	FROM TAP_SCHEMA.columns as ${1##*.} WHERE table_name='$1' and std=1"

curl -s -FLANG=ADQL -FFORMAT=votable/td -FQUERY="$QUERY" -FREQUEST=doQuery \
	-F_ROWSPERDIV=100 $TAP_ACCESS_URL/sync |\
xsltproc columnstotex.xslt - |\
sed -e 's/_/\\_/g'
