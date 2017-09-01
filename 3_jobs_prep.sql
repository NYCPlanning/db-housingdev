-- General background and watchouts: [ADD here about receiving data from DOB]
	--Open Data: ____
	--Duplicates: ____
	--Record dropping: ____
	--Unintional exclusion of records: ____
	--Field names and values coming through differently: 
	--Permits is a misnomer; DOB thinks of as "jobs"

-- Data specifications (July 2017)
	--Job types: NB, A1, DM
	--Timespan: D Date (Application processed) > 1/1/2007
	--Record type: Doc 01 only (i.e., only capturing primary permit/subpermit)


-- Import as CSV (e.g. "dob_jobs_orig") to Carto for cleaning

-- DATA GATHERING AND PROCESSING
--Part 1: Standardize column names and data types (Note: names in original data can change; Carto automatically replaces DOB"s spaces with "_" and converts to lower case)

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
	ALTER COLUMN "status_date" TYPE date using TO_DATE(status_date, 'MM/DD/YYYY');

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
	ALTER COLUMN "status_a" TYPE date using TO_DATE(status_a, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "application_process_date" to "status_d";
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_d" TYPE date using TO_DATE(status_d, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "plan_approval_date" to "status_p"; 
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_p" TYPE date using TO_DATE(status_p, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "first_permit_date" to "status_q"; 
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_q" TYPE date using TO_DATE(status_q, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "fully_permitted_date" to "status_r";
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_r" TYPE date using TO_DATE(status_r, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "signoff_date" to "status_x";
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "status_x" TYPE date using TO_DATE(status_x, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_total_far" to "far_prop"; --non-essential; appended with x

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "building_type_description" to "dob_bldg_type"; --non-essential; appended with x