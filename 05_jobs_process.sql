-- RUN EACH STEP INDIVIDUALLY

-- STEP 1
-- Translate to DCP categories and extract Housing developments. Note: this require having supplementary Occupancy table and Status table, which both translate DOB field values to DCP conventions

UPDATE dob_jobs
	SET
		dcp_dev_category =
			(CASE
				WHEN dob_type = 'NB' THEN 'New Building'
				WHEN dob_type = 'A1' THEN 'Alteration'
				WHEN dob_type = 'DM' THEN 'Demolition'
				ELSE null
			END),
		dcp_occ_init =
			(SELECT lookup_occupancy.dcp FROM lookup_occupancy
			WHERE lookup_occupancy.dob = dob_occ_init),
		dcp_occ_prop =
			(SELECT lookup_occupancy.dcp FROM lookup_occupancy
			WHERE lookup_occupancy.dob = dob_occ_prop),
		dcp_status = 
			(SELECT lookup_status.dcp FROM lookup_status
			WHERE lookup_status.dob = dob_jobs.status_latest);

UPDATE dob_jobs
	SET
		-- Add field for creating single category to express occupancy type; order of case/when logic is intended to capture most likely impact of development; extract only residential
		dcp_occ_category =
			(CASE
				WHEN dcp_occ_prop = 'Other Accomodations' THEN 'Other Accomodations'
				WHEN dcp_occ_prop = 'Residential' OR dcp_occ_init = 'Residential' THEN 'Residential'
				WHEN dcp_occ_init = 'Other Accomodations' THEN 'Other Accomodations'
				ELSE 'Other'
			END),
		-- Create field to translate DCP status categories AND flag if job is withdrawn (note: demolitions considered complete if status is permit issued)
		dcp_status =
			(CASE
				WHEN x_withdrawal = 'Withdrawn' THEN 'Withdrawn'
				WHEN dob_type = 'DM' AND dcp_status IN ('Complete','Permit issued') THEN 'Complete (demolition)'
				ELSE dcp_status
			END);



-- STEP 2
-- Now that we know that some buildings are likely mixed residential,
-- create binary field to see if there are units proposed rather than relying on DOF Occupancy values

UPDATE dob_jobs
	SET
		xunits_binary =
			(CASE
				WHEN xunits_init_raw = '0' AND xunits_prop_raw = '0' THEN 'N'
				WHEN xunits_init_raw = '0' AND xunits_prop_raw = '' THEN 'N'
				WHEN xunits_init_raw = '' AND xunits_prop_raw = '0' THEN 'N'
				WHEN xunits_init_raw = '' AND xunits_prop_raw = '' THEN 'N'
				ELSE 'Y'
			END);


-- STEP 3
-- Create new fields for existing and proposed units, which is integer but also maintains null values from original DOB field (since this may imply erroneous record)
-- Assumes all new buildings have a u_init=0 and all demos have a u_prop=0
UPDATE dob_jobs
	SET
		u_init = 
			(CASE
				WHEN xunits_init_raw <> '' THEN xunits_init_raw::integer
				WHEN dob_type = 'NB' AND (xunits_init_raw = '' OR xunits_init_raw IS NULL) THEN 0
			END),
		u_prop =
			(CASE
				WHEN xunits_prop_raw <> '' THEN xunits_prop_raw::integer
				WHEN dob_type = 'DM' AND (xunits_prop_raw = '' OR xunits_prop_raw IS NULL) THEN 0
			END);


-- Create field to capture proposed net change in units: negative for demolitions, proposed for new buildings, and net change for alterations (note: if an alteration is missing value for existing or proposed units, value set to null)
UPDATE dob_jobs 
	SET u_net =
		CASE
			WHEN dob_type = 'DM' THEN u_init * -1
			WHEN dob_type = 'NB' THEN u_prop
			WHEN dob_type = 'A1' AND u_init IS NOT NULL AND u_prop IS NOT NULL THEN u_prop - u_init
			ELSE NULL 
		END;



-- STEP 4
-- Create address field and flag suspected duplicates; create unique ID (x_dup_id) based on matching job types, address and BBL; identify most recent status update date associated with unique ID; if records status update date does not match, flagged as potential duplicate

ALTER TABLE dob_jobs
	ADD COLUMN x_dup_id text,
	ADD COLUMN x_dup_id_maxdate date,
	ADD COLUMN x_dup_flag text;	

UPDATE dob_jobs
	SET
		address = CONCAT(address_house,' ',address_street),
		x_dup_id = CONCAT(dob_type,bbl,CONCAT(address_house,' ',address_street));

-- Assign the maximum status date for each duplicate ID
UPDATE dob_jobs
	SET
		x_dup_id_maxdate = maxdate
	FROM (SELECT 
       	x_dup_id,
       	MAX(status_date) AS maxdate
       FROM dob_jobs
       GROUP BY x_dup_id) AS a
	WHERE dob_jobs.x_dup_id = a.x_dup_id;

UPDATE dob_jobs
	SET x_dup_flag = 'Possible duplicate' WHERE x_dup_id_maxdate <> status_date;


-- STEP 5
-- Create additional fields for flagging data quality concerns
ALTER TABLE dob_jobs
	ADD COLUMN x_edited BOOLEAN,
	ADD COLUMN x_inactive BOOLEAN,
	ADD COLUMN x_outlier BOOLEAN,
	ADD COLUMN x_notes text;

UPDATE dob_jobs
	SET x_inactive =
		(CASE
			WHEN (CURRENT_DATE - status_date)/365 >= 5 THEN TRUE
			ELSE FALSE
		END)
	WHERE
		dcp_status <> 'Complete'
		AND dcp_status <> 'Complete (demolition)';

