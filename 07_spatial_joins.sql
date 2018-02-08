-- 7.1
UPDATE dob_jobs
	SET geo_mszone201718 = b.dbn
	FROM dcpadmin.doe_school_zones_ms_2017 as b
	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geo_pszone201718 = b.dbn
	FROM dcpadmin.doe_school_zones_es_2017 as b
	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom); 

-- 7.2
UPDATE dob_jobs
	SET
		geo_csd = b.schooldist::text,
		geo_subdistrict = b.distzone
	FROM dcpadmin.doe_schoolsubdistricts as b
	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom);

-- 7.3
UPDATE dob_jobs
	SET
		geo_ntacode = b.ntacode,
		geo_ntaname = b.ntaname
	FROM dcpadmin.support_admin_ntaboundaries as b
	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geo_cd = b.borocd::text
	FROM dcpadmin.nyc_communitydistricts as b
	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom);

-- 7.4
UPDATE dob_jobs
	SET geo_censusblock = b.bctcb2010
	FROM dcpadmin.nyc_census_blocks_2010_wi as b
	WHERE ST_Within(dob_jobs.the_geom,b.the_geom); 

-- -- 7.5
-- UPDATE dob_jobs
-- 	SET f_firms2007_100yr = b.fld_zone
-- 	FROM cpadmin.f_firms2007_100yr as b
-- 	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom);

UPDATE dob_jobs
	SET f_pfirms2015_100yr = b.fld_zone
	FROM dcpadmin.fema_pfirms_100yr_2015 as b
	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom);

-- -- 7.6
-- UPDATE dob_jobs
-- 	SET f_2050s_100yr = 'Within 2050s 100yr floodplain'
-- 	FROM cpadmin.f_2050s_100yr as b
-- 	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom);

-- UPDATE dob_jobs
--  	SET f_2050s_hightide = 'Within 2050s high tide 30in'
--  	FROM cpadmin.f_2050s_hightide as b
--  	WHERE ST_Intersects(dob_jobs.the_geom,b.the_geom);
