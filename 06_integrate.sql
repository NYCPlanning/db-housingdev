-- RUN EACH STEP INDIVIDUALLY

-- STEP 1
-- Fill in gaps in total existing units between CofOs and before first CofO. Looks for most recent CofO value and fills that in. If a CofO value doesn't exist, fills in the initial number of exisiting units from the job application.
UPDATE dobdev_jobs
	SET
		c_u_latest = b.c_u_latest,
		c_date_latest = b.c_date_latest,
		c_date_earliest = b.c_date_earliest,
		c_type_latest = b.c_type_latest,
		u_2017_existtotal = 
			(CASE 
				WHEN b.u_2017_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2016_existtotal, b.u_2015_existtotal, b.u_2014_existtotal, b.u_2013_existtotal, b.u_2012_existtotal, b.u_2011_existtotal, b.u_2010post_existtotal, b.u_2010pre_existtotal, b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2017_existtotal IS NOT NULL THEN b.u_2017_existtotal
			END),
		u_2016_existtotal = 
			(CASE 
				WHEN b.u_2016_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2015_existtotal, b.u_2014_existtotal, b.u_2013_existtotal, b.u_2012_existtotal, b.u_2011_existtotal, b.u_2010post_existtotal, b.u_2010pre_existtotal, b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2016_existtotal IS NOT NULL THEN b.u_2016_existtotal
			END),
		u_2015_existtotal = 
			(CASE 
				WHEN b.u_2015_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2014_existtotal, b.u_2013_existtotal, b.u_2012_existtotal, b.u_2011_existtotal, b.u_2010post_existtotal, b.u_2010pre_existtotal, b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2015_existtotal IS NOT NULL THEN b.u_2015_existtotal
			END),
		u_2014_existtotal = 
			(CASE 
				WHEN b.u_2014_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2013_existtotal, b.u_2012_existtotal, b.u_2011_existtotal, b.u_2010post_existtotal, b.u_2010pre_existtotal, b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2014_existtotal IS NOT NULL THEN b.u_2014_existtotal
			END),
		u_2013_existtotal = 
			(CASE 
				WHEN b.u_2013_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2012_existtotal, b.u_2011_existtotal, b.u_2010post_existtotal, b.u_2010pre_existtotal, b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2013_existtotal IS NOT NULL THEN b.u_2013_existtotal
			END),
		u_2012_existtotal = 
			(CASE 
				WHEN b.u_2012_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2011_existtotal, b.u_2010post_existtotal, b.u_2010pre_existtotal, b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2012_existtotal IS NOT NULL THEN b.u_2012_existtotal
			END),
		u_2011_existtotal = 
			(CASE 
				WHEN b.u_2011_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2010post_existtotal, b.u_2010pre_existtotal, b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2011_existtotal IS NOT NULL THEN b.u_2011_existtotal 
			END),
		u_2010post_existtotal = 
			(CASE 
				WHEN b.u_2010post_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2010pre_existtotal, b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2010post_existtotal IS NOT NULL THEN b.u_2010post_existtotal 
			END),
		u_2010pre_existtotal = 
			(CASE 
				WHEN b.u_2010pre_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2009_existtotal, b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2010pre_existtotal IS NOT NULL THEN b.u_2010pre_existtotal 
			END),
		u_2009_existtotal = 
			(CASE 
				WHEN b.u_2009_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2008_existtotal, b.u_2007_existtotal, u_init)
				WHEN b.u_2009_existtotal IS NOT NULL THEN b.u_2009_existtotal
			END),
		u_2008_existtotal = 
			(CASE 
				WHEN b.u_2008_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(b.u_2007_existtotal, u_init)
				WHEN b.u_2008_existtotal IS NOT NULL THEN b.u_2008_existtotal
			END),
		u_2007_existtotal = 
			(CASE 
				WHEN b.u_2007_existtotal IS NULL AND dcp_status <> 'Complete (demolition)'
				THEN COALESCE(u_init)
				WHEN b.u_2007_existtotal IS NOT NULL THEN b.u_2007_existtotal
			END)
	FROM dobdev_cofos_20171231_test AS b
	WHERE dobdev_jobs.dob_job_number = b.cofo_job_number;


