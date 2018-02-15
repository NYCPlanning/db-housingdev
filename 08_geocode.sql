-- First tags geoms that came from Jan 2017 data for tracing purposes
UPDATE dobdev_jobs
SET x_edited = 'Jan2017'
WHERE
	the_geom IS NOT NULL
	AND x_edited IS NULL
	AND x_datafreshness = 'January 2017';

-- GBAT

-- Apply geoms from Function A GBAT results
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along, b.Alat),4326),
	bbl = b.bbl,
	bin = b.bin,
	x_edited = 'GBAT-A'
FROM gbat_jobs AS b
WHERE
	dobdev_jobs.dob_job_number = b.dob_job_number::text
	AND dobdev_jobs.the_geom IS NULL;

-- Apply geoms from Function E GBAT results
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Elong, b.Elat),4326),
	bbl = b.bbl,
	bin = b.bin,
	x_edited = 'GBAT-E'
FROM gbat_jobs AS b
WHERE
	dobdev_jobs.dob_job_number = b.dob_job_number::text
	AND dobdev_jobs.the_geom IS NULL;

-- MANUAL

-- Jackie's manual geocoding
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along::numeric, b.Alat::numeric),4326),
	-- bbl =
	-- 	(CASE
	-- 		WHEN b.bbl <> ''
	-- 			AND b.bbl IS NOT NULL
	-- 			AND b.bbl <> 0
	-- 			THEN b.bbl
	-- 		ELSE bbl
	-- 	END),
	-- bin =
	-- 	(CASE
	-- 		WHEN b.bin <> ''
	-- 			AND b.bin <> ' '
	-- 			AND b.bin IS NOT NULL
	-- 			AND b.bin <> 0				
	-- 			AND b.bin <> 100000
	-- 			AND b.bin <> 200000
	-- 			AND b.bin <> 300000
	-- 			AND b.bin <> 400000
	-- 			AND b.bin <> 500000
	-- 			THEN b.bin
	-- 		ELSE bin
	-- 	END),
	x_edited = 'Manual-Jackie'
FROM jackie_mangeo AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.dob_job_number = b.dob_job_number::text;

-- Bill's manual geocoding
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along::numeric, b.Alat::numeric),4326),
	-- bbl =
	-- 	(CASE
	-- 		WHEN b.bbl <> ''
	-- 			AND b.bbl IS NOT NULL
	-- 			AND b.bbl <> 0
	-- 			THEN b.bbl
	-- 		ELSE bbl
	-- 	END),
	-- bin =
	-- 	(CASE
	-- 		WHEN b.bin <> ''
	-- 			AND b.bin <> ' '
	-- 			AND b.bin IS NOT NULL
	-- 			AND b.bin <> 0
	-- 			AND b.bin <> 100000
	-- 			AND b.bin <> 200000
	-- 			AND b.bin <> 300000
	-- 			AND b.bin <> 400000
	-- 			AND b.bin <> 500000
	-- 			THEN b.bin
	-- 		ELSE bin
	-- 	END),
	x_edited = 'Manual-Bill'
FROM bill_mangeo AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.dob_job_number = b.dob_job_number::text;

-- PLUTO

-- Pull in PLUTO centroid geom for remaining records without geometries
UPDATE dobdev_jobs
SET
	the_geom = ST_Centroid(b.the_geom),
	x_edited = 'PLUTO'
FROM dcpadmin.dcp_mappluto_2017v1 AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.bbl= b.bbl::text;

-- Pull in PLUTO centroid geom for remaining records without geometries
UPDATE dobdev_jobs
SET
	the_geom = ST_Centroid(b.the_geom),
	x_edited = 'PLUTO-App'
FROM dcpadmin.dcp_mappluto_2017v1 AS b
WHERE
	dobdev_jobs.the_geom IS NULL
	AND dobdev_jobs.bbl= b.appbbl::text;


-- Reapply reapply previous geoms from points that were manually moved
UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.96792173,40.7148463),4326),
	x_edited = 'Manual-Move'
WHERE dob_job_number = '320917503';

UPDATE dobdev_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-74.01180267,40.70082104),4326),
	x_edited = 'Manual-Move'
WHERE dob_job_number = '121324129';

