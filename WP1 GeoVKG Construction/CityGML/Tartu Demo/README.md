### Requirements
[Docker](https://www.docker.com/)  
(Optional) Protégé [5.6.0-beta](https://github.com/protegeproject/protege-distribution/releases) and the Ontop 5.0.0 plugin [it.unibz.inf.ontop.protege-5.0.0.jar](https://github.com/ontop/ontop/releases).
(Optional) DBeaver, Datagrip or another database tool for visualizing the data source.


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
```
docker-compose pull && docker-compose up
```
This command starts and initializes the database. Once the database is ready, it launches the SPARQL endpoint from Ontop at http://localhost:8082 .

For this tutorial, we assume that the ports 7778 (used for database) and 8082 (used by Ontop) are free.

A set of queries are exposed on the endpoint.


### (Optional) Start Protégé
* Run Protégé (run.bat on Windows, run.sh on Mac/Linux)
* Register the PostgreSQL JDBC driver: go to Preferences -> JDBC Drivers and add an entry with the following information
  * Description: postgresql
  * Class Name: org.postgresql.Driver
  * Driver file (jar): /path/to/destination-tutorial/jdbc/postgresql-42.2.8.jar
* Open citygml2.0.owl
* Go to Reasoner and select Ontop 5.0.0 .
