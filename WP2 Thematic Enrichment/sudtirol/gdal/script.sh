#!/bin/sh

PG_CONN='"host=host.docker.internal user=citydb dbname=sudtirol_db password=citydb port=7777"'
WFS_CART_URL=https://geoservices3.civis.bz.it/geoserver/gvcc-Cartography/ows?service=wfs&version=2.0.0&request=getCapabilities
ogr2ogr -f "PostgreSQL" PG:"host=host.docker.internal user=citydb dbname=sudtirol_db password=citydb port=7777" -nln construction_01k -a_srs EPSG:25832 WFS:$WFS_CART_URL gvcc-Cartography:ConstructionAreas-01k
ogr2ogr -f "PostgreSQL" PG:"host=host.docker.internal user=citydb dbname=sudtirol_db password=citydb port=7777" -nln roofarea_01k -a_srs EPSG:25832 WFS:$WFS_CART_URL gvcc-Cartography:RoofAreasScale-01k