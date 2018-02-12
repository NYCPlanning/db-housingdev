 /**3. Join to 2010 baseline units**/

-- Find dcp_housingbctcb_2010 in shared files from dcpadmin 

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

-- Saved as temp_doe_housing_20180209
