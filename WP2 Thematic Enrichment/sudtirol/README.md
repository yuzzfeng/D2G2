### South Tyrol data
* Publically available ata source:
http://geokatalog.buergernetz.bz.it/geokatalog/#!

* Bounding Box:
47.14 N 46.18 S 10.29 W 12.51 E

* gml:BaseUnit
m

* Data derived from digitalization via ortophoto

Link to the metadata for constructions:
https://geoservices3.civis.bz.it/geoserver/gvcc-Cartography/ows?service=WFS&version=2.0.0&request=getCapabilities

Check the layers available for Cartography via:
```
ogrinfo -ro WFS:"https://geoservices3.civis.bz.it/geoserver/gvcc-Cartography/ows?service=wfs&version=2.0.0&request=getCapabilities"
```

### Additional properties and classes
The ontologies used for administrative areas belong to the Italian Public Administration's Controlled Vocabularies to represent cities and regions.

Github source: https://github.com/italia/daf-ontologie-vocabolari-controllati

### Execution
```
docker-compose up
```