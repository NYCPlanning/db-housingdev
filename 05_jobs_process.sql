-- RUN EACH STEP INDIVIDUALLY


-- STEP 0 Misc filling in of fields and data quality clean up


UPDATE dobdev_jobs
	SET address_house = 
		(CASE 
			WHEN split_part(address_house, '-', 1) = 'Jan' THEN CONCAT(1, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Feb' THEN CONCAT(2, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Mar' THEN CONCAT(3, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Apr' THEN CONCAT(4, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'May' THEN CONCAT(5, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Jun' THEN CONCAT(6, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Jul' THEN CONCAT(7, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Aug' THEN CONCAT(8, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Sep' THEN CONCAT(9, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Oct' THEN CONCAT(10, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Nov' THEN CONCAT(11, '-', split_part(address_house, '-', 2))
			WHEN split_part(address_house, '-', 1) = 'Dec' THEN CONCAT(12, '-', split_part(address_house, '-', 2))
			ELSE address_house
		END);

UPDATE dobdev_jobs
	SET address = CONCAT(address_house, ' ', address_street)
	WHERE address IS NULL
	AND address_street IS NOT NULL;


-- STEP 1
-- Translate to DCP categories and extract Housing developments. Note: this require having supplementary Occupancy table and Status table, which both translate DOB field values to DCP conventions

UPDATE dobdev_jobs
	SET
		dcp_dev_category =
			(CASE
				WHEN dob_type = 'NB' THEN 'New Building'
				WHEN dob_type = 'A1' THEN 'Alteration'
				WHEN dob_type = 'DM' THEN 'Demolition'
				ELSE null
			END),
		dcp_occ_init =
			(SELECT dobdev_lookup_occupancy.dcp FROM dobdev_lookup_occupancy
			WHERE dobdev_lookup_occupancy.dob = dob_occ_init),
		dcp_occ_prop =
			(SELECT dobdev_lookup_occupancy.dcp FROM dobdev_lookup_occupancy
			WHERE dobdev_lookup_occupancy.dob = dob_occ_prop),
		dcp_status = 
			(SELECT dobdev_lookup_status.dcp FROM dobdev_lookup_status
			WHERE dobdev_lookup_status.dob = dobdev_jobs.status_latest);

UPDATE dobdev_jobs
	SET dcp_occ_init = 'Empty Lot'
	WHERE dob_type = 'NB';

UPDATE dobdev_jobs
	SET dcp_occ_prop = 'Empty Lot'
	WHERE dob_type = 'DM';

UPDATE dobdev_jobs
	SET
		-- Add field for creating single category to express occupancy type; order of case/when logic is intended to capture most likely impact of development; extract only residential
		dcp_occ_category =
			(CASE
				WHEN dcp_occ_prop = 'Other Accommodations' THEN 'Other Accommodations'
				WHEN dcp_occ_prop = 'Residential' OR dcp_occ_init = 'Residential' THEN 'Residential'
				WHEN dcp_occ_init = 'Other Accommodations' THEN 'Other Accommodations'
				ELSE 'Other'
			END),
		-- Create field to translate DCP status categories AND flag if job is withdrawn (note: demolitions considered complete if status is permit issued)
		dcp_status =
			(CASE
				WHEN x_withdrawal = 'Withdrawn' THEN 'Withdrawn'
				WHEN dob_type = 'DM' AND dcp_status IN ('Complete','Permit issued') THEN 'Complete (demolition)'
				ELSE dcp_status
			END);

-- Recode dcp occupancy based on Bill's manual findings (Need to fogure out where this step belongs long-term)
UPDATE dobdev_jobs
	SET
		dcp_occ_category = 'Other Accommodations',
		dcp_occ_prop = 'Other Accommodations',
		x_occsource = 'Legacy'
	FROM dobdev_recodedfrom_residental_to_other
	WHERE dobdev_jobs.dob_job_number = dobdev_recodedfrom_residental_to_other.dob_job_number::text;


-- STEP 2
-- Now that we know that some buildings are likely mixed residential,
-- create binary field to see if there are units proposed rather than relying on DOF Occupancy values

UPDATE dobdev_jobs
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
UPDATE dobdev_jobs
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
UPDATE dobdev_jobs 
	SET u_net =
		CASE
			WHEN dob_type = 'DM' THEN u_init * -1
			WHEN dob_type = 'NB' THEN u_prop
			WHEN dob_type = 'A1' AND u_init IS NOT NULL AND u_prop IS NOT NULL THEN u_prop - u_init
			ELSE NULL 
		END;
		
