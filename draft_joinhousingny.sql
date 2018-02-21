-- Data source: Housing New York Units by Building data from NYC Open Data 
-- https://data.cityofnewyork.us/Housing-Development/Housing-New-York-Units-by-Building/hg8x-zxpr/data

-- Populate the_geom field using HPD's internal latitude and longtitude fields.
UPDATE hpd_housingny_buildings_20180129
SET the_geom = ST_SetSRID(ST_Makepoint(longitude_internal, latitude_internal), 4326)
WHERE longitude_internal IS NOT NULL;

-- Create DCP columns
ALTER TABLE hpd_housingny_buildings_20180129
ADD COLUMN bbl_dcp text,
ADD COLUMN bin_dcp text,
ADD COLUMN dob_job_number text,
ADD COLUMN dob_job_num_source text;

-- UPDATE hpd_housingny_buildings_20180129
-- SET bbl_dcp = null, bin_dcp = null;

-- UPDATE hpd_housingny_buildings_20180129
-- SET dob_job_number = null, dob_job_num_source = null;

-- Join Geoclient results onto Housing NY records
UPDATE hpd_housingny_buildings_20180129
SET
bbl_dcp = (CASE WHEN g.bbl_geoclient <> 0 THEN g.bbl_geoclient END),
bin_dcp = (CASE WHEN g.bin_geoclient <> 0 AND RIGHT(g.bin_geoclient::text, 6) <> '000000' THEN g.bin_geoclient END)
FROM housingny_geoclient AS g
WHERE CONCAT(hpd_housingny_buildings_20180129.project_id, '-', hpd_housingny_buildings_20180129.building_id) = CONCAT(g.project_id, '-', g.building_id);

-- Populate remaining blanks in bbl_dcp column using a spatial join with DCP's MapPLUTO data.
UPDATE hpd_housingny_buildings_20180129
SET bbl_dcp = p.bbl
FROM dcpadmin.dcp_mappluto_2017v1 AS p
WHERE ST_Intersects(p.the_geom, hpd_housingny_buildings_20180129.the_geom)
AND bbl_dcp IS NULL;


-- -- Check what matches look like
-- SELECT
-- hpd.cartodb_id, reporting_construction_type, project_id, building_id, bin_dcp, bbl_dcp,
-- dobdev_jobs.dob_job_number, status_date, dob_type, u_net, total_units
-- FROM capitalplanning.hpd_housingny_buildings_20180129 as hpd
-- INNER JOIN dobdev_jobs
-- ON bin_dcp = dobdev_jobs.bin
-- AND bbl_dcp = dobdev_jobs.bbl
-- WHERE (dobdev_jobs.dob_type = 'NB' OR dobdev_jobs.dob_type = 'A1')
-- ORDER BY bbl_dcp, dob_job_number


-- Join dob_job_number onto HousingNY data using both BIN and BBL
WITH binbblmatches AS (
  SELECT
  hpd.cartodb_id, reporting_construction_type, project_id, building_id, bin_dcp, bbl_dcp,
  j.dob_job_number, status_date, dob_type, u_net, total_units
  FROM capitalplanning.hpd_housingny_buildings_20180129 as hpd
  INNER JOIN dobdev_jobs AS j
  ON bin_dcp = j.bin
  AND bbl_dcp = j.bbl
  WHERE (j.dob_type = 'NB' OR j.dob_type = 'A1')
  AND j.dcp_status <> 'Withdrawn'
  AND j.dcp_status <> 'Disapproved'
  AND j.dcp_status <> 'Suspended'
--  AND j.(dcp_occ_init = 'Residential' OR dcp_occ_prop = 'Residential')
--  AND j.x_dup_flag is null
--  AND j.x_outlier is null
  ORDER BY bbl_dcp, dob_job_number
),
job_nums AS (
  SELECT CONCAT(project_id, '-', building_id) AS id, array_to_string(array_agg(dob_job_number),';') AS dob_job_number, count(*)
  FROM binbblmatches
  GROUP BY CONCAT(project_id, '-', building_id)
  ORDER BY COUNT DESC
)
UPDATE hpd_housingny_buildings_20180129
SET
dob_job_number = j.dob_job_number,
dob_job_num_source = 'BINandBBL'
FROM job_nums AS j
WHERE CONCAT(hpd_housingny_buildings_20180129.project_id, '-', hpd_housingny_buildings_20180129.building_id) = j.id;


