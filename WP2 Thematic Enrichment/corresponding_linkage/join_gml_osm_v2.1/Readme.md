# Spatial Joining for CityGML and OSM data - version 2.1

## Update log:
- the matched buildings and the adjacent buildings of the matched buildings are included in the index tables
- new output - a statistic CSV recording the matching relationships (1:1, m:n, m:1, 1:0, 1:n, 0:1)
- non-building OSM polygons are excluded

## Requirements:
- python 3.8
- geopandas
- Fiona
- Shapely
- gdal
- pyproj

## Workflow
1. Input:  .gml (GML data), .shp(OSM data) in the "data" folder, the correct CRS for CityGML data, the uniform CRS for spatial joining
2. Output: index_gml.csv, index_gml.csv, statis.csv in the "output" folder
   The index tables records information in the following format:
   index_gml.csv:  gml id, matched osm id 0, ...., matched osm id n, adjacent osm id 0, ..., adjacent osm id m
   index_osm.csv:  osm id, matched gml id 0, ...., matched gml id n, adjacent gml id 0, ..., adjacent gml id m
3. Post processing: Join the index tables to the Shapefile layers in QGIS