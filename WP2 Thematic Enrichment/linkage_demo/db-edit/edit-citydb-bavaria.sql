-- Depending on the country, the xal_source XML tree is different and the paths and data that can be extracted varies

ALTER TABLE citydb.address
    ADD COLUMN xal_locality_name VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_locality_type VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_thoroughfare_name VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_thoroughfare_type VARCHAR(256);

UPDATE citydb.address
SET xal_locality_name = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:LocalityName/text()', xal_source::xml,
                               ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_locality_type = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/@Type', xal_source::xml,
                               ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_thoroughfare_name = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:Thoroughfare/xAL:ThoroughfareName/text()', xal_source::xml,
                                   ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_thoroughfare_type = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:Thoroughfare/@Type', xal_source::xml,
                                   ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

--Due to sqlalchemy limitations, adding foreign keys is not possible, hence we do it here
CREATE TABLE citydb."citygml_osm_association" (
    "id" BIGINT NOT NULL PRIMARY KEY,
    "associated_citygmlid" TEXT NOT NULL,
    "associated_osmid" TEXT NOT NULL,
    "association_type" TEXT NOT NULL,
    "osm_type" TEXT NOT NULL
);

-- Based on their discussion https://github.com/3dcitydb/3dcitydb/issues/100 the UNIQUE constraint on the gmlid
-- column has been dropped. However, since for our use cases we will not perform any intertemporal analysis of CityGML
-- data, we can add this constraint aiming to improve Ontop's performance.
ALTER TABLE citydb.cityobject ADD CONSTRAINT unique_gmlid UNIQUE (gmlid);

-- PostgreSQL requires "cityobject"."gmlid" to be declared as UNIQUE before adding foreign key.
ALTER TABLE ONLY citydb."citygml_osm_association"
    ADD CONSTRAINT fk_association_gmlid FOREIGN KEY ("associated_citygmlid") REFERENCES citydb."cityobject" ("gmlid");
-- TODO: osm_id is NOT UNIQUE.
-- ALTER TABLE ONLY citydb."citygml_osm_association"
--     ADD CONSTRAINT fk_association_osmid FOREIGN KEY ("associated_osmid") REFERENCES public."classes" ("osm_id");

-- Add roof types
-- Based on https://www.citygmlwiki.org/images/f/fd/RoofTypeTypeAdV-trans.xml
CREATE TABLE citydb.roof_codelist (
    "name" TEXT NOT NULL PRIMARY KEY,
    "gmlid" TEXT NOT NULL,
    "description_de" TEXT NOT NULL,
    "description_en" TEXT NOT NULL
);

INSERT INTO citydb.roof_codelist VALUES
(1000, 'AdVid357', 'Flachdach', 'flat roof'),
(2100, 'AdVid358', 'Pultdach', 'pent roof'),
(2200, 'AdVid359', 'Versetztes Pultdach', 'offset pent roof'),
(3100, 'AdVid360', 'Satteldach', 'gabled roof'),
(3200, 'AdVid361', 'Walmdach', 'hipped roof'),
(3300, 'AdVid362', 'Krüppelwalmdach', 'half hipped roof'),
(3400, 'AdVid363', 'Mansardendach', 'mansard roof'),
(3500, 'AdVid364', 'Zeltdach', 'tented roof'),
(3600, 'AdVid365', 'Kegeldach', 'cone roof'),
(3700, 'AdVid366', 'Kuppeldach', 'copula roof'),
(3800, 'AdVid367', 'Sheddach', 'sawtooth roof'),
(3900, 'AdVid368', 'Bogendach', 'arch roof'),
(4000, 'AdVid369', 'Turmdach', 'pyramidal broach roof'),
(5000, 'AdVid370', 'Mischform', 'combination of roof forms'),
(9999, 'AdVid371', 'Sonstiges', 'other');

ALTER TABLE ONLY citydb.building
    ADD CONSTRAINT fk_roof_type FOREIGN KEY ("roof_type") REFERENCES citydb.roof_codelist ("name");


-- Add transformed geometry to WGS84 directly for surfaces in citydb table
ALTER TABLE citydb.surface_geometry
    ADD COLUMN geometry_wgs84 GEOMETRY;

UPDATE citydb.surface_geometry
    SET geometry_wgs84 = ST_TRANSFORM("geometry", 4326);

-- Add more spatial indexes for GEOGRAPHY datatype
CREATE INDEX surfacegeom_geog ON citydb.surface_geometry USING gist(CAST(ST_TRANSFORM("geometry",4326) AS GEOGRAPHY));
CREATE INDEX surfacegeom_geog2 ON citydb.surface_geometry USING gist(CAST("geometry_wgs84" AS GEOGRAPHY));
CREATE INDEX classes_geog ON public.classes USING gist(CAST(geom AS geography));