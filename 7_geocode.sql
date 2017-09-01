-- Part 6: GEOCODE
-- Part 6a: pull in geometries from previous pipeline
UPDATE dob_jobs
SET the_geom = b.the_geom
FROM nchatterjee.q42016_permits_dates_cofos_v4 as b
WHERE dob_jobs.dob_job_number = b.dob_job_number;

--Part 6b: pull in geometries from PLUTO
UPDATE dob_jobs
SET the_geom = st_centroid(b.the_geom)
FROM cpadmin.dcp_mappluto as b
WHERE 
	dob_jobs.the_geom is null
	AND dob_jobs.bbl= b.bbl::text;

--Part 6c: pull in geometries from PLUTO, using old BBLs
UPDATE dob_jobs
SET the_geom = st_centroid(b.the_geom)
FROM cpadmin.dcp_mappluto as b
WHERE 
	dob_jobs.the_geom is null
	AND dob_jobs.bbl= b.appbbl::text;


-- Part 7: Assign boundary IDs for administrative and statistical boundaries
-- Need to run these in pieces. Carto can't handle running all 8 joins at once.
ALTER TABLE dob_jobs
 	ADD COLUMN geog_mszone201718 text,
 	ADD COLUMN geog_pszone201718 text,
 	ADD COLUMN geog_csd text,
 	ADD COLUMN geog_subdistrict text,
 	ADD COLUMN geog_ntacode text,
 	ADD COLUMN geog_ntaname text,
 	ADD COLUMN geog_censusblock text,
 	ADD COLUMN geog_cd text;

UPDATE dob_jobs
	SET geog_mszone201718 = b.dbn
	FROM nchatterjee.ms_zones_2017_18 as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_pszone201718 = b.dbn
	FROM nchatterjee.ps_zones_2017_18 as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_csd = b.schooldist::text
	FROM nchatterjee.subdistricts as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom);

UPDATE dob_jobs
	SET geog_subdistrict = b.distzone
	FROM nchatterjee.subdistricts as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET
		geog_ntacode = b.ntacode,
		geog_ntaname = b.ntaname
	FROM nchatterjee.ntas as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_censusblock = b.bctcb2010
	FROM nchatterjee.censusblocks as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_cd = b.borocd::text
	FROM cpadmin.dcp_cdboundaries as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom);
