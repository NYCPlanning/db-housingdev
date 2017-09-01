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


-- Import as CSV (named "dob_jobs") to Carto for cleaning

--Part 1: Standardize column names and data types (Note: names in original data can change; Carto automatically replaces DOB"s spaces with "_" and converts to lower case)

ALTER TABLE dob_jobs
	RENAME COLUMN "job_number" to "dob_job_number";

ALTER TABLE dob_jobs
	RENAME COLUMN "job_type" to "type";

ALTER TABLE dob_jobs
	RENAME COLUMN "current_job_status_description" to "dob_status";	

ALTER TABLE dob_jobs
	RENAME COLUMN "withdrawal_description" to "withdrawal_flag";

ALTER TABLE dob_jobs
	RENAME COLUMN "job_status_date" to "dob_status_date";
ALTER TABLE dob_jobs
	ALTER COLUMN "dob_status_date" TYPE date using TO_DATE(dob_status_date, 'MM/DD/YYYY');

ALTER TABLE dob_jobs
	RENAME COLUMN "existing_occupancy_classification_description" to "dob_occupancy_exist";	

ALTER TABLE dob_jobs
	RENAME COLUMN "proposed_occupancy_classification_description" to "dob_occupancy_prop";

ALTER TABLE dob_jobs
	RENAME COLUMN "existing_dwelling_units" to "xunits_exist_raw"; --this is to preserve original data, while we set this to 0 for calcs; appended with x for ordering 

ALTER TABLE dob_jobs
	RENAME COLUMN "proposed_dwelling_units" to "xunits_prop_raw"; --this is to preserve original data, while we set this to 0 for calcs; appended with x for ordering 

ALTER TABLE dob_jobs
	RENAME COLUMN "existing_stories" to "stories_exist";	

ALTER TABLE dob_jobs
	RENAME COLUMN "proposed_stories" to "stories_prop";	

ALTER TABLE dob_jobs
	RENAME COLUMN "existing_zoning_floor_area" to "zoningarea_exist";

ALTER TABLE dob_jobs
	RENAME COLUMN "proposed_zoning_floor_area" to "zoningarea_prop"; 

ALTER TABLE dob_jobs
	RENAME COLUMN "borough_name" to "boro";

ALTER TABLE dob_jobs
	RENAME COLUMN "job_location_house_number" to "address_house";	

ALTER TABLE dob_jobs
	RENAME COLUMN "job_location_street_name" to "address_street";	

ALTER TABLE dob_jobs
	RENAME COLUMN "pre_file_date" to "status_a";
ALTER TABLE dob_jobs
	ALTER COLUMN "status_a" TYPE date using TO_DATE(status_a, 'MM/DD/YYYY');

ALTER TABLE dob_jobs
	RENAME COLUMN "application_process_date" to "dob_ddate";
ALTER TABLE dob_jobs
	ALTER COLUMN "dob_ddate" TYPE date using TO_DATE(dob_ddate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs
	RENAME COLUMN "plan_approval_date" to "dob_pdate"; 
ALTER TABLE dob_jobs
	ALTER COLUMN "dob_pdate" TYPE date using TO_DATE(dob_pdate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs
	RENAME COLUMN "first_permit_date" to "dob_qdate"; 
ALTER TABLE dob_jobs
	ALTER COLUMN "dob_qdate" TYPE date using TO_DATE(dob_qdate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs
	RENAME COLUMN "fully_permitted_date" to "dob_rdate";
ALTER TABLE dob_jobs
	ALTER COLUMN "dob_rdate" TYPE date using TO_DATE(dob_rdate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs
	RENAME COLUMN "signoff_date" to "dob_xdate";
ALTER TABLE dob_jobs
	ALTER COLUMN "dob_xdate" TYPE date using TO_DATE(dob_xdate, 'MM/DD/YYYY');

ALTER TABLE dob_jobs
	RENAME COLUMN "proposed_total_far" to "xfar_prop"; --non-essential; appended with x

ALTER TABLE dob_jobs
	RENAME COLUMN "building_type_description" to "xbldgtype"; --non-essential; appended with x



--Part 2: Create and populate additional columns, which will be used for analysis and categorization; Note: this will require having Status and Occupancy tables, which translate DOB field values to DCP conventions

--Create new fields for existing and proposed units, which is integer but also maintains null values from original DOB field (since this may imply erroneous reocrd)

ALTER TABLE dob_jobs
	ADD COLUMN "units_exist" integer;
UPDATE dob_jobs
	SET units_exist = xunits_exist_raw::integer where xunits_exist_raw <>'';

ALTER TABLE dob_jobs
	ADD COLUMN "units_prop" integer;
UPDATE dob_jobs
	SET units_prop = xunits_prop_raw::integer where xunits_prop_raw <>''; 

-- Create field to capture incremental units: negative for demolitions, proposed for new buildings, and net change for alterations (note: if an alteration is missing value for existing or proposed units, value set to null)

ALTER TABLE dob_jobs
	ADD COLUMN "units_net" integer;
UPDATE dob_jobs 
	SET units_net = CASE
		WHEN type = 'DM' THEN units_exist * -1
		WHEN type = 'NB' THEN units_prop
		WHEN type = 'A1' AND units_exist IS NOT null AND units_prop IS NOT null THEN units_prop - units_exist
		ELSE null 
	END;

-- Create field to translate DCP status categories AND flag if job is withdrawn

ALTER TABLE dob_jobs
	ADD COLUMN "dcp_status" text;
UPDATE dob_jobs
SET dcp_status = 
	(SELECT status.dcp FROM status
	WHERE status.dob = dob_jobs.dob_status)
UPDATE dob_jobs
	SET dcp_status = 'Withdrawn' WHERE withdrawal_flag = 'Withdrawn';

-- Create field to translate to DCP existing and proposed occupancy categories

ALTER TABLE dob_jobs
	ADD COLUMN dcp_occupancy_exist text;
UPDATE dob_jobs
	SET dcp_occupancy_exist =
	(SELECT occupancy.dcp FROM occupancy
	WHERE occupancy.dob = dob_occupancy_exist); 

ALTER TABLE dob_jobs
	ADD COLUMN dcp_occupancy_prop text;
UPDATE dob_jobs
	SET dcp_occupancy_prop =
	(SELECT occupancy.dcp FROM occupancy
	WHERE occupancy.dob = dob_occupancy_prop) 

-- Create field to create single category to express occupancy type; order of case/when logic is intended to capture most likely impact of development 

ALTER TABLE dob_jobs
	ADD COLUMN dcp_category_occupancy text;
UPDATE dob_jobs
	SET dcp_category_occupancy = CASE
		WHEN dcp_occupancy_prop = 'Other Accomodations' THEN 'Other Accomodations'
		WHEN dcp_occupancy_prop = 'Residential' OR dcp_occupancy_exist = 'Residential' THEN 'Residential'
		WHEN dcp_occupancy_exist = 'Other Accomodations' THEN 'Other Accomodations'
		ELSE 'Other'
	END;


-- Create field to translate to DCP development types

ALTER TABLE dob_jobs
	ADD COLUMN dcp_category_development text;
UPDATE dob_jobs
	SET dcp_category_development = CASE
		WHEN type = 'NB' THEN 'New Building'
		WHEN type = 'A1' THEN 'Alteration'
		WHEN type = 'DM' THEN 'Demolition'
		ELSE null
	END;


-- Create address field 

ALTER TABLE dob_jobs
	ADD COLUMN address text;
UPDATE dob_jobs
	SET address = CONCAT(address_house,' ',address_street);

-- Create fields to flag suspected duplicates; create unique ID based on matching job types, address and BBL; identify most recent status update date associated with unique ID; if records status update date does not match, flagged as potential duplicate

ALTER TABLE dob_jobs
	ADD COLUMN x_dup_id text;
UPDATE dob_jobs
	SET x_dup_id = CONCAT(type,bbl,address);

UPDATE nchatterjee.dob_jobs
	SET x_dup_id_maxdate = x
	FROM (SELECT 
          	x_dup_id,
          	MAX(dob_status_date) as x
          FROM nchatterjee.dob_jobs
          GROUP BY x_dup_id) as a
	WHERE nchatterjee.dob_jobs.x_dup_id = a.x_dup_id

ALTER TABLE dob_jobs
	ADD COLUMN x_dup_flag text;
UPDATE dob_jobs
	SET x_dup_flag = 'Possible duplicate' WHERE x_dup_id_maxdate <> dob_status_date

-- Isolate housing jobs

SELECT 
	*
FROM 
	dob_jobs
WHERE 
	dcp_category_occupancy = 'Residential'
	OR dcp_category_occupancy = 'Other Accomodations'