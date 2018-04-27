-- Download nyzma from Bytes of the Big Apple
-- Select all DoB jobs that fall within a re-zoning area from 2015 onwards

SELECT
	j.*,
    z.ulurpno,
    z.project_na,
    z.status,
    z.effective
FROM 
	capitalplanning.dobdev_jobs_20180316 AS j,
    capitalplanning.nyzma_mar2018 AS z
WHERE
    1=1
    AND j.the_geom is not null
    AND j.dcp_status <> 'Withdrawn'
    AND j.dcp_status <> 'Disapproved'
    AND j.dcp_status <> 'Suspended'
    AND j.dcp_status not like '%Application%'
    AND (j.dcp_occ_init = 'Residential' OR j.dcp_occ_prop = 'Residential')
    AND j.x_dup_flag <> 'Possible Duplicate'
    AND j.x_outlier <> 'true'
    AND z.effective >= '2015-01-01'
    AND ST_Intersects(j.the_geom,z.the_geom)

-- Create dataset from query
-- Calculate units since rezoning
SELECT
	boro,
    ulurpno,
    project_na,
    effective,
    sum(u_2015_increm)+sum(u_2016_increm)+sum(u_2017_increm) AS complete201517,
    sum(u_net_incomplete) AS permitted
FROM capitalplanning.dobjobs_in_rezoning_area_20180316
WHERE status_a >= effective
GROUP BY boro, ulurpno, project_na, effective
ORDER BY boro, effective DESC
