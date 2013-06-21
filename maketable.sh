#!/bin/bash
# dump an HTML table containing the major TAP_SCHEMA.column values of the
# table given in the argument to stdout

TAP_ACCESS_URL=${TAP_ACCESS_URL:=http://localhost:8080/tap}
QUERY="SELECT column_name || ' join', utype,
	datatype, description 
	FROM TAP_SCHEMA.columns WHERE table_name='$1' and std=1"

curl -s -FLANG=ADQL -FFORMAT=html -FQUERY="$QUERY" -FREQUEST=doQuery\
	-F_ROWSPERDIV=100 $TAP_ACCESS_URL/sync |\
sed -e 's/title="[^"]*"//g;
	s/class="results"/& frame="box" rules="rows"/g;
	s/join<\/td><td[^>]*>/<br\/>/g;
	s/Name<\/th><th[^>]*>/Name<br\/>/g;'
