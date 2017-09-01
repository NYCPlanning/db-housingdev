-- RUN EACH STEP INDIVIDUALLY

-- STEP 1
-- Add unit calculation columns to dob_jobs table
ALTER TABLE dob_jobs
	ADD COLUMN c_u_latest integer,
	ADD COLUMN u_net_complete integer,
	ADD COLUMN u_net_incomplete integer,
	ADD COLUMN c_date_latest date,
	ADD COLUMN c_date_earliest date,
	ADD COLUMN c_type_latest text,

	ADD COLUMN u_2007_totalexist integer,
	ADD COLUMN u_2008_totalexist integer,
	ADD COLUMN u_2009_totalexist integer,
	ADD COLUMN u_2010_totalexist integer,
	ADD COLUMN u_2011_totalexist integer,
	ADD COLUMN u_2012_totalexist integer,
	ADD COLUMN u_2013_totalexist integer,
	ADD COLUMN u_2014_totalexist integer,
	ADD COLUMN u_2015_totalexist integer,
	ADD COLUMN u_2016_totalexist integer,
	ADD COLUMN u_2017_totalexist integer,

	ADD COLUMN u_2007_netcomplete integer,
	ADD COLUMN u_2008_netcomplete integer,
	ADD COLUMN u_2009_netcomplete integer,
	ADD COLUMN u_2010_netcomplete integer,
	ADD COLUMN u_2011_netcomplete integer,
	ADD COLUMN u_2012_netcomplete integer,
	ADD COLUMN u_2013_netcomplete integer,
	ADD COLUMN u_2014_netcomplete integer,
	ADD COLUMN u_2015_netcomplete integer,
	ADD COLUMN u_2016_netcomplete integer,
	ADD COLUMN u_2017_netcomplete integer,

	ADD COLUMN u_2007_increm integer,
	ADD COLUMN u_2008_increm integer,
	ADD COLUMN u_2009_increm integer,
	ADD COLUMN u_2010_increm integer,
	ADD COLUMN u_2011_increm integer,
	ADD COLUMN u_2012_increm integer,
	ADD COLUMN u_2013_increm integer,
	ADD COLUMN u_2014_increm integer,
	ADD COLUMN u_2015_increm integer,
	ADD COLUMN u_2016_increm integer,
	ADD COLUMN u_2017_increm integer;


-- STEP 2
-- Fill in gaps in total existing units between CofOs and before first CofO. Looks for most recent CofO value and fills that in. If a CofO value doesn't exist, fills in the initial number of exisiting units from the job application.
UPDATE dob_jobs
	SET
		c_u_latest = b.u_latest,
		c_date_latest = b.c_date_latest,
		c_date_earliest = b.c_date_earliest,
		c_type_latest = b.c_type_latest,
		u_2017_totalexist = 
			(CASE 
				WHEN b.u_2017_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2016_totalexist, b.u_2015_totalexist, b.u_2014_totalexist, b.u_2013_totalexist, b.u_2012_totalexist, b.u_2011_totalexist, b.u_2010_totalexist, b.u_2009_totalexist, b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2017_totalexist IS NOT NULL THEN b.u_2017_totalexist
			END),
		u_2016_totalexist = 
			(CASE 
				WHEN b.u_2016_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2015_totalexist, b.u_2014_totalexist, b.u_2013_totalexist, b.u_2012_totalexist, b.u_2011_totalexist, b.u_2010_totalexist, b.u_2009_totalexist, b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2016_totalexist IS NOT NULL THEN b.u_2016_totalexist
			END),
		u_2015_totalexist = 
			(CASE 
				WHEN b.u_2015_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2014_totalexist, b.u_2013_totalexist, b.u_2012_totalexist, b.u_2011_totalexist, b.u_2010_totalexist, b.u_2009_totalexist, b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2015_totalexist IS NOT NULL THEN b.u_2015_totalexist
			END),
		u_2014_totalexist = 
			(CASE 
				WHEN b.u_2014_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2013_totalexist, b.u_2012_totalexist, b.u_2011_totalexist, b.u_2010_totalexist, b.u_2009_totalexist, b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2014_totalexist IS NOT NULL THEN b.u_2014_totalexist
			END),
		u_2013_totalexist = 
			(CASE 
				WHEN b.u_2013_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2012_totalexist, b.u_2011_totalexist, b.u_2010_totalexist, b.u_2009_totalexist, b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2013_totalexist IS NOT NULL THEN b.u_2013_totalexist
			END),
		u_2012_totalexist = 
			(CASE 
				WHEN b.u_2012_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2011_totalexist, b.u_2010_totalexist, b.u_2009_totalexist, b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2012_totalexist IS NOT NULL THEN b.u_2012_totalexist
			END),
		u_2011_totalexist = 
			(CASE 
				WHEN b.u_2011_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2010_totalexist, b.u_2009_totalexist, b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2011_totalexist IS NOT NULL THEN b.u_2011_totalexist 
			END),
		u_2010_totalexist = 
			(CASE 
				WHEN b.u_2010_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2009_totalexist, b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2010_totalexist IS NOT NULL THEN b.u_2010_totalexist 
			END),
		u_2009_totalexist = 
			(CASE 
				WHEN b.u_2009_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2008_totalexist, b.u_2007_totalexist, u_init)
				WHEN b.u_2009_totalexist IS NOT NULL THEN b.u_2009_totalexist
			END),
		u_2008_totalexist = 
			(CASE 
				WHEN b.u_2008_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2007_totalexist, u_init)
				WHEN b.u_2008_totalexist IS NOT NULL THEN b.u_2008_totalexist
			END),
		u_2007_totalexist = 
			(CASE 
				WHEN b.u_2007_totalexist IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(u_init)
				WHEN b.u_2007_totalexist IS NOT NULL THEN b.u_2007_totalexist
			END)
	FROM dob_cofos AS b
	WHERE dob_jobs.dob_job_number = b.cofo_job_number;


