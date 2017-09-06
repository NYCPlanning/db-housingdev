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
 	ADD COLUMN geo_mszone201718 text,
 	ADD COLUMN geo_pszone201718 text,
 	ADD COLUMN geo_csd text,
 	ADD COLUMN geo_subdistrict text,
 	ADD COLUMN geo_ntacode text,
 	ADD COLUMN geo_ntaname text,
 	ADD COLUMN geo_censusblock text,
 	ADD COLUMN geo_cd text,
 	ADD COLUMN f_firms2007_100yr text,
 	ADD COLUMN f_pfirms2015_100yr text,
	ADD COLUMN f_2050s_100yr text,
  	ADD COLUMN f_2050s_hightide text;

-- If manually geocoded was done previously, reapply those manual edits using reapply_manual_edits.sql before doing the following spatial joins

-- 7.1
UPDATE dob_jobs
	SET geo_mszone201718 = b.dbn
	FROM nchatterjee.ms_zones_2017_18 as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geo_pszone201718 = b.dbn
	FROM nchatterjee.ps_zones_2017_18 as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

-- 7.2
UPDATE dob_jobs
	SET
		geo_csd = b.schooldist::text,
		geo_subdistrict = b.distzone
	FROM nchatterjee.subdistricts as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom);

-- 7.3
UPDATE dob_jobs
	SET
		geo_ntacode = b.ntacode,
		geo_ntaname = b.ntaname
	FROM nchatterjee.ntas as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geo_cd = b.borocd::text
	FROM cpadmin.dcp_cdboundaries as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom);

-- 7.4
UPDATE dob_jobs
	SET geo_censusblock = b.bctcb2010
	FROM nchatterjee.censusblocks as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

-- 7.5
UPDATE dob_jobs
	SET f_firms2007_100yr = b.fld_zone
	FROM cpadmin.f_firms2007_100yr as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom);

UPDATE dob_jobs
	SET f_pfirms2015_100yr = b.fld_zone
	FROM cpadmin.f_pfirms2015_100yr as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom);

-- 7.6
UPDATE dob_jobs
	SET f_2050s_100yr = 'Within 2050s 100yr floodplain'
	FROM cpadmin.f_2050s_100yr
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom);

UPDATE dob_jobs
 	SET f_2050s_hightide = 'Within 2050s high tide 30in'
 	FROM cpadmin.f_2050s_hightide as b
 	WHERE ST_Within(dob_jobs.the_geom,b.the_geom);
