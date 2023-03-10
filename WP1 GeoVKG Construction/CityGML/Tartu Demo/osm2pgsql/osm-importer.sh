#!/bin/bash
# Updated author: Ariel Kadouri
# Original author: Rex Tsai <rex.cc.tsai@gmail.com> https://github.com/OsmHackTW/osm2pgsql-docker

export PGPASSWORD=$PG_ENV_POSTGRES_PASSWORD
echo DATADIR=${DATADIR:="/osm/data"}
mkdir -p DATADIR
echo PBF=${PBF:=$DATADIR/$(echo $REGION | grep -o '[^/]*$')-latest.osm.pbf}
HOST=download.geofabrik.de

# For this demo we do not wish to apply any updates
#if psql --no-password -h $PG_PORT_5432_TCP_ADDR -U $PG_ENV_POSTGRES_USER $PG_ENV_POSTGRES_DB -c "select * from planet_osm_replication_status;"; then
#    echo "Updating."
#    osm2pgsql-replication update \
#        -v \
#        --host $PG_PORT_5432_TCP_ADDR \
#        --database $PG_ENV_POSTGRES_DB \
#        --username $PG_ENV_POSTGRES_USER \
#        -- -k --style /user/local/bin/custom.style --extra-attributes
#else
    echo "Database not ready, need to intialize."
    if [[ -f "$PBF" ]]; then
        echo "Using local file at $PBF"
    else
        echo "$PBF File not found, downloading..."
        mkdir -p DATADIR
        wget -O /osm/data/estonia-latest.osm.pbf http://download.geofabrik.de/europe/estonia-latest.osm.pbf
        #wget -O "${PBF}" http://download.geofabrik.de/europe/monaco-latest.osm.pbf
        #http://${HOST}/${REGION}-latest.osm.pbf
        echo "Download done"
    fi

    psql --no-password \
        -h $PG_PORT_5432_TCP_ADDR -p $PG_PORT_5432_TCP_PORT \
        -U $PG_ENV_POSTGRES_USER $PG_ENV_POSTGRES_DB \
        -c "CREATE EXTENSION hstore"

    osm2pgsql -v \
        -k \
        --create \
        --slim \
        --cache 4000 \
        --extra-attributes \
        --style /user/local/bin/custom.style \
        --host $PG_PORT_5432_TCP_ADDR \
        --database $PG_ENV_POSTGRES_DB \
        --username $PG_ENV_POSTGRES_USER \
        --port $PG_PORT_5432_TCP_PORT \
        $PBF

    osm2pgsql-replication init \
        --host $PG_PORT_5432_TCP_ADDR \
        --database $PG_ENV_POSTGRES_DB \
        --username $PG_ENV_POSTGRES_USER \
        --port $PG_PORT_5432_TCP_PORT --osm-file $PBF
#fi