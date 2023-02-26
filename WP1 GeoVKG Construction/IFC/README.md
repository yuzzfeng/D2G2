### Sample IFC exploration
File used: AC20-FZK-Haus.ifc at http://smartlab1.elis.ugent.be:8889/IFC-repo/

#### Experiment 1 - Ontop with file with materialized triples
```
sudo docker-compose -f docker-compose.ontop-ifc-test.yml up
```
Not recommended, complex queries are quite slow with long values clauses.

#### Experiment 2 - Jena Fuseki
```
sudo docker-compose -f docker-compose.ontop-ifc-test.yml up
```
Sample queries available in [sample-queries.txt](WP1%20GeoVKG%20Construction/IFC/jena-fuseki/sample-queries.txt)

#### Experiment 3 - Ontop with sql database via ifcopenshell
```
sudo docker-compose -f docker-compose.customdb-ontop-test.yml up
```
Only IfcSite currently available for small experiment.
Scalability of solution needs to be reviewed.