ALTER TABLE sudtirol_db.construction_01k
    ADD COLUMN 3dgeom GEOMETRY;

UPDATE sudtirol_db.construction_01k
SET 3dgeom = ST_EXTRUDE(ct1a_shape, 0, 0, ct1a_alt) ;