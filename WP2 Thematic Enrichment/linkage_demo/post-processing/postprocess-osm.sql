
-- Due to the geofabrik file downloaded at a different date vs. QGIS shapefiles for OSM
-- Any inconsistent osm_id-s need to be removed (ca.300 as of july 2023)
DELETE FROM citydb."citygml_osm_association"
WHERE associated_osmid NOT IN (
    SELECT entities.osm_id
    FROM public."entities");

-- Respective FK can now be added
ALTER TABLE ONLY citydb."citygml_osm_association"
    ADD CONSTRAINT fk_association_osmid FOREIGN KEY ("associated_osmid") REFERENCES public."entities" ("osm_id");