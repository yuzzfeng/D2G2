-- Add LoD1 CityGML column to the table
-- ALTER TABLE construction_01k
--     ADD COLUMN geom3d GEOMETRY;
--
-- UPDATE construction_01k
-- SET geom3d =
--         CASE
--             WHEN ct1a_alt IS NOT NULL THEN ST_EXTRUDE(ct1a_shape, 0, 0, ct1a_alt)
--             ELSE NULL
--         END;

-- Add official Italian Public Administration data
ALTER TABLE municipalities
    ADD COLUMN istat_code_controlled TEXT;

WITH latest_istat_updates AS (
    SELECT DISTINCT ON (istat_code)
    *
FROM controlled_istat_codes
ORDER BY istat_code, date_last_change DESC)
UPDATE municipalities
SET istat_code_controlled=latest_istat_updates.controlled_istat_code
    FROM latest_istat_updates
WHERE municipalities.istat_code=latest_istat_updates.istat_code;