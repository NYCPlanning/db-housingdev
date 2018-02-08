-- First tags geoms that came from Jan 2017 data for tracing purposes
UPDATE dob_jobs
SET x_edited = 'Jan2017'
WHERE
	the_geom IS NOT NULL
	AND x_edited IS NULL
	AND x_datafreshness = 'January 2017';

UPDATE dob_jobs
SET the_geom = NULL,
x_edited = NULL
WHERE x_edited <> 'Jan2017';

-- GBAT

-- Apply geoms from Function A GBAT results
UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along, b.Alat),4326),
	bbl = b.bbl,
	bin = b.bin,
	x_edited = 'GBAT-A'
FROM gbat_jobs as b
WHERE
	dob_jobs.dob_job_number = b.dob_job_number::text
	AND dob_jobs.the_geom IS NULL

-- Apply geoms from Function E GBAT results
UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Elong, b.Elat),4326),
	bbl = b.bbl,
	bin = b.bin,
	x_edited = 'GBAT-E'
FROM gbat_jobs as b
WHERE
	dob_jobs.dob_job_number = b.dob_job_number::text
	AND dob_jobs.the_geom IS NULL;

-- MANUAL

-- Join manually geocoded records onto jobs data and populate x_edited field
UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along::numeric, b.Alat::numeric),4326),
	(CASE WHEN b.bbl <> '' AND b.bbl IS NOT NULL THEN bbl = b.bbl),
	(CASE
		WHEN
			b.bin <> ''
			AND b.bin <> ' '
			AND b.bin IS NOT NULL
			AND b.bin <> 100000
			AND b.bin <> 200000
			AND b.bin <> 300000
			AND b.bin <> 400000
			AND b.bin <> 500000
		THEN bin = b.bin),
	x_edited = 'Manual-Jackie'
FROM jackie_mangeo as b
WHERE
	dob_jobs.the_geom is null
	AND dob_jobs.dob_job_number = b.dob_job_number::text;

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(b.Along::numeric, b.Alat::numeric),4326),
	(CASE WHEN b.bbl <> '' AND b.bbl IS NOT NULL THEN bbl = b.bbl),
	(CASE
		WHEN
			b.bin <> ''
			AND b.bin <> ' '
			AND b.bin IS NOT NULL
			AND b.bin <> 100000
			AND b.bin <> 200000
			AND b.bin <> 300000
			AND b.bin <> 400000
			AND b.bin <> 500000
		THEN bin = b.bin),
	x_edited = 'Manual-Bill'
FROM bill_mangeo as b
WHERE
	dob_jobs.the_geom is null
	AND dob_jobs.dob_job_number = b.dob_job_number::text;

-- PLUTO

-- Pull in PLUTO centroid geom for remaining records without geometries
UPDATE dob_jobs
SET
	the_geom = ST_Centroid(b.the_geom),
	x_edited = 'PLUTO'
FROM cpadmin.dcp_mappluto as b
WHERE
	dob_jobs.the_geom is null
	AND dob_jobs.bbl= b.bbl::text;

-- Pull in PLUTO centroid geom for remaining records without geometries
UPDATE dob_jobs
SET
	the_geom = ST_Centroid(b.the_geom),
	x_edited = 'PLUTO-App'
FROM cpadmin.dcp_mappluto as b
WHERE
	dob_jobs.the_geom is null
	AND dob_jobs.bbl= b.appbbl::text;

-- Fill in missing address using PLUTO
UPDATE dob_jobs
SET address = b.address
FROM cpadmin.dcp_mappluto as b
WHERE 
	dob_jobs.address = ' '
	AND dob_jobs.bbl= b.bbl::text;


-- Backup option: Pull in geometries from previous data
-- UPDATE dob_jobs
-- SET the_geom = b.the_geom
-- FROM dob_jobs_20161231 as b
-- WHERE dob_jobs.dob_job_number = b.dob_job_number;
