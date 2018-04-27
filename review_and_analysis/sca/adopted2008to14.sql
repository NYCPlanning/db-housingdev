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
    AND j.dob_type = 'NB'
    AND z.effective between '2008-01-01' and '2015-01-01'
    AND ST_Intersects(j.the_geom,z.the_geom)
