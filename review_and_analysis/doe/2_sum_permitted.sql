-- Aggregate permitted, but incomplete units (screening out jobs with the inactive flag)

SELECT
    geo_censusblock,
    sum(u_net_incomplete) AS u_permitted
FROM
    capitalplanning.dobdev_jobs_20180316
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

 -- Export Export as csv and upload to Carto as csv temp_permitted
