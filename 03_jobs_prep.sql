-- Import original data as CSV to Carto, naming the table "dob_jobs_orig", and replace column names with preferred columns names that will be used for rest of processing. Carto automatically makes everything lower case and replaces spaces and special characters with "_".

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_number" to "dob_job_number";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_type" to "dob_type";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "current_job_status_description" to "status_latest";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "withdrawal_description" to "x_withdrawal";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_status_date" to "status_date";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_occupancy_classification_description" to "dob_occ_init";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_occupancy_classification_description" to "dob_occ_prop";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_dwelling_units" to "xunits_init_raw"; --this is to preserve original data, while we set this to 0 for calcs; appended with x for ordering 

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_dwelling_units" to "xunits_prop_raw"; --this is to preserve original data, while we set this to 0 for calcs; appended with x for ordering 

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_stories" to "stories_init";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_stories" to "stories_prop";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_zoning_floor_area" to "zoningarea_init";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_zoning_floor_area" to "zoningarea_prop"; 

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "borough_name" to "boro";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_location_house_number" to "address_house";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_location_street_name" to "address_street";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "pre_file_date" to "status_a";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "application_process_date" to "status_d";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "plan_approval_date" to "status_p"; 

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "first_permit_date" to "status_q"; 

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "fully_permitted_date" to "status_r";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "signoff_date" to "status_x";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_total_far" to "far_prop";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "building_type_description" to "dob_bldg_type";
	
-- Grouping data conversions together in case date format in source data changes and edits are needed
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_date" TYPE date using TO_DATE(status_date, 'MM/DD/YYYY');
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_a" TYPE date using TO_DATE(status_a, 'MM/DD/YYYY');
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_d" TYPE date using TO_DATE(status_d, 'MM/DD/YYYY');
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_p" TYPE date using TO_DATE(status_p, 'MM/DD/YYYY');
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_q" TYPE date using TO_DATE(status_q, 'MM/DD/YYYY');
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_r" TYPE date using TO_DATE(status_r, 'MM/DD/YYYY');
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_x" TYPE date using TO_DATE(status_x, 'MM/DD/YYYY');
