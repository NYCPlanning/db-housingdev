-- NTA profiles
-- completions
SELECT
    geo_ntacode,
    dob_type,
    sum(u_2010post_increm) + sum(u_2011_increm) + sum(u_2012_increm) + sum(u_2013_increm) + sum(u_2014_increm) AS u_2010post14_increm,
    sum(u_2015_increm) + sum(u_2016_increm) + sum(u_2017_increm) AS u_201517_increm
FROM
	capitalplanning.dobdev_jobs_20180316_old
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
    AND geo_ntacode in ('QN31','QN63','QN28','QN27','QN26','QN68','QN70','QN71','QN72')
GROUP BY
   geo_ntacode, dob_type
ORDER BY
   geo_ntacode, dob_type

-- permitted

SELECT
    geo_ntacode,
    dob_type,
    sum(u_net_complete) AS u_permitted
FROM
	capitalplanning.dobdev_jobs_20180316_old
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
    AND geo_ntacode in ('QN31','QN63','QN28','QN27','QN26','QN68','QN70','QN71','QN72')
    AND x_inactive <> 'true'
GROUP BY
   geo_ntacode, dob_type
ORDER BY
   geo_ntacode, dob_type
