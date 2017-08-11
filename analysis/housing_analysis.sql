-- Data sources:
-- House dev pipeline data from 7/7/2017 downloaded from explorer
-- 2010 housing units data from https://www1.nyc.gov/site/planning/data-maps/nyc-population/census-2010.page


-- Key fields for analysis:
-- units_net: used to take sum of net units
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
	sum(units_net::numeric) AS new_units_total
FROM
	housing_developments_20170707
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
	AND geog_ntacode <> ''
  	AND RIGHT(geog_ntacode, 2) <> '99'
  	AND RIGHT(geog_ntacode, 2) <> '98'
	AND units_net <> ''
	AND the_geom IS NOT NULL
	AND dob_ddate > '2014'
GROUP BY
	geog_ntacode
ORDER BY
	geog_ntacode

-- Counts of net units by nta by type of job

SELECT
	geog_ntacode,
	dcp_category_development,
	sum(units_net::numeric) AS new_units_total
FROM
	housing_developments_20170707
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
	AND geog_ntacode <> ''
  	AND RIGHT(geog_ntacode, 2) <> '99'
  	AND RIGHT(geog_ntacode, 2) <> '98'
	AND units_net <> ''
	AND the_geom IS NOT NULL
	AND dob_ddate > '2014'
GROUP BY
	geog_ntacode,
	dcp_category_development
ORDER BY
	geog_ntacode

-- Counts of net units by nta by status

SELECT
	geog_ntacode,
	dcp_status,
	sum(units_net::numeric) AS new_units_total
FROM
	housing_developments_20170707
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
	AND geog_ntacode <> ''
  	AND RIGHT(geog_ntacode, 2) <> '99'
  	AND RIGHT(geog_ntacode, 2) <> '98'
	AND units_net <> ''
	AND the_geom IS NOT NULL
	AND dob_ddate > '2014'
GROUP BY
	geog_ntacode,
	dcp_status
ORDER BY
	geog_ntacode

-- Percent increase in housing units by nta

WITH counts AS (
SELECT
	geog_ntacode,
	geog_ntaname,
	sum(units_net::numeric) AS new_units_total,
  	sum(units_complete_net::numeric) AS new_units_complete,
  	sum(units_incomplete_net::numeric) AS new_units_incomplete
FROM
	cpadmin.housing_developments_20170707
WHERE
	1=1
	AND geog_ntacode IS NOT NULL
	AND geog_ntacode <> ''
  	AND RIGHT(geog_ntacode, 2) <> '99'
  	AND RIGHT(geog_ntacode, 2) <> '98'
	AND units_net <> ''
	AND the_geom IS NOT NULL
	AND dob_ddate > '2014'
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
	REPLACE(h.total_housing_units,',','')::numeric AS baseline_units_2010,
	ROUND(counts.new_units_total/REPLACE(h.total_housing_units,',','')::numeric, 3) AS incpercent,
	row_number() over (ORDER BY ROUND(counts.new_units_total/REPLACE(h.total_housing_units,',','')::numeric, 3) DESC) AS rank
FROM
	counts
LEFT JOIN
	cpadmin.housingunits_nta_2010 AS h
ON
	h.ntacode = counts.geog_ntacode
ORDER BY
	incpercent DESC
LIMIT 20


-- /** CartoCSS */
-- /** choropleth visualization */

-- #housingunits_nta_2010{
--   polygon-fill: #FFEDA0;
--   polygon-opacity: 0.8;
--   line-color: #FFF;
--   line-width: 0.5;
--   line-opacity: 1;
-- }
-- #housingunits_nta_2010 [ rank <= 20] {
--    polygon-fill: #FEB24C;
-- }
-- #housingunits_nta_2010 [ rank <= 10] {
--    polygon-fill: #F03B20;
-- }


---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------


-- Counts of net units by CD

SELECT
	geog_cd,
	sum(units_net::numeric) AS new_units_total
FROM
	housing_developments_20170707
WHERE
	1=1
	AND geog_cd IS NOT NULL
	AND geog_cd <> ''
	AND units_net <> ''
	AND the_geom IS NOT NULL
	AND dob_ddate > '2014'
GROUP BY
	geog_cd
ORDER BY
	geog_cd

-- Counts of net units by CD by type of job

SELECT
	geog_cd,
	dcp_category_development, 
	sum(units_net::numeric) AS new_units_total
FROM
	housing_developments_20170707
WHERE
	1=1
	AND geog_cd IS NOT NULL
	AND geog_cd <> ''
	AND units_net <> ''
	AND the_geom IS NOT NULL
	AND dob_ddate > '2014'
GROUP BY
	geog_cd,
	dcp_category_development
ORDER BY
	geog_cd

-- Counts of net units by CD by status

SELECT
	geog_cd,
	dcp_status,
	sum(units_net::numeric) AS new_units_total
FROM
	housing_developments_20170707
WHERE
	1=1
	AND geog_cd IS NOT NULL
	AND geog_cd <> ''
	AND units_net <> ''
	AND the_geom IS NOT NULL
	AND dob_ddate > '2014'
GROUP BY
	geog_cd,
	dcp_status
ORDER BY
	geog_cd

-- Percent increase in housing units by CD

WITH counts AS (
SELECT
	geog_cd,
	sum(units_net::numeric) AS new_units_total,
  	sum(units_complete_net::numeric) AS new_units_complete,
  	sum(units_incomplete_net::numeric) AS new_units_incomplete
FROM
	cpadmin.housing_developments_20170707
WHERE
	1=1
	AND geog_cd IS NOT NULL
	AND geog_cd <> ''
	AND units_net <> ''
	AND the_geom IS NOT NULL
	AND dob_ddate > '2014'
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
	REPLACE(h.count2010,',','')::numeric As baseline_units_2010,
	ROUND(counts.new_units_total/REPLACE(h.count2010,',','')::numeric, 3) AS incpercent,
	row_number() over (ORDER BY ROUND(counts.new_units_total/REPLACE(h.count2010,',','')::numeric, 3) DESC) AS rank
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

-- #housingunits_cd_2010{
--   polygon-fill: #FFEDA0;
--   polygon-opacity: 0.8;
--   line-color: #FFF;
--   line-width: 0.5;
--   line-opacity: 1;
-- }
-- #housingunits_cd_2010 [ rank <= 20] {
--    polygon-fill: #FEB24C;
-- }
-- #housingunits_cd_2010 [ rank <= 10] {
--    polygon-fill: #F03B20;
-- }



-----------------


-- Getting changes between end of 2016 and mid-2017

SELECT
	*
FROM
	cpadmin.housing_developments_20170707
WHERE
	(units_complete_2017_increm_net <> ''
	AND
	units_complete_2017_increm_net is not null
	AND
	units_complete_2017_increm_net <> '0')
	OR
	dob_ddate > '2017'



