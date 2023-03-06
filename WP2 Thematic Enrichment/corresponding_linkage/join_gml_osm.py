from lxml import etree
from shapely.geometry import Polygon, shape
from shapely.ops import transform
from rtree import index
import pyproj
import fiona
from pyproj import Transformer

def join_gml_osm(shapefile_path,gml_file_path,crs_gml,output_path):
    #contruct a 2D retree index
    p = index.Property()
    p.dimension = 2
    idx = index.Index(properties=p)

    csvfile = open(output_path,'w')
    csvfile.write('gml_id,osm_id\n')
    id_index = 0
    shapes=[] #to store the osm feature geometry
    list_osm_id = [] #to store the osm feature osm_id
    
    #read osm shapefile data and input them into a rtree index
    with fiona.open(shapefile_path, 'r') as shapefile:
        transformer = Transformer.from_crs(shapefile.crs, crs_gml, always_xy=True)
        for feature in shapefile:
            geom = shape(feature['geometry'])
            osm_id = feature['properties']['osm_id']
            list_osm_id.append(osm_id)
            geom_proj = transform(transformer.transform,geom) # the osm crs is transformed from wgs84 to the gml crs, epsg 25832
            shapes.append(geom_proj)
            idx.insert(id_index, shapes[id_index].bounds)
            id_index = id_index + 1

    # read gml and query the rtree index
    tree  = etree.parse(gml_file_path)
    namespaces = {k: v for k, v in tree.getroot().nsmap.items() if k}
    elements = tree.xpath('//bldg:GroundSurface', namespaces=namespaces)
    for element in elements:
        gml_id = element.get('{http://www.opengis.net/gml}id')
        pos_list  = element.find('.//gml:posList', namespaces=namespaces)
        if pos_list is not None:
            pos_list_str = pos_list.text.strip().split()
            coords = [(float(pos_list_str[i]), float(pos_list_str[i+1]), float(pos_list_str[i+2])) for i in range(0, len(pos_list_str), 3)]
            polygon = Polygon(coords)
            center = polygon.centroid
            if not polygon.contains(center):
                center = polygon.representative_point()
            for item in idx.intersection(polygon.bounds):
                intersected_poly = shapes[item]
                if intersected_poly.contains(center):
                    csvfile.write(str(gml_id)+','+str(list_osm_id[item])+'\n')
    csvfile.close()


if __name__ == '__main__':
    shapefile_path = '690_5334_OSM.shp'
    gml_file_path = '690_5334.gml'
    crs_gml = 'epsg:25832'
    output_path = 'spatial_join_result.csv'
    join_gml_osm(shapefile_path,gml_file_path,crs_gml,output_path)