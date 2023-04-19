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