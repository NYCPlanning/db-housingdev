-- Data sources:
-- House dev pipeline data from 7/7/2017 downloaded from explorer
-- 2010 housing units data from https://www1.nyc.gov/site/planning/data-maps/nyc-population/census-2010.page


-- Key fields for analysis:
-- u_net: used to take sum of net units
-- dob_ddate: used to filter date range of projects (>=2014)


-- Issues:
-- Since baseline is 2010 census, instead of 2010 + more recent developments, the % increase in biased.
-- >2000 housing units are mapped in the water.
-- Some housing units are also be assigned to central park and governor's island NTA - haven't investigated where these are happening.
-- Need to exclude central park/cemeteries NTA.
-- Numbers look different from last time.


---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------


-- Counts of net units by nta

SELECT
	geog_ntacode,
	sum(u_net) AS new_u_total
FROM
	dob_jobs
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
  	AND RIGHT(geog_ntacode::text, 2) <> '99'
  	AND RIGHT(geog_ntacode::text, 2) <> '98'
	AND u_net IS NOT NULL
	AND the_geom IS NOT NULL
	AND dob_ddate::text > '2014'
GROUP BY
	geog_ntacode
ORDER BY
	geog_ntacode

-- Counts of net units by nta by type of job

SELECT
	geog_ntacode,
	dcp_dev_category,
	sum(u_net) AS new_u_total
FROM
	dob_jobs
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
  	AND RIGHT(geog_ntacode::text, 2) <> '99'
  	AND RIGHT(geog_ntacode::text, 2) <> '98'
	AND u_net IS NOT NULL
	AND the_geom IS NOT NULL
	AND dob_ddate::text > '2014'
GROUP BY
	geog_ntacode,
	dcp_dev_category
ORDER BY
	geog_ntacode

-- Counts of net units by nta by status

SELECT
	geog_ntacode,
	dcp_status,
	sum(u_net) AS new_u_total
FROM
	dob_jobs
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
  	AND RIGHT(geog_ntacode::text, 2) <> '99'
  	AND RIGHT(geog_ntacode::text, 2) <> '98'
	AND u_net IS NOT NULL
	AND the_geom IS NOT NULL
	AND dob_ddate::text > '2014'
GROUP BY
	geog_ntacode,
	dcp_status
ORDER BY
	geog_ntacode

-- Baseline total legal unit couts per year since 2010

WITH cumulative_sums AS (
SELECT
	geog_ntacode,
	geog_ntaname,
	sum(u_2011_increm) AS netchange_eo2011,
	sum(u_2011_increm)+sum(u_2012_increm) AS netchange_eo2012,
	sum(u_2011_increm)+sum(u_2012_increm)+sum(u_2013_increm) AS netchange_eo2013,
  	sum(u_2011_increm)+sum(u_2012_increm)+sum(u_2013_increm)+sum(u_2014_increm) AS netchange_eo2014,
  	sum(u_2011_increm)+sum(u_2012_increm)+sum(u_2013_increm)+sum(u_2014_increm)+sum(u_2015_increm) AS netchange_eo2015,
  	sum(u_2011_increm)+sum(u_2012_increm)+sum(u_2013_increm)+sum(u_2014_increm)+sum(u_2015_increm)+sum(u_2016_increm) AS netchange_eo2016
FROM
	hkates.dob_jobs
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
  	AND RIGHT(geog_ntacode::text, 2) <> '99'
  	AND RIGHT(geog_ntacode::text, 2) <> '98'
	AND the_geom IS NOT NULL
	AND u_net is not null
	AND dcp_status <> 'Withdrawn'
	AND x_dup_flag IS NULL
	AND x_outlier IS NOT TRUE
GROUP BY
	geog_ntacode,
	geog_ntaname
ORDER BY
	geog_ntacode
)

SELECT
	h.cartodb_id,
	h.the_geom,
	h.the_geom_webmercator,
	cumulative_sums.*,
	h.total_housing_units AS baseline_u_eo2010,
	h.total_housing_units + netchange_eo2011 AS baseline_u_eo2011,
	h.total_housing_units + netchange_eo2012 AS baseline_u_eo2012,
	h.total_housing_units + netchange_eo2013 AS baseline_u_eo2013,
	h.total_housing_units + netchange_eo2014 AS baseline_u_eo2014,
	h.total_housing_units + netchange_eo2015 AS baseline_u_eo2015,
	h.total_housing_units + netchange_eo2016 AS baseline_u_eo2016
FROM
	cumulative_sums
LEFT JOIN
	cpadmin.housingunits_nta_2010 AS h
ON
	h.ntacode = cumulative_sums.geog_ntacode
WHERE
	geog_ntaname LIKE '%Queensbridge%'
	OR geog_ntaname LIKE '%Hunters Point%'
	OR geog_ntaname LIKE '%DUMBO%'
	OR geog_ntaname LIKE '%Clinton%'
	OR geog_ntaname LIKE '%Hudson Yards%'
	OR geog_ntaname LIKE '%Greenpoint%'
ORDER BY
	geog_ntaname
LIMIT 20

-- Percent increase in housing units by nta