-- Join dob_job_number onto HousingNY data using only BBL for records that didn't find matches including BIN
WITH bblmatches AS (
  SELECT
  hpd.cartodb_id, reporting_construction_type, project_id, building_id, bin_dcp, bbl_dcp,
  j.dob_job_number, status_date, dob_type, u_net, total_units
  FROM capitalplanning.hpd_housingny_buildings_20180129 as hpd
  INNER JOIN dobdev_jobs AS j
  ON bbl_dcp = j.bbl
  WHERE (j.dob_type = 'NB' OR j.dob_type = 'A1')
  AND j.dcp_status <> 'Withdrawn'
  AND j.dcp_status <> 'Disapproved'
  AND j.dcp_status <> 'Suspended'
--  AND j.(dcp_occ_init = 'Residential' OR dcp_occ_prop = 'Residential')
--  AND j.x_dup_flag is null
--  AND j.x_outlier is null
  ORDER BY bbl_dcp, dob_job_number
),
job_nums AS (
  SELECT CONCAT(project_id, '-', building_id) AS id, array_to_string(array_agg(dob_job_number),';') AS dob_job_number, count(*)
  FROM bblmatches
  GROUP BY CONCAT(project_id, '-', building_id)
  ORDER BY COUNT DESC
)
UPDATE hpd_housingny_buildings_20180129
SET
dob_job_number = j.dob_job_number,
dob_job_num_source = 'BBLOnly'
FROM job_nums AS j
WHERE CONCAT(hpd_housingny_buildings_20180129.project_id, '-', hpd_housingny_buildings_20180129.building_id) = j.id
AND dob_job_num_source IS NULL;


-- Use spatial proximity (10 meters) join for remaining new construction that haven't found DOB matches
WITH spatialmatches AS (
  SELECT
  h.project_id,
  h.building_id,
  j.dob_job_number
  FROM
  hpd_housingny_buildings_20180129 AS h,
  dobdev_jobs AS j
  WHERE
  ST_DWithin(h.the_geom::geography, j.the_geom::geography, 10)
  AND dob_job_num_source IS NULL
  AND (j.dob_type = 'NB' OR j.dob_type = 'A1')
  AND j.dcp_status <> 'Withdrawn'
  AND j.dcp_status <> 'Disapproved'
  AND j.dcp_status <> 'Suspended'
--  AND j.(dcp_occ_init = 'Residential' OR dcp_occ_prop = 'Residential')
--  AND j.x_dup_flag is null
--  AND j.x_outlier is null
),
job_nums AS (
  SELECT CONCAT(project_id, '-', building_id) AS id, array_to_string(array_agg(dob_job_number),';') AS dob_job_number, count(*)
  FROM spatialmatches
  GROUP BY CONCAT(project_id, '-', building_id)
  ORDER BY COUNT DESC
)
UPDATE hpd_housingny_buildings_20180129
SET
dob_job_number = j.dob_job_number,
dob_job_num_source = 'Spatial'
FROM job_nums AS j
WHERE CONCAT(hpd_housingny_buildings_20180129.project_id, '-', hpd_housingny_buildings_20180129.building_id) = j.id
AND dob_job_num_source IS NULL;


-- -- Check match rate per construction type and match method
-- SELECT reporting_construction_type, dob_job_num_source, count(*) FROM capitalplanning.hpd_housingny_buildings_20180129
-- WHERE the_geom IS NOT NULL
-- GROUP BY dob_job_num_source, reporting_construction_type
-- ORDER BY reporting_construction_type, dob_job_num_source


-- -- Job numbers with multiple HPD matches
-- with temp as(
-- SELECT unnest(string_to_array(dob_job_number,';')) as dob_job_number, bbl_dcp, dob_job_num_source FROM capitalplanning.hpd_housingny_buildings_20180129
-- )
-- select dob_job_number, bbl_dcp, dob_job_num_source, count(*)
-- from temp
-- group by dob_job_number, bbl_dcp, dob_job_num_source
-- order by count desc