-- STEP 2
-- Capture demolitions in a given year and proxy for CofO date
UPDATE dobdev_jobs
	SET
		c_date_earliest = status_q,
		c_date_latest = status_q,
		u_2007_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2007' THEN 0 ELSE u_2007_existtotal END),
		u_2008_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2008' THEN 0 ELSE u_2008_existtotal END),
		u_2009_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2009' THEN 0 ELSE u_2009_existtotal END),
		u_2010pre_existtotal = 
			(CASE WHEN status_q < TO_DATE('04/01/2010', 'MM/DD/YYYY') AND status_q >= TO_DATE('01/01/2010', 'MM/DD/YYYY') THEN 0 ELSE u_2010pre_existtotal END),
		u_2010post_existtotal = 
			(CASE WHEN status_q >= TO_DATE('04/01/2010', 'MM/DD/YYYY') AND status_q < TO_DATE('01/01/2011', 'MM/DD/YYYY') THEN 0 ELSE u_2010post_existtotal END),
		u_2011_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2011' THEN 0 ELSE u_2011_existtotal END),
		u_2012_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2012' THEN 0 ELSE u_2012_existtotal END),
		u_2013_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2013' THEN 0 ELSE u_2013_existtotal END),
		u_2014_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2014' THEN 0 ELSE u_2014_existtotal END),
		u_2015_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2015' THEN 0 ELSE u_2015_existtotal END),
		u_2016_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2016' THEN 0 ELSE u_2016_existtotal END),
		u_2017_existtotal = 
			(CASE WHEN LEFT (status_q::text, 4) = '2017' THEN 0 ELSE u_2017_existtotal END)
	WHERE dcp_status = 'Complete (demolition)';

