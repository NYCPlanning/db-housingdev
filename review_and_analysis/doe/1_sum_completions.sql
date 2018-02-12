/**1. Aggregate dob jobs by census block, with exclusions to capture changes in residential units only and jobs that are complete/partially complete/or permit issued**/
 - Aggregate completions (not screening out jobs with the inactive flag)

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

 -- Export as csv and upload to Carto as temp_completions
