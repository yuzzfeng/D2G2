#!/bin/bash
# Updated author: Ariel Kadouri
# Original author: Rex Tsai <rex.cc.tsai@gmail.com> https://github.com/OsmHackTW/osm2pgsql-docker

export PGPASSWORD=$PG_ENV_POSTGRES_PASSWORD
echo DATADIR=${DATADIR:="/osm/data"}
mkdir -p DATADIR
echo PBF=${PBF:=$DATADIR/$(echo $REGION | grep -o '[^/]*$')-latest.osm.pbf}
HOST=download.geofabrik.de

# For this demo we do not wish to apply any updates
    echo "Database not ready, need to intialize."
    if [[ -f "$PBF" ]]; then
        echo "Using local file at $PBF"
    else
        echo "$PBF File not found, downloading..."
        mkdir -p DATADIR
        wget -O "${PBF}" http://${HOST}/${REGION}-latest.osm.pbf
        echo "Download done"
    fi

    osmium fileinfo $PBF

  # Bounding box seems to have EPSG:4326 data
  # Convert the upper corner of the top north-western file and lower corner of the bottom south-eastern file
  # (687975.901 5338092.305) to (694025.61 5331978.51) for central Munich
  # which becomes (11°31'41.726"  48°10'5.711") to (11°36'24.314"  48°6'41.353")
    osmium extract -b 11.528257,48.168253,11.606754,48.111487 $PBF -o /osm/data/extract.osm.pbf
    PBFX=/osm/data/extract.osm.pbf

    psql --no-password \
        -h $PG_PORT_5432_TCP_ADDR -p $PG_PORT_5432_TCP_PORT \
        -U $PG_ENV_POSTGRES_USER $PG_ENV_POSTGRES_DB


    osm2pgsql -v \
        -k \
        --create \
        --slim \
        --cache 4000 \
        --extra-attributes \
        --output=flex \
        --style /user/local/bin/test.lua \
        --host $PG_PORT_5432_TCP_ADDR \
        --database $PG_ENV_POSTGRES_DB \
        --username $PG_ENV_POSTGRES_USER \
        --port $PG_PORT_5432_TCP_PORT \
        $PBFX

#    osm2pgsql-replication init \
#        --host $PG_PORT_5432_TCP_ADDR \
#        --database $PG_ENV_POSTGRES_DB \
#        --username $PG_ENV_POSTGRES_USER \
#        --port $PG_PORT_5432_TCP_PORT --osm-file $PBFX
#fi