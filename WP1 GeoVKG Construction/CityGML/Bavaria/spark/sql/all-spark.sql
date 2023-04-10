-- Memory issues for cityobject table, possibly due to size or partitioning issues

CREATE SCHEMA citydb;

DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.address",
   user 'citydb',
   password 'citydb'
 );

CREATE TABLE citydb.address (
                                id INTEGER NOT NULL,
                                gml_id STRING,
                                gml_id_codespace STRING,
                                street STRING,
                                house_number STRING,
                                po_box STRING,
                                zip_code STRING,
                                city STRING,
                                state STRING,
                                country STRING,
                                multi_point STRING,
                                xal_source STRING
);

INSERT INTO TABLE citydb.address
SELECT * FROM jdbcTable;


DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.address_to_building",
   user 'citydb',
   password 'citydb'
 );


CREATE TABLE citydb.address_to_building (
                                            building_id INTEGER NOT NULL,
                                            address_id INTEGER NOT NULL
);

INSERT INTO TABLE citydb.address_to_building
SELECT * FROM jdbcTable;


DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.aggregation_info",
   user 'citydb',
   password 'citydb'
 );


CREATE TABLE citydb.aggregation_info (
                                         child_id INTEGER NOT NULL,
                                         parent_id INTEGER NOT NULL,
                                         join_table_or_column_name STRING,
                                         min_occurs INTEGER,
                                         max_occurs INTEGER,
                                         is_composite INTEGER
);

INSERT INTO TABLE citydb.aggregation_info
SELECT * FROM jdbcTable;


DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.building",
   user 'citydb',
   password 'citydb'
 );


CREATE TABLE citydb.building (
                                 id INTEGER NOT NULL,
                                 objectclass_id INTEGER NOT NULL,
                                 building_parent_id INTEGER NOT NULL,
                                 building_root_id INTEGER NOT NULL,
                                 class STRING,
                                 class_codespace STRING,
                                 function STRING,
                                 function_codespace STRING,
                                 usage STRING,
                                 usage_codespace STRING,
                                 year_of_construction DATE,
                                 year_of_demolition DATE,
                                 roof_type STRING,
                                 roof_type_codespace STRING,
                                 measured_height DOUBLE,
                                 measured_height_unit STRING,
                                 storeys_above_ground TINYINT,
                                 storeys_below_ground TINYINT,
                                 storey_heights_above_ground STRING,
                                 storey_heights_ag_unit STRING,
                                 storey_heights_below_ground STRING,
                                 storey_heights_bg_unit STRING,
                                 lod1_terrain_intersection STRING,
                                 lod2_terrain_intersection STRING,
                                 lod3_terrain_intersection STRING,
                                 lod4_terrain_intersection STRING,
                                 lod2_multi_curve STRING,
                                 lod3_multi_curve STRING,
                                 lod4_multi_curve STRING,
                                 lod0_footprint_id INTEGER,
                                 lod0_roofprint_id INTEGER,
                                 lod1_multisurface_id INTEGER,
                                 lod2_multisurface_id INTEGER,
                                 lod3_multisurface_id INTEGER,
                                 lod4_multisurface_id INTEGER,
                                 lod1_solid_id INTEGER,
                                 lod2_solid_id INTEGER,
                                 lod3_solid_id INTEGER,
                                 lod4_solid_id INTEGER
);

INSERT INTO TABLE citydb.building
SELECT * FROM jdbcTable;



DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.cityobject",
   user 'citydb',
   password 'citydb'
 );

--
-- CREATE TABLE citydb.cityobject (
--                                    id INTEGER NOT NULL,
--                                    objectclass_id INTEGER NOT NULL,
--                                    gml_id STRING,
--                                    gml_codespace STRING,
--                                    name STRING,
--                                    name_codespace STRING,
--                                    description STRING,
--                                    envelope STRING,
--                                    creation_date TIMESTAMP,
--                                    termination_date TIMESTAMP,
--                                    relative_to_terrain STRING,
--                                    relative_to_water STRING,
--                                    last_modification_date TIMESTAMP,
--                                    updating_person STRING,
--                                    reason_for_update STRING,
--                                    lineage STRING,
--                                    xml_source STRING
-- );
--
-- INSERT INTO TABLE citydb.cityobject
-- SELECT * FROM jdbcTable;