-- STEP 3
-- Capture demolitions in a given year and proxy for CofO date
UPDATE dob_jobs
	SET
		c_date_earliest = status_q,
		c_date_latest = status_q,
		u_2007_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2007' THEN 0 ELSE u_2007_totalexist END),
		u_2008_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2008' THEN 0 ELSE u_2008_totalexist END),
		u_2009_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2009' THEN 0 ELSE u_2009_totalexist END),
		u_2010_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2010' THEN 0 ELSE u_2010_totalexist END),
		u_2011_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2011' THEN 0 ELSE u_2011_totalexist END),
		u_2012_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2012' THEN 0 ELSE u_2012_totalexist END),
		u_2013_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2013' THEN 0 ELSE u_2013_totalexist END),
		u_2014_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2014' THEN 0 ELSE u_2014_totalexist END),
		u_2015_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2015' THEN 0 ELSE u_2015_totalexist END),
		u_2016_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2016' THEN 0 ELSE u_2016_totalexist END),
		u_2017_totalexist = 
			(CASE WHEN LEFT (status_q::text, 4) = '2017' THEN 0 ELSE u_2017_totalexist END)
	WHERE dcp_status = 'Complete (demolition)';


UPDATE dob_jobs
	SET
		u_2017_totalexist = 
			(CASE
				WHEN u_2017_totalexist IS NULL 
				THEN COALESCE(u_2016_totalexist, u_2015_totalexist, u_2014_totalexist, u_2013_totalexist, u_2012_totalexist, u_2011_totalexist, u_2010_totalexist, u_2009_totalexist, u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2017_totalexist
			END),
		u_2016_totalexist = 
			(CASE
				WHEN u_2016_totalexist IS NULL 
				THEN COALESCE(u_2015_totalexist, u_2014_totalexist, u_2013_totalexist, u_2012_totalexist, u_2011_totalexist, u_2010_totalexist, u_2009_totalexist, u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2016_totalexist
			END),
		u_2015_totalexist = 
			(CASE
				WHEN u_2015_totalexist IS NULL 
				THEN COALESCE(u_2014_totalexist, u_2013_totalexist, u_2012_totalexist, u_2011_totalexist, u_2010_totalexist, u_2009_totalexist, u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2015_totalexist
			END),
		u_2014_totalexist = 
			(CASE
				WHEN u_2014_totalexist IS NULL 
				THEN COALESCE(u_2013_totalexist, u_2012_totalexist, u_2011_totalexist, u_2010_totalexist, u_2009_totalexist, u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2014_totalexist
			END),
		u_2013_totalexist = 
			(CASE
				WHEN u_2013_totalexist IS NULL 
				THEN COALESCE(u_2012_totalexist, u_2011_totalexist, u_2010_totalexist, u_2009_totalexist, u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2013_totalexist
			END),
		u_2012_totalexist = 
			(CASE
				WHEN u_2012_totalexist IS NULL 
				THEN COALESCE(u_2011_totalexist, u_2010_totalexist, u_2009_totalexist, u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2012_totalexist
			END),
		u_2011_totalexist = 
			(CASE
				WHEN u_2011_totalexist IS NULL 
				THEN COALESCE(u_2010_totalexist, u_2009_totalexist, u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2011_totalexist
			END),
		u_2010_totalexist = 
			(CASE
				WHEN u_2010_totalexist IS NULL 
				THEN COALESCE(u_2009_totalexist, u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2010_totalexist
			END),
		u_2009_totalexist = 
			(CASE
				WHEN u_2009_totalexist IS NULL 
				THEN COALESCE(u_2008_totalexist, u_2007_totalexist, u_init)
				ELSE u_2009_totalexist
			END),
		u_2008_totalexist = 
			(CASE
				WHEN u_2008_totalexist IS NULL 
				THEN COALESCE(u_2007_totalexist, u_init)
				ELSE u_2008_totalexist
			END),
		u_2007_totalexist = 
			(CASE
				WHEN u_2007_totalexist IS NULL 
				THEN COALESCE(u_2007_totalexist, u_init)
				ELSE u_2007_totalexist
			END)
	WHERE dcp_status = 'Complete (demolition)';


-- STEP 4
-- Calculate cummulative completed units for each year and annual incremental changes
UPDATE dob_jobs 
	SET
		u_2017_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2017_totalexist - u_init END),
		u_2016_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2016_totalexist - u_init END),
		u_2015_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2015_totalexist - u_init END),
		u_2014_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2014_totalexist - u_init END),
		u_2013_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2013_totalexist - u_init END),
		u_2012_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2012_totalexist - u_init END),
		u_2011_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2011_totalexist - u_init END),
		u_2010_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2010_totalexist - u_init END),
		u_2009_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2009_totalexist - u_init END),
		u_2008_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2008_totalexist - u_init END),
		u_2007_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2007_totalexist - u_init END),
		u_2017_increm = u_2017_totalexist - u_2016_totalexist,
		u_2016_increm = u_2016_totalexist - u_2015_totalexist,
		u_2015_increm = u_2015_totalexist - u_2014_totalexist,
		u_2014_increm = u_2014_totalexist - u_2013_totalexist,
		u_2013_increm = u_2013_totalexist - u_2012_totalexist,
		u_2012_increm = u_2012_totalexist - u_2011_totalexist,
		u_2011_increm = u_2011_totalexist - u_2010_totalexist,
		u_2010_increm = u_2010_totalexist - u_2009_totalexist,
		u_2009_increm = u_2009_totalexist - u_2008_totalexist,
		u_2008_increm = u_2008_totalexist - u_2007_totalexist,
		u_2007_increm = u_2007_totalexist - u_init
	;


