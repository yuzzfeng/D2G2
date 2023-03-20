import fiona
from shapely.geometry import shape, mapping, Polygon
from lxml import etree
from rtree import index
import geopandas as gpd
import pandas as pd
import os

def gml_2_shp (gml_file_path,crs_gml,output_path):
    with fiona.open(output_path, 'w', 'ESRI Shapefile',crs=crs_gml, schema={'geometry': 'Polygon','properties': [('id', 'str')]}) as output:
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
                feature = {'geometry': mapping(polygon), 'properties': {'id': gml_id}}
                output.write(feature)

def spatial_join(osm_file_path,gml_file_path,uni_crs,tolerance,output_path):
    tolerance = str(tolerance)
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    
    # Read in the shapefiles
    osm_data = gpd.read_file(osm_file_path)
    gml_data = gpd.read_file(gml_file_path)

    osm_data = osm_data.to_crs(uni_crs)
    gml_data = gml_data.to_crs(uni_crs)

    merged = osm_data.overlay(gml_data, how='intersection')
    
    osm_data['osm_area']= osm_data.area
    gml_data['gml_area']= gml_data.area

    merged = osm_data.overlay(gml_data, how='intersection')
    merged['overlap_area'] = merged.area
    merged['ratio_overlap_osm'] = merged['overlap_area'] / merged['osm_area']
    merged['ratio_overlap_gml'] = merged['overlap_area'] / merged['gml_area']
    #print(merged[merged['id']=='DEBY_LOD2_4907572_9c439791-cce4-4ebe-b5d1-4a951feb548e'])
    matched = merged.query(('ratio_overlap_osm > '+tolerance +  'or ratio_overlap_gml > '+tolerance))
    #print(matched[matched['id']=='DEBY_LOD2_4907572_9c439791-cce4-4ebe-b5d1-4a951feb548e'])
    count_data = pd.crosstab(matched["full_id"], matched["id"],margins = True)
    count_data.to_csv(output_path+'/'+'crosstab.csv')
    count_osm_con = {}
    count_gml_con = {}
    dict_osm_con = {}
    dict_gml_con = {}

    for i in range(matched.shape[0]):
        tmp_osm_id = matched.iloc[i].full_id
        tmp_gml_id = matched.iloc[i].id

        if tmp_osm_id in dict_osm_con:
            dict_osm_con[tmp_osm_id].append(tmp_gml_id)
            count_osm_con[tmp_osm_id] = count_osm_con[tmp_osm_id] + 1
        else:
            dict_osm_con[tmp_osm_id] = [tmp_gml_id]
            count_osm_con[tmp_osm_id] = 1


        if tmp_gml_id in dict_gml_con:
            dict_gml_con[tmp_gml_id].append(tmp_osm_id)
            count_gml_con[tmp_gml_id] = count_gml_con[tmp_gml_id] + 1
        else:
            dict_gml_con[tmp_gml_id] = [tmp_osm_id]
            count_gml_con[tmp_gml_id] = 1
    
    index_gml = pd.DataFrame.from_dict(dict_gml_con,orient='index')
    index_gml2 = pd.DataFrame.from_dict(count_gml_con,orient='index')
    index_gml2.columns=['count']
    index_gml = pd.concat([index_gml2,index_gml],sort = False, axis = 1)
    index_gml.to_csv(output_path+'/'+'index_gml.csv')
    #print(index_gml.loc['DEBY_LOD2_30439259_a138d5e0-4c0e-49f7-a488-3aa77a14d698_2'])

    index_osm = pd.DataFrame.from_dict(dict_osm_con,orient='index')
    index_osm2 = pd.DataFrame.from_dict(count_osm_con,orient='index')
    index_osm2.columns=['count']
    index_osm = pd.concat([index_osm2,index_osm],sort = False, axis = 1)
    index_osm.to_csv(output_path+'/'+'index_osm.csv')
    
if __name__ == '__main__':
    gml_file_path = '690_5334.gml'
    crs_gml = 'epsg:25832'
    output_gml_shp = '690_5334_newshp2.shp'
    gml_2_shp(gml_file_path,crs_gml,output_gml_shp)

    gml_shp_path = output_gml_shp
    uni_crs = 'epsg:25832'
    osm_file_path = '690_5334_OSM.shp'
    output_path = './output'
    tolerance = 0.5 # match when (ratio of the overlap area) > tolerance
    spatial_join(osm_file_path,gml_shp_path, uni_crs,tolerance,output_path)