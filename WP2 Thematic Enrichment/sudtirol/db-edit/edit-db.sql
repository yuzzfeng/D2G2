ALTER TABLE construction_01k
    ADD COLUMN geom3d GEOMETRY;

UPDATE construction_01k
SET geom3d =
        CASE
            WHEN ct1a_alt IS NOT NULL THEN ST_EXTRUDE(ct1a_shape, 0, 0, ct1a_alt)
            ELSE NULL
        END;