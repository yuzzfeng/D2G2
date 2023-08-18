Data:
http://geokatalog.buergernetz.bz.it/geokatalog/#!

Link to the metadata for constructions:
https://geoservices3.civis.bz.it/geoserver/gvcc-Cartography/ows?service=WFS&version=2.0.0&request=getCapabilities

Check the layers available via:
```
ogrinfo -ro WFS:"https://geoservices3.civis.bz.it/geoserver/gvcc-Cartography/ows?service=wfs&version=2.0.0&request=getCapabilities"
```

Tasks:
- Get altitude information for each polygon in order to have precise 3d objects for LoD1