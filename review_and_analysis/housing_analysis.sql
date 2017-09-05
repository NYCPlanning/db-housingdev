-- Data sources:
-- House dev pipeline data from 7/7/2017 downloaded from explorer
-- 2010 housing units data from https://www1.nyc.gov/site/planning/data-maps/nyc-population/census-2010.page


-- Baseline total legal unit counts per year since 2010

WITH cumulative_sums AS (
SELECT
	geo_ntacode,
	geo_ntaname,
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
	AND geo_ntacode IS NOT NULL
  	AND RIGHT(geo_ntacode::text, 2) <> '99'
  	AND RIGHT(geo_ntacode::text, 2) <> '98'
	AND the_geom IS NOT NULL
	AND dcp_status <> 'Withdrawn'
	AND x_dup_flag IS NULL
	AND x_outlier IS NOT TRUE
GROUP BY
	geo_ntacode,
	geo_ntaname
ORDER BY
	geo_ntacode
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
	h.ntacode = cumulative_sums.geo_ntacode
ORDER BY
	geo_ntaname
LIMIT 20

-- Percent increase in housing units by nta

WITH counts AS (
SELECT
	geo_ntacode,
	geo_ntaname,
	sum(u_2011_increm)+sum(u_2012_increm)+sum(u_2013_increm) AS change_by_beg2014,
	sum(u_2014_increm)+sum(u_2015_increm)+sum(u_2016_increm) AS netchange_20142016,
  	sum(u_net_incomplete) AS new_u_incomplete
FROM
	hkates.dob_jobs
WHERE
	1=1
	AND geo_ntacode IS NOT NULL
  	AND RIGHT(geo_ntacode::text, 2) <> '99'
  	AND RIGHT(geo_ntacode::text, 2) <> '98'
	AND the_geom IS NOT NULL
	AND dcp_status <> 'Withdrawn'
	AND dcp_status NOT LIKE '%Application%'
	AND x_dup_flag IS NULL
	AND x_outlier IS NOT TRUE
GROUP BY
	geo_ntacode,
	geo_ntaname
ORDER BY
	geo_ntacode
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
	h.ntacode = counts.geo_ntacode
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

