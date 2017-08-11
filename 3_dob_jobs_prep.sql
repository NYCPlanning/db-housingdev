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
	RENAME COLUMN "job_type" to "type";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "current_job_status_description" to "dob_status";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "withdrawal_description" to "withdrawal_flag";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_status_date" to "dob_status_date";
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "dob_status_date" TYPE date using TO_DATE(dob_status_date, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_occupancy_classification_description" to "dob_occupancy_exist";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_occupancy_classification_description" to "dob_occupancy_prop";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_dwelling_units" to "xunits_exist_raw"; --this is to preserve original data, while we set this to 0 for calcs; appended with x for ordering 

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_dwelling_units" to "xunits_prop_raw"; --this is to preserve original data, while we set this to 0 for calcs; appended with x for ordering 

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_stories" to "stories_exist";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_stories" to "stories_prop";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "existing_zoning_floor_area" to "zoningarea_exist";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_zoning_floor_area" to "zoningarea_prop"; 

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "borough_name" to "boro";

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_location_house_number" to "address_house";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "job_location_street_name" to "address_street";	

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "pre_file_date" to "dob_adate";
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "dob_adate" TYPE date using TO_DATE(dob_adate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "application_process_date" to "dob_ddate";
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "dob_ddate" TYPE date using TO_DATE(dob_ddate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "plan_approval_date" to "dob_pdate"; 
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "dob_pdate" TYPE date using TO_DATE(dob_pdate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "first_permit_date" to "dob_qdate"; 
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "dob_qdate" TYPE date using TO_DATE(dob_qdate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "fully_permitted_date" to "dob_rdate";
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "dob_rdate" TYPE date using TO_DATE(dob_rdate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "signoff_date" to "dob_xdate";
ALTER TABLE dob_jobs_orig
	ALTER COLUMN "dob_xdate" TYPE date using TO_DATE(dob_xdate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "proposed_total_far" to "xfar_prop"; --non-essential; appended with x

ALTER TABLE dob_jobs_orig
	RENAME COLUMN "building_type_description" to "xbldgtype"; --non-essential; appended with x