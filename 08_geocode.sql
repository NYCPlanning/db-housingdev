-- Clean up dummy BBLs and BINs
UPDATE dobdev_jobs
SET bbl = NULL
WHERE bbl = '0';

UPDATE dobdev_jobs
SET bin = NULL
WHERE bin = '0' OR RIGHT(bin, 6) = '000000';

-- Tags geoms that came from Jan 2017 data for tracing purposes
UPDATE dobdev_jobs
SET x_geomsource = 'Jan2017'
WHERE
	the_geom IS NOT NULL
	AND x_geomsource IS NULL
	AND x_datafreshness = 'January 2017';

-- Geoclient

-- Pull in Geoclient output
UPDATE dobdev_jobs
SET
	the_geom = (CASE WHEN b.long_geoclient <> 0 THEN ST_SetSRID(ST_MakePoint(b.long_geoclient, b.lat_geoclient),4326) ELSE NULL END),
	bbl = (CASE WHEN b.bbl_geoclient::text IS NOT NULL THEN b.bbl_geoclient::text ELSE bbl END),
	bin = (CASE WHEN b.bin_geoclient::text IS NOT NULL THEN b.bin_geoclient::text ELSE bin END),
	x_geomsource = (CASE WHEN b.long_geoclient <> 0 THEN 'Geoclient' ELSE NULL END)
FROM dobdev_jobs_geoclient AS b
WHERE dobdev_jobs.dob_job_number::text = b.dob_job_number::text;
 
-- GBAT

-- Apply geoms from Function A GBAT results
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along, b.Alat),4326),
	bbl = (CASE WHEN dobdev_jobs.bbl IS NULL THEN b.bbl::text ELSE dobdev_jobs.bbl END),
	bin = (CASE WHEN dobdev_jobs.bin IS NULL THEN b.bin::text ELSE dobdev_jobs.bin END),
	x_geomsource = 'GBAT-A'
FROM dobdev_gbat_jobs AS b
WHERE
	dobdev_jobs.dob_job_number = b.dob_job_number::text
	AND dobdev_jobs.the_geom IS NULL;

-- Apply geoms from Function E GBAT results
UPDATE dobdev_jobs
SET
	the_geom = (CASE WHEN b.Elong <> 0 THEN ST_SetSRID(ST_MakePoint(b.Elong, b.Elat),4326) END),
	bbl = (CASE WHEN dobdev_jobs.bbl IS NULL THEN b.bbl::text ELSE dobdev_jobs.bbl END),
	bin = (CASE WHEN dobdev_jobs.bin IS NULL THEN b.bin::text ELSE dobdev_jobs.bin END),
	x_geomsource = (CASE WHEN b.Elong <> 0 THEN 'GBAT-E' ELSE NULL END)
FROM dobdev_gbat_jobs AS b
WHERE
	dobdev_jobs.dob_job_number = b.dob_job_number::text
	AND dobdev_jobs.the_geom IS NULL;

-- PLUTO

-- Pull in PLUTO centroid geom for remaining records without geometries
UPDATE dobdev_jobs
SET
	the_geom = ST_Centroid(b.the_geom),
	x_geomsource = 'PLUTO'
FROM dcpadmin.dcp_mappluto_2017v1 AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.bbl= b.bbl::text;

-- Pull in PLUTO centroid geom for remaining records without geometries
UPDATE dobdev_jobs
SET
	the_geom = ST_Centroid(b.the_geom),
	x_geomsource = 'PLUTO-App'
FROM dcpadmin.dcp_mappluto_2017v1 AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.bbl= b.appbbl::text;

-- MANUAL

-- Kristina/Population's manual geocoding
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.ks_long::numeric, b.ks_lat::numeric),4326),
	x_geomsource = 'Manual-Population'
FROM dobdev_population_mangeo_20170615 AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.dob_job_number = b.dob_job_number::text;

-- Jackie's manual geocoding
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along::numeric, b.Alat::numeric),4326),
	x_geomsource = 'Manual-Jackie'
FROM dobdev_jackie_mangeo AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.dob_job_number = b.dob_job_number::text;

-- Bill's manual geocoding
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along::numeric, b.Alat::numeric),4326),
	x_geomsource = 'Manual-Bill'
FROM dobdev_bill_mangeo AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.dob_job_number = b.dob_job_number::text;

-- Final round of manual geocoding
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.longitude::numeric, b.latitude::numeric),4326),
	bin = b.bin,
	bbl = b.bbl,
	x_geomsource = (CASE WHEN b.label = 'Legacy' THEN 'Manual-BillLegacy' WHEN b.label = 'SamL-manual' THEN 'Manual-Sam' END)
FROM dobdev_manualgeo_sl AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.dob_job_number = b.dob_job_number::text;

-- Reapply reapply previous geoms from points that were manually moved
-- UPDATE dobdev_jobs
-- SET
-- 	the_geom = ST_SetSRID(ST_MakePoint(-73.96792173,40.7148463),4326),
-- 	x_geomsource = 'Manual-Move'
-- WHERE dob_job_number = '320917503';

-- UPDATE dobdev_jobs
-- SET
-- 	the_geom = ST_SetSRID(ST_MakePoint(-74.01180267,40.70082104),4326),
-- 	x_geomsource = 'Manual-Move'
-- WHERE dob_job_number = '121324129';

UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.962936, 40.719756),4326),
	x_geomsource = 'Manual-Move'
WHERE dob_job_number = '302143883';


-- Clean up dummy BBLs and BINs
UPDATE dobdev_jobs
SET bbl = NULL
WHERE bbl = '0';

UPDATE dobdev_jobs
SET bin = NULL
WHERE bin = '0' OR RIGHT(bin, 6) = '000000';

-- Calculate coordinates to fill in columns
UPDATE dobdev_jobs
SET
latitude = ST_Y(the_geom),
longitude = ST_X(the_geom),
ycoord = ST_Y(ST_Transform(the_geom, 2263)),
xcoord = ST_X(ST_Transform(the_geom, 2263));

