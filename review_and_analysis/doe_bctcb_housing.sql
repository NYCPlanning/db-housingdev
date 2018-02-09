/**1. Aggregate dob jobs by census block, with exclusions to capture changes in residential units only**/
 
--Aggregate completions (not screening out jobs with the inactive flag)

SELECT
    geo_censusblock,
    sum(u_2010_increm) AS u_2010_increm,
    sum(u_2011_increm) AS u_2011_increm,
    sum(u_2012_increm) AS u_2012_increm,
    sum(u_2013_increm) AS u_2013_increm,
    sum(u_2014_increm) AS u_2014_increm,
    sum(u_2015_increm) AS u_2015_increm,
    sum(u_2016_increm) AS u_2016_increm,
    sum(u_2017_increm) AS u_2017_increm
FROM
	capitalplanning.dob_jobs_20180208
WHERE
    1=1
    AND the_geom is not null
    AND dcp_status <> 'Withdrawn'
    AND dcp_status <> 'Disapproved'
    AND dcp_status <> 'Suspended'
    AND dcp_status not like '%Application%'
    AND (dcp_occ_init = 'Residential' OR dcp_occ_prop = 'Residential')
    AND x_dup_flag is null
    AND x_outlier is null
GROUP BY
    geo_censusblock
ORDER BY
    geo_censusblock

--Export as csv and upload to Carto as temp_completions

--Aggregate permitted, but incomplete units (screening out jobs with the inactive flag)

SELECT
    geo_censusblock,
    sum(u_net_incomplete) AS u_permitted
FROM
    capitalplanning.dob_jobs_20180208
WHERE
    1=1
    AND the_geom is not null
    AND dcp_status <> 'Withdrawn'
    AND dcp_status <> 'Disapproved'
    AND dcp_status <> 'Suspended'
    AND dcp_status not like '%Application%'
    AND (dcp_occ_init = 'Residential' OR dcp_occ_prop = 'Residential')
    AND x_dup_flag is null
    AND x_outlier is null
    AND x_inactive <> 'true'
GROUP BY
    geo_censusblock
ORDER BY
    geo_censusblock

 - Export Export as csv and upload to Carto as csv temp_permitted

 /**2. Join to 2010 baseline units**/

- Find dcp_housingbctcb_2010 in shared files from dcpadmin 

WITH completions AS (
SELECT
    h.the_geom,
    h.borough,
    h.bctcb AS bctcb2010,
    h.total_housing_units AS baseline_units_2010,
    temp_completions.u_2010_increm,
    temp_completions.u_2011_increm,
    temp_completions.u_2012_increm,
    temp_completions.u_2013_increm,
    temp_completions.u_2014_increm,
    temp_completions.u_2015_increm,
    temp_completions.u_2016_increm,
    temp_completions.u_2017_increm
FROM 
    dcpadmin.dcp_housingbctcb_2010 AS h
LEFT JOIN
    temp_completions
ON h.bctcb = temp_completions.geo_censusblock::numeric
ORDER BY h.bctcb ASC)

SELECT
    c.*,
    temp_permitted.u_permitted
FROM
    completions AS c
LEFT JOIN
    temp_permitted
ON c.bctcb2010 = temp_permitted.geo_censusblock::numeric
ORDER BY c.bctcb2010 ASC

-- Export as geojson and upload to Carto as shared_doe_housing_20180209 to perform checks

/**1. check total baseline units = 3.37M**/
SELECT sum(baseline_units_2010) FROM capitalplanning.shared_doe_housing_20180209

/**2. check no units from DOB where the geom is null**/
SELECT 
    sum(baseline_units_2010) AS baseline_units_2010,
    sum(u_2010_increm) AS u_2010_increm,
    sum(u_2011_increm) AS u_2011_increm,
    sum(u_2012_increm) AS u_2012_increm,
    sum(u_2013_increm) AS u_2013_increm,
    sum(u_2014_increm) AS u_2014_increm,
    sum(u_2015_increm) AS u_2015_increm,
    sum(u_2016_increm) AS u_2016_increm,
    sum(u_2017_increm) AS u_2017_increm,
    sum(u_permitted) AS u_permitted
FROM capitalplanning.shared_doe_housing_20180209
WHERE the_geom is null

/*3. check whether blocks with geom exist in censusblock boundary file*/

alter table shared_doe_housing_20180209
add column x_match text

update shared_doe_housing_20180209
set x_match = 'Y'
from dcpadmin.dcp_nycbctcb2010 AS t
where shared_doe_housing_20180209.the_geom is null
and shared_doe_housing_20180209.bctcb2010 = t.bctcb2010::numeric