-- STEP 5
-- Update status based on CofO data and assign number of completed units
UPDATE dob_jobs
SET
	dcp_status =
		(CASE 
			WHEN c_u_latest IS NULL THEN dcp_status
			WHEN u_prop = 0 THEN dcp_status
			WHEN u_net IS NOT NULL AND (c_u_latest / u_prop) >= 0.8 OR status_latest = 'X' OR c_type_latest = 'C- CO' THEN 'Complete'
			WHEN dob_type <> 'DM' AND u_net IS NOT NULL AND (c_u_latest / u_prop) < 0.8 THEN 'Partial complete'
			ELSE dcp_status
		END),
	u_net_complete =
	-- Calculation is not performed if u_init or u_prop were NULL
		(CASE
			WHEN dcp_status = 'Complete (demolition)' AND u_net IS NOT NULL THEN u_net
			WHEN c_u_latest IS NULL AND u_net IS NOT NULL THEN 0 
			WHEN dob_type = 'A1' AND c_u_latest IS NOT NULL AND u_net IS NOT NULL THEN c_u_latest - u_init 
			WHEN dob_type = 'NB' AND c_u_latest IS NOT NULL AND u_net IS NOT NULL THEN c_u_latest
		END);


-- STEP 6
-- Update column to capture outstanding (non-complete) units

UPDATE dob_jobs
	SET u_net_incomplete =
		CASE 
			WHEN u_net IS NOT NULL AND dcp_status LIKE '%Complete%' THEN 0
			WHEN u_net IS NOT NULL AND dcp_status <> 'Complete' THEN (u_net - u_net_complete)
			WHEN u_init IS NULL AND u_prop IS NOT NULL AND c_u_latest IS NOT NULL THEN u_prop - c_u_latest
			ELSE u_net
		END;

		