WITH counts AS (
SELECT
	geog_ntacode,
	geog_ntaname,
	sum(u_2011_increm)+sum(u_2012_increm)+sum(u_2013_increm) AS change_by_beg2014,
	sum(u_2014_increm)+sum(u_2015_increm)+sum(u_2016_increm) AS netchange_20142016,
  	sum(u_net_incomplete) AS new_u_incomplete
FROM
	hkates.dob_jobs
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
  	AND RIGHT(geog_ntacode::text, 2) <> '99'
  	AND RIGHT(geog_ntacode::text, 2) <> '98'
	AND the_geom IS NOT NULL
    AND u_net is not null
	AND dcp_status <> 'Withdrawn'
	AND dcp_status NOT LIKE '%Application%'
	AND x_dup_flag IS NULL
	AND x_outlier IS NOT TRUE
GROUP BY
	geog_ntacode,
	geog_ntaname
ORDER BY
	geog_ntacode
)

SELECT
	h.cartodb_id,
	h.the_geom,
	h.the_geom_webmercator,
	counts.*,
	h.total_housing_units AS baseline_u_2010,
	h.total_housing_units + change_by_beg2014 AS baseline_u_beg2014,
	100*(counts.netchange_20142016 + new_u_incomplete)/(change_by_beg2014 + h.total_housing_units) AS incpercent,
	row_number() over (ORDER BY 100*(counts.netchange_20142016 + new_u_incomplete)/(change_by_beg2014 + h.total_housing_units) DESC) AS rank
FROM
	counts
LEFT JOIN
	cpadmin.housingunits_nta_2010 AS h
ON
	h.ntacode = counts.geog_ntacode
WHERE
	netchange_20142016 IS NOT NULL
ORDER BY
	incpercent DESC
LIMIT 20


/** CartoCSS */
/** choropleth visualization */

#housingu_nta_2010{
  polygon-fill: #FFEDA0;
  polygon-opacity: 0.8;
  line-color: #FFF;
  line-width: 0.5;
  line-opacity: 1;
}
#housingu_nta_2010 [ rank <= 20] {
   polygon-fill: #FEB24C;
}
#housingu_nta_2010 [ rank <= 10] {
   polygon-fill: #F03B20;
}


---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------


-- Counts of net units by CD

SELECT
	geog_cd,
	sum(u_net) AS new_u_total
FROM
	dob_jobs
WHERE
	1=1
	AND geog_cd IS NOT NULL
	AND geog_cd <> ''
	AND u_net IS NOT NULL
	AND the_geom IS NOT NULL
	AND dob_ddate::text > '2014'
GROUP BY
	geog_cd
ORDER BY
	geog_cd

-- Counts of net units by CD by type of job

SELECT
	geog_cd,
	dcp_dev_category, 
	sum(u_net) AS new_u_total
FROM
	dob_jobs
WHERE
	1=1
	AND geog_cd IS NOT NULL
	AND geog_cd <> ''
	AND u_net IS NOT NULL
	AND the_geom IS NOT NULL
	AND dob_ddate::text > '2014'
GROUP BY
	geog_cd,
	dcp_dev_category
ORDER BY
	geog_cd

-- Counts of net units by CD by status

SELECT
	geog_cd,
	dcp_status,
	sum(u_net) AS new_u_total
FROM
	dob_jobs
WHERE
	1=1
	AND geog_cd IS NOT NULL
	AND geog_cd <> ''
	AND u_net IS NOT NULL
	AND the_geom IS NOT NULL
	AND dob_ddate::text > '2014'
GROUP BY
	geog_cd,
	dcp_status
ORDER BY
	geog_cd

-- Percent increase in housing units by CD

WITH counts AS (
SELECT
	geog_cd,
	sum(u_net) AS new_u_total,
  	sum(u_complete_net::numeric) AS new_u_complete,
  	sum(u_incomplete_net::numeric) AS new_u_incomplete
FROM
	hkates.dob_jobs
WHERE
	1=1
	AND geog_cd IS NOT NULL
	AND geog_cd <> ''
	AND u_net IS NOT NULL
	AND the_geom IS NOT NULL
	AND dob_ddate::text > '2014'
GROUP BY
	geog_cd
ORDER BY
	geog_cd
)

SELECT
	h.cartodb_id,
	h.the_geom,
	h.the_geom_webmercator,
	counts.*,
	REPLACE(h.count2010,',','')::numeric As baseline_u_2010,
	ROUND(counts.new_u_total/REPLACE(h.count2010,',','')::numeric, 3) AS incpercent,
	row_number() over (ORDER BY ROUND(counts.new_u_total/REPLACE(h.count2010,',','')::numeric, 3) DESC) AS rank
FROM
	counts
LEFT JOIN
	cpadmin.housingunits_cd_2010 AS h
ON
	h.cd = counts.geog_cd
ORDER BY
	incpercent DESC
LIMIT 20

-- /** CartoCSS */
-- /** choropleth visualization */

-- #housingu_cd_2010{
--   polygon-fill: #FFEDA0;
--   polygon-opacity: 0.8;
--   line-color: #FFF;
--   line-width: 0.5;
--   line-opacity: 1;
-- }
-- #housingu_cd_2010 [ rank <= 20] {
--    polygon-fill: #FEB24C;
-- }
-- #housingu_cd_2010 [ rank <= 10] {
--    polygon-fill: #F03B20;
-- }



-----------------


-- Getting changes between end of 2016 and mid-2017

SELECT
	*
FROM
	hkates.dob_jobs
WHERE
	(u_complete_2017_increm_net <> ''
	AND
	u_complete_2017_increm_net is not null
	AND
	u_complete_2017_increm_net <> '0')
	OR
	dob_ddate > '2017'



