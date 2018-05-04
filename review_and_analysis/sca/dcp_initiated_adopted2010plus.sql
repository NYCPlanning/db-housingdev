-- Use latest NYZI (Zoning Change Index) available on M drive
-- Select all DCP-initiated rezonings from 2010 onwards
-- Select all DoB jobs that fall within a rezoning area where status a is on or after rezoning effective date

WITH temp AS (
SELECT
    j.*,
    z.ulurpno,
    z.project_na,
    z.effective
FROM 
    capitalplanning.dobdev_jobs_20180316 AS j,
    capitalplanning.zoningchangesindexmarch2018 AS z
WHERE ST_Intersects(z.the_geom,j.the_geom)
AND z.applicant_ = '1'
AND z.effective >= '2010-01-01'
AND j.dcp_status <> 'Withdrawn'
AND j.dcp_status <> 'Disapproved'
AND j.dcp_status <> 'Suspended'
AND j.dcp_status not like '%Application%'
AND (j.dcp_occ_init = 'Residential' OR j.dcp_occ_prop = 'Residential')
AND j.x_dup_flag <> 'Possible Duplicate'
AND j.x_outlier <> 'true'
AND j.dob_type = 'NB')

SELECT
    z.cartodb_id,
    z.the_geom,
    z.the_geom_webmercator,
    temp.ulurpno,
    temp.project_na,
    temp.effective,
    sum(temp.u_2010pre_increm) AS u_2010pre_increm,
    sum(temp.u_2010post_increm) AS u_2010post_increm,
    sum(temp.u_2011_increm) AS u_2011_increm,
    sum(temp.u_2012_increm) AS u_2012_increm,
    sum(temp.u_2013_increm) AS u_2013_increm,
    sum(temp.u_2014_increm) AS u_2014_increm,
    sum(temp.u_2015_increm) AS u_2015_increm,
    sum(temp.u_2016_increm) AS u_2016_increm,
    sum(temp.u_2017_increm) AS u_2017_increm,
    sum(temp.u_net_incomplete) AS u_permitted
FROM 
	temp,
	capitalplanning.zoningchangesindexmarch2018 AS z
WHERE temp.status_a >= temp.effective
AND temp.ulurpno = z.ulurpno
GROUP BY 
	z.cartodb_id, z.the_geom, z.the_geom_webmercator, temp.ulurpno, temp.project_na, temp.effective
ORDER BY temp.effective
