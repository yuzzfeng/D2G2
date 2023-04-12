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
    
    # remove OSM non-buildings 
    osm_data = osm_data[osm_data.building != 'NULL']
    
    osm_data = osm_data.to_crs(uni_crs)
    gml_data = gml_data.to_crs(uni_crs)
    
    # obtaining neighbour features
    osm_data["neigh_osm"] = None
    gml_data["neigh_gml"] = None
    for index, idem in gml_data.iterrows():   
        neighbors = gml_data[~gml_data.geometry.disjoint(idem.geometry)].id.tolist()
        neighbors = [ name for name in neighbors if idem.id != name ]
        gml_data.at[index, "neigh_gml"] = ",".join(neighbors)
    for index, idem in osm_data.iterrows():   
        neighbors = osm_data[~osm_data.geometry.disjoint(idem.geometry)].full_id.tolist()
        neighbors = [ name for name in neighbors if idem.full_id != name ]
        osm_data.at[index, "neigh_osm"] = ",".join(neighbors)
        
    # matching
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
    
    # obtain not matched buildings
    osm_left = pd.concat([osm_data['full_id'],matched['full_id'],matched['full_id']]).drop_duplicates(keep=False)
    gml_left = pd.concat([gml_data['id'],matched['id'],matched['id']]).drop_duplicates(keep=False)
    _1_0 = len(osm_left)
    _0_1 = len(gml_left)
    
    #count_data = pd.crosstab(matched["full_id"], matched["id"],margins = True)
    #count_data.to_csv(output_path+'/'+'crosstab.csv')
    
    count_osm_con = {} # count of matched id
    count_gml_con = {}
    dict_osm_con = {} # matched ids
    dict_gml_con = {}
    dict_osm_neigh = {}# neighbour ids
    dict_gml_neigh = {}

    for i in range(matched.shape[0]):
        tmp_osm_id = matched.iloc[i].full_id
        tmp_gml_id = matched.iloc[i].id
        neigh_osm = matched.iloc[i].neigh_osm.split(',')
        neigh_gml = matched.iloc[i].neigh_gml.split(',')

        if tmp_osm_id in dict_osm_con:
            dict_osm_con[tmp_osm_id].append(tmp_gml_id)
            count_osm_con[tmp_osm_id] = count_osm_con[tmp_osm_id] + 1
            dict_gml_neigh[tmp_osm_id].extend(neigh_gml)
        else:
            dict_osm_con[tmp_osm_id] = [tmp_gml_id]
            count_osm_con[tmp_osm_id] = 1
            dict_gml_neigh[tmp_osm_id] = neigh_gml

        if tmp_gml_id in dict_gml_con:
            dict_gml_con[tmp_gml_id].append(tmp_osm_id)
            count_gml_con[tmp_gml_id] = count_gml_con[tmp_gml_id] + 1
            dict_osm_neigh[tmp_gml_id].extend(neigh_osm)
        else:
            dict_gml_con[tmp_gml_id] = [tmp_osm_id]
            count_gml_con[tmp_gml_id] = 1
            dict_osm_neigh[tmp_gml_id] = neigh_osm

    # organizing the neigbour features
    for key in dict_osm_neigh:
        dict_osm_neigh[key] = list(dict.fromkeys(dict_osm_neigh[key]))
        for osm in dict_osm_neigh[key].copy():
            if osm in count_osm_con:
                dict_osm_neigh[key].remove(osm)
    for key in dict_gml_neigh:
        dict_gml_neigh[key] = list(dict.fromkeys(dict_gml_neigh[key]))
        for gml in dict_gml_neigh[key].copy():
            if gml in count_gml_con:
                dict_gml_neigh[key].remove(gml)        
    
    # statistic the matching relationship
    _1_1 = 0
    osm_m_1 = 0
    osm_1_n = 0
    osm_m_n = 0

    for osm_feature in count_osm_con.keys():
        if count_osm_con[osm_feature] == 1:
            if count_gml_con[dict_osm_con[osm_feature][0]] == 1:
                _1_1 = _1_1 + 1
            else:
                osm_m_1 = osm_m_1 + 1
        else:
            flag = False  #  to identify whether all of the mathced_gml have 1 connection
            for matched_gml_feature in dict_osm_con[osm_feature]:
                if count_gml_con[matched_gml_feature] != 1:
                    osm_m_n = osm_m_n +1
                    flag = True
                    break
            if flag == False:
                osm_1_n = osm_1_n +1

    #saving static
    with open(output_path+'/'+'statis.csv','w') as csvfile:
        csvfile.write("OSM:GML 1:1,"+str(_1_1)+'\n')
        csvfile.write("OSM:GML m:1,"+str(osm_m_1)+'\n')
        csvfile.write("OSM:GML 1:n,"+str(osm_1_n)+'\n')
        csvfile.write("OSM:GML m:n,"+str(osm_m_n)+'\n')
        csvfile.write("OSM:GML 1:0,"+str(_1_0)+'\n')
        csvfile.write("OSM:GML 0:1,"+str(_0_1)+'\n')
        csvfile.write("OSM All,"+str(osm_data.shape[0])+'\n\n')
        csvfile.write("GML All,"+str(gml_data.shape[0])+'\n')
    
    # saving index tables
    index_gml = pd.DataFrame.from_dict(dict_gml_con,orient='index')
    index_gml.rename(columns=lambda x: 'matched_' + str(x), inplace=True)
    index_gml2 = pd.DataFrame.from_dict(count_gml_con,orient='index')
    index_gml2.columns=['count_matched']
    index_gml3 = pd.DataFrame.from_dict(dict_osm_neigh,orient='index')
    index_gml3.rename(columns=lambda x: 'adjacent_' + str(x), inplace=True)
    index_gml = pd.concat([index_gml2,index_gml,index_gml3],sort = False, axis = 1)
    index_gml = index_gml.reset_index()
    index_gml.to_csv(output_path+'/'+'index_gml.csv',index=False)
    #print(index_gml.loc['DEBY_LOD2_30439259_a138d5e0-4c0e-49f7-a488-3aa77a14d698_2'])
    index_osm = pd.DataFrame.from_dict(dict_osm_con,orient='index')
    index_osm.rename(columns=lambda x: 'matched_' + str(x), inplace=True)
    index_osm2 = pd.DataFrame.from_dict(count_osm_con,orient='index')
    index_osm2.columns=['count_matched']
    index_osm3 = pd.DataFrame.from_dict(dict_gml_neigh,orient='index')
    index_osm3.rename(columns=lambda x: 'adjacent_' + str(x), inplace=True)
    index_osm = pd.concat([index_osm2,index_osm,index_osm3],sort = False, axis = 1)
    index_osm = index_osm.reset_index()
    index_osm.to_csv(output_path+'/'+'index_osm.csv',index=False)
    
if __name__ == '__main__':
    gml_file_path = './data/690_5334.gml'
    crs_gml = 'epsg:25832'  # the original CRS of GML data
    output_gml_shp = './data/690_5334_gml.shp'
    gml_2_shp(gml_file_path,crs_gml,output_gml_shp)

    gml_shp_path = output_gml_shp
    uni_crs = 'epsg:25832'  # project the CRSs of the two data into this one CRS
    osm_file_path = './data/690_5334_OSM.shp'
    output_path = './output'
    tolerance = 0.5 # match when (ratio of the overlap area) > tolerance
    spatial_join(osm_file_path,gml_shp_path, uni_crs,tolerance,output_path)