CREATE TABLE citydb.cityobject (
                                   id INTEGER NOT NULL,
                                   objectclass_id INTEGER NOT NULL,
                                   gmlid STRING,
                                   name STRING
);

INSERT INTO TABLE citydb.cityobject
SELECT id, objectclass_id, gmlid, name FROM jdbcTable;

DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.cityobject_genericattrib",
   user 'citydb',
   password 'citydb'
 );

-- CREATE TABLE citydb.cityobject_genericattrib (
--                                                  id INTEGER NOT NULL,
--                                                  parent_genattrib_id INTEGER NOT NULL,
--                                                  root_genattrib_id INTEGER NOT NULL,
--                                                  attrname STRING,
--                                                  datatype INTEGER,
--                                                  strval STRING,
--                                                  intval INTEGER,
--                                                  realval DOUBLE,
--                                                  urival STRING,
--                                                  dateval TIMESTAMP,
--                                                  unit STRING,
--                                                  genattribset_codespace STRING,
--                                                  blobval STRING,
--                                                  geomval STRING,
--                                                  surface_geometry_id INTEGER,
--                                                  cityobject_id INTEGER
-- );
--
-- INSERT INTO TABLE citydb.cityobject_genericattrib
-- SELECT * FROM jdbcTable;
-- CREATE TABLE citydb.cityobject_genericattrib (
--                                                  id INTEGER NOT NULL,
--                                                  root_genattrib_id INTEGER NOT NULL,
--                                                  attrname STRING,
--                                                  datatype INTEGER,
--                                                  strval STRING,
--                                                  cityobject_id INTEGER
-- );
--
-- INSERT INTO TABLE citydb.cityobject_genericattrib
-- SELECT id, root_genattrib_id, attrname, datatype, strval, cityobject_id FROM jdbcTable;
--
--
--
DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.objectclass",
   user 'citydb',
   password 'citydb'
 );


CREATE TABLE citydb.objectclass (
                                    id INTEGER NOT NULL,
                                    is_ade_class NUMERIC,
                                    is_toplevel NUMERIC,
                                    classname STRING,
                                    tablename STRING,
                                    superclass_id INTEGER NOT NULL,
                                    baseclass_id INTEGER NOT NULL,
                                    ade_id INTEGER NOT NULL
);

INSERT INTO TABLE citydb.objectclass
SELECT * FROM jdbcTable;


DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.surface_geometry",
   user 'citydb',
   password 'citydb'
 );


-- CREATE TABLE citydb.surface_geometry (
--                                          id INTEGER NOT NULL,
--                                          gmlid STRING,
--                                          gmlid_codespace STRING,
--                                          parent_id INTEGER,
--                                          root_id INTEGER,
--                                          is_solid NUMERIC,
--                                          is_composite NUMERIC,
--                                          is_triangulated NUMERIC,
--                                          is_xlink NUMERIC,
--                                          is_reverse NUMERIC,
--                                          solid_geometry STRING,
--                                          geometry STRING,
--                                          implicit_geometry STRING,
--                                          cityobject_id INTEGER
-- );
--
-- INSERT INTO TABLE citydb.surface_geometry
-- SELECT * FROM jdbcTable;


CREATE TABLE citydb.surface_geometry (
                                         id INTEGER NOT NULL,
                                         parent_id INTEGER,
                                         geometry STRING,
                                         cityobject_id INTEGER
);

INSERT INTO TABLE citydb.surface_geometry
SELECT id, parent_id, geometry, cityobject_id FROM jdbcTable;


DROP VIEW IF EXISTS jdbcTable;
CREATE TEMPORARY VIEW jdbcTable
 USING org.apache.spark.sql.jdbc
 OPTIONS (
   driver "org.postgresql.Driver",
   url "jdbc:postgresql://host.docker.internal:7778/citydb",
   dbtable "citydb.thematic_surface",
   user 'citydb',
   password 'citydb'
 );


CREATE TABLE citydb.thematic_surface (
                                         id INTEGER NOT NULL,
                                         objectclass_id INTEGER,
                                         building_id INTEGER,
                                         room_id INTEGER,
                                         building_installation_id INTEGER,
                                         lod2_multi_surface_id INTEGER,
                                         lod3_multi_surface_id INTEGER,
                                         lod4_multi_surface_id INTEGER
);

INSERT INTO TABLE citydb.thematic_surface
SELECT * FROM jdbcTable;