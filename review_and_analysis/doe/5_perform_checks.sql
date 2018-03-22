-- Perform checks

/*1. check total baseline units = 3.37M*/
SELECT sum(baseline_units_2010) FROM capitalplanning.temp_doe_housing_20180209

/*2. check no units from DOB where the geom is null*/
SELECT 
    sum(baseline_units_2010) AS baseline_units_2010,
    sum(u_2010pre_increm) AS u_2010pre_increm,
    sum(u_2010post_increm) AS u_2010post_increm,
    sum(u_2011_increm) AS u_2011_increm,
    sum(u_2012_increm) AS u_2012_increm,
    sum(u_2013_increm) AS u_2013_increm,
    sum(u_2014_increm) AS u_2014_increm,
    sum(u_2015_increm) AS u_2015_increm,
    sum(u_2016_increm) AS u_2016_increm,
    sum(u_2017_increm) AS u_2017_increm,
    sum(u_permitted) AS u_permitted
FROM capitalplanning.temp_doe_housing_20180322
WHERE the_geom is null

/*3. check magnitude of invalid geoms from Bytes of the Big Apple censusblock file, add in non-valid geoms and make valid*/

UPDATE capitalplanning.temp_doe_housing_20180209
SET the_geom = c.the_geom
FROM dcpadmin.dcp_nycbctcb2010 AS c
WHERE temp_doe_housing_20180209.bctcb2010 = c.bctcb2010::numeric
AND temp_doe_housing_20180209.the_geom is null

UPDATE capitalplanning.temp_doe_housing_20180209
SET the_geom = ST_MakeValid(the_geom)
WHERE NOT ST_IsValid(the_geom)

/*4. check whether blocks with geom exist in censusblock boundary file*/

SELECT * FROM capitalplanning.temp_doe_housing_20180209
where geo_csd is null
and the_geom is not null

SELECT * FROM capitalplanning.temp_doe_housing_20180209
where geo_subdist is null
and the_geom is not null

SELECT * FROM capitalplanning.temp_doe_housing_20180209
where geo_pszone201718 is null and geo_pszone_remarks is null
and the_geom is not null

SELECT * FROM capitalplanning.temp_doe_housing_20180209
where geo_nta is null
and the_geom is not null
