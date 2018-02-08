-- Import original data as CSV to Carto, naming the table "dob_jobs_orig", and replace column names with preferred columns names that will be used for rest of processing. Carto automatically makes everything lower case and replaces spaces and special characters with "_".

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_number" TO "dob_job_number";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_type" TO "dob_type";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "borough_name" TO "boro";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_location_house_number" TO "address_house";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_location_street_name" TO "address_street";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_occupancy_classification_description" TO "dob_occ_init";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_occupancy_classification_description" TO "dob_occ_prop";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_dwelling_units" TO "xunits_init_raw";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_dwelling_units" TO "xunits_prop_raw";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_stories" TO "stories_init";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_stories" TO "stories_prop";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_zoning_floor_area" TO "zoningarea_init";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_zoning_floor_area" TO "zoningarea_prop";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_total_far" TO "far_prop";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "building_type_description" TO "dob_bldg_type";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_status_date" TO "status_date";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "current_job_status_description" TO "status_latest";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "withdrawal_description" TO "x_withdrawal";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "pre_file_date" TO "status_a";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "application_process_date" TO "status_d";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "plan_approval_date" TO "status_p";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "first_permit_date" TO "status_q";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "fully_permitted_date" TO "status_r";
ALTER TABLE dob_jobs_orig
	RENAME COLUMN "signoff_date" TO "status_x";

	
-- Grouping date conversions together in case date format in source data changes and edits are needed
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_date" TYPE date using TO_DATE(status_date, 'MM/DD/YYYY'),
	ALTER COLUMN "status_a" TYPE date using TO_DATE(status_a, 'MM/DD/YYYY'),
	ALTER COLUMN "status_d" TYPE date using TO_DATE(status_d, 'MM/DD/YYYY'),
	ALTER COLUMN "status_p" TYPE date using TO_DATE(status_p, 'MM/DD/YYYY'),
	ALTER COLUMN "status_q" TYPE date using TO_DATE(status_q, 'MM/DD/YYYY'),
	ALTER COLUMN "status_r" TYPE date using TO_DATE(status_r, 'MM/DD/YYYY'),
	ALTER COLUMN "status_x" TYPE date using TO_DATE(status_x, 'MM/DD/YYYY');

-- Create empty dob_jobs table with columns in preferred order using the following query.
SELECT
	NULL AS dob_job_number,
	NULL AS address,
	NULL AS address_house,
	NULL AS address_street,
	NULL AS bin,
	NULL AS bbl,
	NULL AS boro,
	NULL AS block,
	NULL AS lot,
	NULL AS dob_type,
	NULL AS dcp_dev_category,
	NULL AS dcp_occ_category,
	NULL AS dcp_occ_init,
	NULL AS dcp_occ_prop,
	NULL AS dob_occ_init,
	NULL AS dob_occ_prop,
	NULL AS dcp_status,
	NULL AS status_latest,
	NULL::date AS status_date,
	NULL::date AS status_a,
	NULL::date AS status_d,
	NULL::date AS status_p,
	NULL::date AS status_q,
	NULL::date AS status_r,
	NULL::date AS status_x,
	NULL AS dob_bldg_type,
	NULL::numeric AS far_prop,
	NULL::numeric AS stories_init,
	NULL::numeric AS stories_prop,
	NULL AS zoningarea_init,
	NULL AS zoningarea_prop,
	NULL::numeric AS u_init,
	NULL::numeric AS u_prop,
	NULL::numeric AS u_net,
	NULL::numeric AS u_net_complete,
	NULL::numeric AS u_net_incomplete,
	NULL::date AS c_date_earliest,
	NULL::date AS c_date_latest,
	NULL AS c_type_latest,
	NULL::numeric AS c_u_latest,
	NULL::numeric AS u_2007_existtotal,
	NULL::numeric AS u_2008_existtotal,
	NULL::numeric AS u_2009_existtotal,
	NULL::numeric AS u_2010_existtotal,
	NULL::numeric AS u_2011_existtotal,
	NULL::numeric AS u_2012_existtotal,
	NULL::numeric AS u_2013_existtotal,
	NULL::numeric AS u_2014_existtotal,
	NULL::numeric AS u_2015_existtotal,
	NULL::numeric AS u_2016_existtotal,
	NULL::numeric AS u_2017_existtotal,
	NULL::numeric AS u_2007_increm,
	NULL::numeric AS u_2008_increm,
	NULL::numeric AS u_2009_increm,
	NULL::numeric AS u_2010_increm,
	NULL::numeric AS u_2011_increm,
	NULL::numeric AS u_2012_increm,
	NULL::numeric AS u_2013_increm,
	NULL::numeric AS u_2014_increm,
	NULL::numeric AS u_2015_increm,
	NULL::numeric AS u_2016_increm,
	NULL::numeric AS u_2017_increm,
	NULL::numeric AS u_2007_netcomplete,
	NULL::numeric AS u_2008_netcomplete,
	NULL::numeric AS u_2009_netcomplete,
	NULL::numeric AS u_2010_netcomplete,
	NULL::numeric AS u_2011_netcomplete,
	NULL::numeric AS u_2012_netcomplete,
	NULL::numeric AS u_2013_netcomplete,
	NULL::numeric AS u_2014_netcomplete,
	NULL::numeric AS u_2015_netcomplete,
	NULL::numeric AS u_2016_netcomplete,
	NULL::numeric AS u_2017_netcomplete,
	NULL AS geo_cd,
	NULL AS geo_ntacode,
	NULL AS geo_ntaname,
	NULL AS geo_censusblock,
	NULL AS geo_csd,
	NULL AS geo_subdistrict,
	NULL AS geo_pszone201718,
	NULL AS geo_mszone201718,
 	NULL AS f_firms2007_100yr,
 	NULL AS f_pfirms2015_100yr,
	NULL AS f_2050s_100yr,
  	NULL AS f_2050s_hightide,	
	NULL AS x_datafreshness,
	NULL AS xunits_binary,
	NULL AS x_dup_flag,
	NULL AS x_dup_id,
	NULL::date AS x_dup_maxstatusdate,
	NULL::date AS x_dup_maxcofodate,
	NULL AS x_edited,
	NULL AS x_inactive,
	NULL AS x_outlier,
	NULL AS x_withdrawal,
	NULL AS xunits_init_raw,
	NULL AS xunits_prop_raw


-- Then insert the contents from dob_jobs_orig
INSERT INTO dob_jobs
(
	dob_job_number,
	address_house,
	address_street,
	bbl,
	boro,
	block,
	lot,
	dob_type,
	dob_occ_init,
	dob_occ_prop,
	status_latest,
	status_date,
	status_a,
	status_d,
	status_p,
	status_q,
	status_r,
	status_x,
	dob_bldg_type,
	far_prop,
	stories_init,
	stories_prop,
	zoningarea_init,
	zoningarea_prop,
	xunits_init_raw,
	xunits_prop_raw
)

SELECT
	dob_job_number,
	address_house,
	address_street,
	bbl,
	boro,
	block,
	lot,
	dob_type,
	dob_occ_init,
	dob_occ_prop,
	status_latest,
	status_date,
	status_a,
	status_d,
	status_p,
	status_q,
	status_r,
	status_x,
	dob_bldg_type,
	far_prop::numeric,
	stories_init::numeric,
	stories_prop::numeric,
	zoningarea_init,
	zoningarea_prop,
	xunits_init_raw,
	xunits_prop_raw
FROM dob_jobs_orig;

DELETE FROM dob_jobs WHERE cartodb_id = 1 AND dob_job_number IS NULL;


