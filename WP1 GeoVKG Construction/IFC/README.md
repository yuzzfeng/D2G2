### Sample IFC exploration
File used: AC20-FZK-Haus.ifc at http://smartlab1.elis.ugent.be:8889/IFC-repo/

#### Experiment 1 - Ontop
```
sudo docker-compose -f docker-compose.ontop-ifc-test.yml up
```
Not recommended, complex queries are quite slow with long values clauses.

#### Experiment 2 - Jena Fuseki
```
sudo docker-compose -f docker-compose.ontop-ifc-test.yml up
```
Sample queries available in [sample-queries.txt](WP1%20GeoVKG%20Construction/IFC/jena-fuseki/sample-queries.txt)