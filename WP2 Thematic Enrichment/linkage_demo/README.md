### Instructions
#### Execution
Keep the ports 7778, 8082 free.

Clean up any existing containers or images as needed:
```
docker system prune --volumes
docker image prune -a
```

Execute:
```
docker-compose -f docker-compose.linkage.yml up
```
It should take 5 minutes to set up.  
Open [localhost:8082](http://localhost:8082/) to see sample queries.

#### CityGML-OSM Linkage Reification
Reification is used to express linkages OSM and CityGML instances. An example is provided below for matches, a similar one can be constructed for adjacency.

```
 :Association_CityGML_OSM       rdf:type            owl:Class .
 :association_CityGML_OSM1      rdf:type            :Association_CityGML_OSM .
 :membership12345               :matchesCityGML     :cityobject1 .
 :membership12345               :matchesOSM         lgdo:osm_id1 .
```

### Mofidying the demo with different data
#### 3D City Importer Exporter
Place all the gml files you want to use in the citygml-data folder. If more files are desired vs. the demo, navigate to the citygml-data folder, modify the range of [get-munich-citygml.sh](citygml-data/get-munich-citygml.sh) and run:
```
bash get-munich-citygml.sh
```
Downloads files corresponding to the range provided for [EPSG:25832](https://epsg.io/25832) from the [Bavarian geoportal](https://geoportal.bayern.de/bayernatlas/?lang=de&topic=ba&bgLayer=atkis&catalogNodes=11&layers=WMS%7C%7COpendata_Auswahl_LoD2%7C%7Chttps:%2F%2Fgeoservices.bayern.de%2Fwms%2Fv1%2Fopendatagrid%7C%7Clod2%7C%7C1.1.1).

#### OSM
Modify the parameter REGION depending on the desired OSM region as per [geofabrik](http://download.geofabrik.de/). Currently OSM script is importing the region of [Oberbayern](http://download.geofabrik.de/europe/germany/bayern/oberbayern.html) in Bavaria, Germany.
If further refinement is needed modify the coordinates of the sub-area within the region as needed in [osm-importer.sh](osm2pgsql/osm-importer.sh) 
Finally, if more OSM entities of points of interest are needed e.g. parks etc. please modify the list of filtered classes in [osm-unitable.lua](osm2pgsql/osm-unitable.lua).

#### CityGML-OSM linkage
If a different file is required for the linkage please modify the files located in the [linkage data folder](linkage_citygml_osm/data.zip).

#### xAL addresses
For different regions (i.e. outside Bavaria) the extraction of the xAL properties might need to be modified in [db edit SQL file](db-edit/edit-citydb-bavaria.sql).