UPDATE dobdev_jobs
	SET
		u_2017_existtotal = 
			(CASE
				WHEN u_2017_existtotal IS NULL 
				THEN COALESCE(u_2016_existtotal, u_2015_existtotal, u_2014_existtotal, u_2013_existtotal, u_2012_existtotal, u_2011_existtotal, u_2010post_existtotal, u_2010pre_existtotal, u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2017_existtotal
			END),
		u_2016_existtotal = 
			(CASE
				WHEN u_2016_existtotal IS NULL 
				THEN COALESCE(u_2015_existtotal, u_2014_existtotal, u_2013_existtotal, u_2012_existtotal, u_2011_existtotal, u_2010post_existtotal, u_2010pre_existtotal, u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2016_existtotal
			END),
		u_2015_existtotal = 
			(CASE
				WHEN u_2015_existtotal IS NULL 
				THEN COALESCE(u_2014_existtotal, u_2013_existtotal, u_2012_existtotal, u_2011_existtotal, u_2010post_existtotal, u_2010pre_existtotal, u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2015_existtotal
			END),
		u_2014_existtotal = 
			(CASE
				WHEN u_2014_existtotal IS NULL 
				THEN COALESCE(u_2013_existtotal, u_2012_existtotal, u_2011_existtotal, u_2010post_existtotal, u_2010pre_existtotal, u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2014_existtotal
			END),
		u_2013_existtotal = 
			(CASE
				WHEN u_2013_existtotal IS NULL 
				THEN COALESCE(u_2012_existtotal, u_2011_existtotal, u_2010post_existtotal, u_2010pre_existtotal, u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2013_existtotal
			END),
		u_2012_existtotal = 
			(CASE
				WHEN u_2012_existtotal IS NULL 
				THEN COALESCE(u_2011_existtotal, u_2010post_existtotal, u_2010pre_existtotal, u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2012_existtotal
			END),
		u_2011_existtotal = 
			(CASE
				WHEN u_2011_existtotal IS NULL 
				THEN COALESCE(u_2010post_existtotal, u_2010pre_existtotal, u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2011_existtotal
			END),
		u_2010post_existtotal = 
			(CASE
				WHEN u_2010post_existtotal IS NULL 
				THEN COALESCE(u_2010pre_existtotal, u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2010post_existtotal
			END),
		u_2010pre_existtotal = 
			(CASE
				WHEN u_2010pre_existtotal IS NULL 
				THEN COALESCE(u_2009_existtotal, u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2010pre_existtotal
			END),
		u_2009_existtotal = 
			(CASE
				WHEN u_2009_existtotal IS NULL 
				THEN COALESCE(u_2008_existtotal, u_2007_existtotal, u_init)
				ELSE u_2009_existtotal
			END),
		u_2008_existtotal = 
			(CASE
				WHEN u_2008_existtotal IS NULL 
				THEN COALESCE(u_2007_existtotal, u_init)
				ELSE u_2008_existtotal
			END),
		u_2007_existtotal = 
			(CASE
				WHEN u_2007_existtotal IS NULL 
				THEN COALESCE(u_2007_existtotal, u_init)
				ELSE u_2007_existtotal
			END)
	WHERE dcp_status = 'Complete (demolition)';


-- STEP 3
-- Calculate cummulative completed units for each year and annual incremental changes
UPDATE dobdev_jobs 
	SET
		u_2017_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2017_existtotal - u_init END),
		u_2016_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2016_existtotal - u_init END),
		u_2015_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2015_existtotal - u_init END),
		u_2014_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2014_existtotal - u_init END),
		u_2013_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2013_existtotal - u_init END),
		u_2012_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2012_existtotal - u_init END),
		u_2011_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2011_existtotal - u_init END),
		u_2010post_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2010post_existtotal - u_init END),
		u_2010pre_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2010pre_existtotal - u_init END),		
		u_2009_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2009_existtotal - u_init END),
		u_2008_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2008_existtotal - u_init END),
		u_2007_netcomplete = (CASE WHEN u_init IS NOT NULL THEN u_2007_existtotal - u_init END),
		u_2017_increm = u_2017_existtotal - u_2016_existtotal,
		u_2016_increm = u_2016_existtotal - u_2015_existtotal,
		u_2015_increm = u_2015_existtotal - u_2014_existtotal,
		u_2014_increm = u_2014_existtotal - u_2013_existtotal,
		u_2013_increm = u_2013_existtotal - u_2012_existtotal,
		u_2012_increm = u_2012_existtotal - u_2011_existtotal,
		u_2011_increm = u_2011_existtotal - u_2010post_existtotal,
		u_2010post_increm = u_2010post_existtotal - u_2010pre_existtotal,
		u_2010pre_increm = u_2010pre_existtotal - u_2009_existtotal,
		u_2009_increm = u_2009_existtotal - u_2008_existtotal,
		u_2008_increm = u_2008_existtotal - u_2007_existtotal,
		u_2007_increm = u_2007_existtotal - u_init
	;


-- STEP 4
-- Update status based on CofO data and assign number of completed units
UPDATE dobdev_jobs
SET
	dcp_status =
		(CASE 
			WHEN c_u_latest IS NULL THEN dcp_status
			WHEN u_prop = 0 THEN dcp_status
			WHEN u_net IS NOT NULL AND (c_u_latest / u_prop) >= 0.8 OR status_latest = 'SIGNED OFF' OR status_latest = 'SIGNED-OFF' OR c_type_latest = 'C- CO' THEN 'Complete'
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


-- STEP 5
-- Update column to capture outstanding (non-complete) units

UPDATE dobdev_jobs
	SET u_net_incomplete =
		CASE 
			WHEN u_net IS NOT NULL AND dcp_status LIKE '%Complete%' THEN 0
			WHEN u_net IS NOT NULL AND dcp_status <> 'Complete' THEN (u_net - u_net_complete)
			WHEN u_init IS NULL AND u_prop IS NOT NULL AND c_u_latest IS NOT NULL THEN u_prop - c_u_latest
			ELSE u_net
		END;


-- STEP 6
-- Tag projects that have been inactive for at least 5 years

UPDATE dobdev_jobs
	SET x_inactive =
		(CASE
			WHEN (CURRENT_DATE - status_date)/365 >= 5 THEN TRUE
			ELSE FALSE
		END)
	WHERE
		dcp_status <> 'Complete'
		AND dcp_status <> 'Complete (demolition)'
		AND status_latest <> 'SIGNED OFF'
		AND status_latest <> 'SIGNED-OFF';

UPDATE dobdev_jobs
	SET x_inactive = false
	WHERE
		x_inactive IS NULL;

		