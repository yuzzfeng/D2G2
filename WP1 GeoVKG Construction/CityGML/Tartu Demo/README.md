### Goal
For this simple tutorial we will set up 2 VKGs and query them via SPARQL endpoints. The VKGs will include CityGML data, one of the primary targets, and OSM data which will be quite useful in performing integrated query processing.

### Requirements
[Docker](https://www.docker.com/) . Installation [instructions](https://docs.docker.com/engine/install/).
(Optional) Protégé [5.6.0-beta](https://github.com/protegeproject/protege-distribution/releases) and the Ontop 5.0.0 plugin [it.unibz.inf.ontop.protege-5.0.0.jar](https://github.com/ontop/ontop/releases).  
(Optional) [DBeaver](https://dbeaver.io/), Datagrip or another similar database tool for visualizing the data source.


### Clone this repository
On Windows
```
git clone https://github.com/yuzzfeng/D2G2  --config core.autocrlf=input
```
Otherwise, on MacOS and Linux:
```
git clone https://github.com/yuzzfeng/D2G2
```

### Start docker-compose

#### OSM (Estonia) demo and set-up in 2 different terminals
```
docker-compose -f docker-compose.estonia-osm.yml up postgres osm2pgsql
docker-compose -f docker-compose.estonia-osm.yml up ontop
```
These command starts and initializes the database and run osm2pgsql. These 2 commands will populate a PostgreSQL database with OSM data corresponding to the file downloaded from Geofabrik estonia-latest.osm.pbf. Once the database and osm2pgsql are done, we separately launch the SPARQL endpoint from Ontop at http://localhost:8082 .

For this tutorial, we assume that the ports 7779 (used for the database) and 8082 (used by Ontop) are free.

osm2pgsql will map the OSM data to several tables where each object is uniquely identified by an OSM_ID. The tables include:
* planet_osm_line - contains lines: roads, fences, power lines, railroads, and administrative boundaries
* planet_osm_point - contains points: buildings, trees, telephone poles, etc.
* planet_osm_polygon - contains polygon features: land use, buildings, etc.

The tables are mapped onto the virtual knowledge graph and a set of queries are exposed on the endpoint.

#### CityGML (Tartu, Estonia) set-up with preloaded data

```
docker-compose -f docker-compose.tartu.yml up
```
For this tutorial, we assume that the ports 7778 (used for the database) and 8082 (used by Ontop) are free.
Via [3dCityDB](https://www.3dcitydb.org/3dcitydb/3dimpexp/) we have mapped the Tartu CityGML file to the database, and further mapped the database to the vkg.

#### (Optional) CityGML (Tartu, Estonia) without preloaded data

Download [3dCityDBImporter](https://www.3dcitydb.org/3dcitydb/downloads/)
```
java -jar 3DCityDB-Importer-Exporter-4.3.0-Setup.jar
```
Run the 3DCityDB Docker Image
```
docker run --name 3dcitydb -p 7778:5432 -d -e POSTGRES_PASSWORD=3dcitydb -e SRID=3301 3dcitydb/3dcitydb-pg:14-3.2-4.1.0
```
Open 3DCityDBImporter and load Tartu file.

For this tutorial, we assume that the ports 7778 (used for the database) and 8082 (used by Ontop) are free.
Via [3dCityDB](https://www.3dcitydb.org/3dcitydb/3dimpexp/) we have mapped the Tartu CityGML file to the database, and further mapped the database to the vkg.

```
docker-compose -f docker-compose.tartu.yml up ontop
```

### (Optional) Start Protégé
* Run Protégé (run.bat on Windows, run.sh on Mac/Linux)
* Register the PostgreSQL JDBC driver: go to Preferences -> JDBC Drivers and add an entry with the following information
  * Description: postgresql
  * Class Name: org.postgresql.Driver
  * Driver file (jar): /path/to/destination-tutorial/jdbc/postgresql-42.2.8.jar
* Open citygml2.0.owl
* Go to Reasoner and select Ontop 5.0.0 .
