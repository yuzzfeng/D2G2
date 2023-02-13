### Instructions
#### 3D City Importer Exporter
Place all the gml files you want to use in the citygml-data folder. 
```
bash get-munich-citygml.sh
```
Downloads 9 files corresponding to the city of Munich and its surroundings.

#### OSM
Modify the parameter REGION depending on the desired OSM region as per [geofabrik](http://download.geofabrik.de/). Currently importing the region of [Oberbayern](http://download.geofabrik.de/europe/germany/bayern/oberbayern.html) in Bavaria, Germany.

#### Execution
Keep the ports 7778, 8082 free.
Run the following:
```
sudo docker-compose -f docker-compose.munich-citygml.yml up
```
It should take 10 minutes to set up.
Open [localhost:8082](http://localhost:8082/) to see sample queries.

#### (Optional)
If interested only in OSM data, run separately the OSM image:
```
sudo docker-compose -f docker-compose.oberbayern-osm.yml up
```