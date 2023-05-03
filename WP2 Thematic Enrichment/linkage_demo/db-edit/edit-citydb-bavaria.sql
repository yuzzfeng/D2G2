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