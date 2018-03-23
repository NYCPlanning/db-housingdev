-- All residential jobs that have received permit (with exclusions, except dupes and outliers left in)
SELECT
  cartodb_id,
  the_geom,
  dob_job_number,
  bbl,
  bin,
  dcp_occ_category,
  dcp_occ_init,
  dcp_occ_prop,
  u_init,
  u_prop,
  u_net,
  u_net_complete,
  u_net_incomplete,
  stories_init,
  stories_prop,
  dcp_status,
  dcp_dev_category,
  address
  u_2007_increm,
  u_2008_increm,
  u_2009_increm,
  u_2010pre_increm,
  u_2010post_increm,
  u_2011_increm,
  u_2012_increm,
  u_2013_increm,
  u_2014_increm,
  u_2015_increm,
  u_2016_increm,
  u_2017_increm,
  c_date_earliest,
  c_date_latest,
  c_type_latest,
  geo_censusblock,
  geo_pszone201718,
  geo_mszone201718,
  geo_subdistrict,
  geo_csd,
  geo_ntacode,
  x_dup_flag,
  x_dup_maxstatusdate,
  x_dup_maxcofodate,
  x_outlier,
  x_inactive
FROM capitalplanning.dobdev_jobs_20180316
WHERE 
    1=1
    AND the_geom is not null
    AND dcp_status <> 'Withdrawn'
    AND dcp_status <> 'Disapproved'
    AND dcp_status <> 'Suspended'
    AND dcp_status not like '%Application%'
    AND (dcp_occ_init = 'Residential' OR dcp_occ_prop = 'Residential')
    
-- All residential job applications (with exclusions, except dupes and outliers left in)

SELECT
  cartodb_id,
  the_geom,
  dob_job_number,
  bbl,
  bin,
  dcp_occ_category,
  dcp_occ_init,
  dcp_occ_prop,
  u_init,
  u_prop,
  u_net,
  u_net_complete,
  u_net_incomplete,
  stories_init,
  stories_prop,
  dcp_status,
  dcp_dev_category,
  address
  geo_censusblock,
  geo_pszone201718,
  geo_mszone201718,
  geo_subdistrict,
  geo_csd,
  geo_ntacode,
  x_dup_flag,
  x_dup_maxstatusdate,
  x_dup_maxcofodate,
  x_outlier,
  x_inactive
FROM capitalplanning.dobdev_jobs_20180316
WHERE 
    1=1
    AND the_geom is not null
    AND dcp_status <> 'Withdrawn'
    AND dcp_status <> 'Disapproved'
    AND dcp_status <> 'Suspended'
    AND dcp_status like '%Application%'
    AND (dcp_occ_init = 'Residential' OR dcp_occ_prop = 'Residential')   
