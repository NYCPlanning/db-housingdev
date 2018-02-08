-- Part 6: GEOCODE
-- Part 6a: pull in geometries from previous pipeline
UPDATE dob_jobs
SET the_geom = b.the_geom
FROM nchatterjee.q42016_permits_dates_cofos_v4 as b
WHERE dob_jobs.dob_job_number = b.dob_job_number;

--Part 6b: pull in geometries from PLUTO
UPDATE dob_jobs3
SET the_geom = ST_centroid(b.the_geom)
FROM cpadmin.dcp_mappluto as b
WHERE 
	dob_jobs.the_geom is null
	AND dob_jobs.bbl= b.bbl::text;

--Part 6c: pull in geometries from PLUTO, using old BBLs
UPDATE dob_jobs
SET the_geom = ST_centroid(b.the_geom)
FROM cpadmin.dcp_mappluto as b
WHERE 
	dob_jobs.the_geom is null
	AND dob_jobs.bbl= b.appbbl::text;

--Part 6d: Fill in missing address using PLUTO
UPDATE dob_jobs
SET address = b.address
FROM cpadmin.dcp_mappluto as b
WHERE 
	dob_jobs.address = ' '
	AND dob_jobs.bbl= b.bbl::text;