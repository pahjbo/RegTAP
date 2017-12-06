#!/bin/bash
# Dump the table of tables from GAVO's rr schema (which was a prototype
# of the IVOA relational registry schema) to stdout

SELECT_CLAUSE="table_name, utype, description"
QUERY="select $SELECT_CLAUSE from tap_schema.tables 
	where table_name like 'rr.%' and not table_name like 'rr.stc%'
	and not table_name='rr.authorities'
	order by table_name"


TAP_ACCESS_URL=${TAP_ACCESS_URL:=http://localhost:8080/tap}
curl -s -FLANG=ADQL -FFORMAT=votable/td -FQUERY="$QUERY" -FREQUEST=doQuery\
	$TAP_ACCESS_URL/sync |\
xsltproc tablestotex.xslt - |\
sed -e 's/_/\\_/g'
