#!/bin/bash

echo "$0: Start: $(date)"

echo "Viewing the PostgreSQL Client Version"

psql -Version

echo "Viewing the PostgreSQL Server Version"

export PGPASSWORD='citydb'
echo "Edit database"
psql -h host.docker.internal -p 7778 -d citydb -U citydb -f edit-citydb-bavaria.sql;

#TODO: Review shp import
#echo "Import shapefile"
#shp2pgsql -d -s 25832 Radwege.shp public.bikelanes | psql -h host.docker.internal -p 7778 -d citydb -U citydb;

echo "$0: End: $(date)"