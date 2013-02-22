#!/bin/bash
# Dump the table of tables from GAVO's rr schema (which was a prototype
# of the IVOA relational registry schema) to stdout

SELECT_CLAUSE="table_name || 'join', utype, description"
if [ "t$1" = "tstc" ]; then
QUERY="select $SELECT_CLAUSE from tap_schema.tables 
	where table_name like 'rr.stc_%' order by table_name"
else
QUERY="select $SELECT_CLAUSE from tap_schema.tables 
	where table_name like 'rr.%' and not table_name like 'rr.stc%'
	order by table_name"
fi

TAP_ACCESS_URL=${TAP_ACCESS_URL:=http://localhost:8080/tap}
curl -s -FLANG=ADQL -FFORMAT=html -FQUERY="$QUERY" -FREQUEST=doQuery\
	$TAP_ACCESS_URL/sync|\
sed -e 's/title="[^"]*"//g;
	s/class="results"/& frame="all" rules="rows"/g;
	s/join<\/td><td[^>]*>/<br\/>/g;
	s/Table<\/th><th[^>]*>/Table<br\/>/g;'
