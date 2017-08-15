CREATE TABLE dob_jobs AS (
	SELECT * FROM dob_jobs_orig
);


---Part 2: Translate to DCP categories and extract Housing developments. Note: this will require having supplementary Occupancy table, which translate DOB field values to DCP conventions
 
 
ALTER TABLE dob_jobs
	ADD COLUMN dcp_category_development text;
UPDATE dob_jobs
	SET dcp_category_development = CASE
		WHEN type = 'NB' THEN 'New Building'
		WHEN type = 'A1' THEN 'Alteration'
		WHEN type = 'DM' THEN 'Demolition'
		ELSE null
	END;


ALTER TABLE dob_jobs
	ADD COLUMN dcp_occupancy_exist text;
UPDATE dob_jobs
	SET dcp_occupancy_exist =
	(SELECT lookup_occupancy.dcp FROM lookup_occupancy
	WHERE lookup_occupancy.dob = dob_occupancy_exist); 

ALTER TABLE dob_jobs
	ADD COLUMN dcp_occupancy_prop text;
UPDATE dob_jobs
	SET dcp_occupancy_prop =
	(SELECT lookup_occupancy.dcp FROM lookup_occupancy
	WHERE lookup_occupancy.dob = dob_occupancy_prop); 



-- Create field to create single category to express occupancy type; order of case/when logic is intended to capture most likely impact of development; extract only residential 
 
ALTER TABLE dob_jobs
	ADD COLUMN dcp_category_occupancy text;
UPDATE dob_jobs
	SET dcp_category_occupancy =
		CASE
			WHEN dcp_occupancy_prop = 'Other Accomodations' THEN 'Other Accomodations'
			WHEN dcp_occupancy_prop = 'Residential' OR dcp_occupancy_exist = 'Residential' THEN 'Residential'
			WHEN dcp_occupancy_exist = 'Other Accomodations' THEN 'Other Accomodations'
			ELSE 'Other'
		END;

DELETE FROM dob_jobs
WHERE dcp_category_occupancy NOT in ('Other Accomodations', 'Residential');



--Part 3: Create and populate additional columns, which will be used for analysis and categorization; Note: this will require having supplementary Status table, which translate DOB field values to DCP conventions

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
	SET units_net =
		CASE
			WHEN type = 'DM' THEN units_exist * -1
			WHEN type = 'NB' THEN units_prop
			WHEN type = 'A1' AND units_exist IS NOT null AND units_prop IS NOT null THEN units_prop - units_exist
			ELSE null 
		END;



-- Part 4: Create field to translate DCP status categories AND flag if job is withdrawn (note: demolitions considered complete if status is permit issued)

ALTER TABLE dob_jobs
	ADD COLUMN "dcp_status" text;
UPDATE dob_jobs
SET dcp_status = 
	(SELECT lookup_status.dcp FROM lookup_status
	WHERE lookup_status.dob = dob_jobs.dob_status);
UPDATE dob_jobs
	SET dcp_status = 'Withdrawn' WHERE withdrawal_flag = 'Withdrawn';
UPDATE dob_jobs
	set dcp_status = 'Complete (demolition)' WHERE type = 'DM' AND dcp_status in ('Complete','Permit issued');




-- Part 5 Create address field and flag suspected duplicates; create unique ID based on matching job types, address and BBL; identify most recent status update date associated with unique ID; if records status update date does not match, flagged as potential duplicate

ALTER TABLE dob_jobs
	ADD COLUMN address text;
UPDATE dob_jobs
	SET address = CONCAT(address_house,' ',address_street);



-- Create a unique ID of type-bbl-address for indentifying duplicates
ALTER TABLE dob_jobs
	ADD COLUMN x_dup_id text;
UPDATE dob_jobs
	SET x_dup_id = CONCAT(type,bbl,address);

-- Assign the maximum status date for each duplicate ID
ALTER TABLE dob_jobs
	ADD COLUMN x_dup_id_maxdate date;
UPDATE dob_jobs
	SET x_dup_id_maxdate = x
	FROM (SELECT 
       	x_dup_id,
       	MAX(dob_status_date) as x
       FROM dob_jobs
       GROUP BY x_dup_id) as a
	WHERE dob_jobs.x_dup_id = a.x_dup_id;


ALTER TABLE dob_jobs
	ADD COLUMN x_dup_flag text;
UPDATE dob_jobs
	SET x_dup_flag = 'Possible duplicate' WHERE x_dup_id_maxdate <> dob_status_date;
