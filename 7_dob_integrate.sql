-- Create fields to capture join with CofOs (requires processing CofO data first)

ALTER TABLE dob_jobs
	ADD COLUMN units_complete_2007_net integer,
	ADD COLUMN units_complete_2008_increm_net integer,
	ADD COLUMN units_complete_2009_increm_net integer,
	ADD COLUMN units_complete_2010_increm_net integer,
	ADD COLUMN units_complete_2011_increm_net integer,
	ADD COLUMN units_complete_2012_increm_net integer,
	ADD COLUMN units_complete_2013_increm_net integer,
	ADD COLUMN units_complete_2014_increm_net integer,
	ADD COLUMN units_complete_2015_increm_net integer,
	ADD COLUMN units_complete_2016_increm_net integer,
	ADD COLUMN units_complete_2017_increm_net integer,
	ADD COLUMN cofo_latestunits integer,
	ADD COLUMN units_complete_net integer,
	ADD COLUMN cofo_latest date,
	ADD COLUMN cofo_earliest date,
	ADD COLUMN cofo_latesttype text;

-- This calculation updates the very first incremental change value to subtract the number of exisitng units that was listed in the jobs record
UPDATE dob_jobs
SET
	units_complete_2007_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2007 <> 0 THEN b.units_2007 - units_init ELSE b.units_2007 END,
	units_complete_2008_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2008_increm <> 0 AND (b.units_2007) = 0 THEN b.units_2008_increm - units_init 
			ELSE b.units_2008_increm 
		END,
	units_complete_2009_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2009_increm <> 0 AND (b.units_2007 + b.units_2008) = 0 THEN b.units_2009_increm - units_init 
			ELSE b.units_2009_increm 
		END,
	units_complete_2010_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2010_increm <> 0 AND (b.units_2007 + b.units_2008 + b.units_2009) = 0 THEN b.units_2010_increm - units_init 
			ELSE b.units_2010_increm 
		END,
	units_complete_2011_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2011_increm <> 0 AND (b.units_2007 + b.units_2008 + b.units_2009 + b.units_2010) = 0 THEN b.units_2011_increm - units_init 
			ELSE b.units_2011_increm 
		END,
	units_complete_2012_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2012_increm <> 0 AND (b.units_2007 + b.units_2008 + b.units_2009 + b.units_2010 + b.units_2011) = 0 THEN b.units_2012_increm - units_init 
			ELSE b.units_2012_increm 
		END,
	units_complete_2013_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2013_increm <> 0 AND (b.units_2007 + b.units_2008 + b.units_2009 + b.units_2010 + b.units_2011 + b.units_2012) = 0 THEN b.units_2013_increm - units_init 
			ELSE b.units_2013_increm 
		END,
	units_complete_2014_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2014_increm <> 0 AND (b.units_2007 + b.units_2008 + b.units_2009 + b.units_2010 + b.units_2011 + b.units_2012 + b.units_2013) = 0 THEN b.units_2014_increm - units_init 
			ELSE b.units_2014_increm 
		END,
	units_complete_2015_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2015_increm <> 0 AND (b.units_2007 + b.units_2008 + b.units_2009 + b.units_2010 + b.units_2011 + b.units_2012 + b.units_2013 + b.units_2014) = 0 THEN b.units_2015_increm - units_init 
			ELSE b.units_2015_increm 
		END,
	units_complete_2016_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2016_increm <> 0 AND (b.units_2007 + b.units_2008 + b.units_2009 + b.units_2010 + b.units_2011 + b.units_2012 + b.units_2013 + b.units_2014 + b.units_2015) = 0 THEN b.units_2016_increm - units_init 
			ELSE b.units_2016_increm 
		END,
	units_complete_2017_increm_net = 
		CASE 
			WHEN dcp_category_development = 'Alteration' AND b.units_2017_increm <> 0 AND (b.units_2007 + b.units_2008 + b.units_2009 + b.units_2010 + b.units_2011 + b.units_2012 + b.units_2013 + b.units_2014 + b.units_2015 + b.units_2016) = 0 THEN b.units_2017_increm - units_init 
			ELSE b.units_2017_increm 
		END,
	cofo_latestunits = b.units_latest,
	cofo_latest = b.cofo_latest,
	cofo_earliest = b.cofo_earliest,
	cofo_latesttype = b.cofo_latesttype

FROM dob_cofos b

WHERE dob_jobs.dob_job_number = b.cofo_job_number;


--Update status based on CofO data

UPDATE dob_jobs
SET
	dcp_status = CASE 
		WHEN cofo_latestunits is null THEN dcp_status
		WHEN units_prop = 0 THEN dcp_status
		WHEN (cofo_latestunits / units_prop) >= 0.8 OR dob_status = 'X' THEN 'Complete'
		WHEN (cofo_latestunits / units_prop) < 0.8 THEN 'Partial complete'
		ELSE dcp_status END;


-- Update units complete column, also capturing demolitions in a given year and proxying for CofO date

UPDATE dob_jobs
SET
	units_complete_2007_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2007' THEN units_net ELSE units_complete_2007_net END,
	units_complete_2008_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2008' THEN units_net ELSE units_complete_2008_increm_net END,
	units_complete_2009_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2009' THEN units_net ELSE units_complete_2009_increm_net END,
	units_complete_2010_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2010' THEN units_net ELSE units_complete_2010_increm_net END,
	units_complete_2011_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2011' THEN units_net ELSE units_complete_2011_increm_net END,
	units_complete_2012_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2012' THEN units_net ELSE units_complete_2012_increm_net END,
	units_complete_2013_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2013' THEN units_net ELSE units_complete_2013_increm_net END,
	units_complete_2014_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2014' THEN units_net ELSE units_complete_2014_increm_net END,
	units_complete_2015_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2015' THEN units_net ELSE units_complete_2015_increm_net END,
	units_complete_2016_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2016' THEN units_net ELSE units_complete_2016_increm_net END,
	units_complete_2017_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2017' THEN units_net ELSE units_complete_2017_increm_net END,
	units_complete_net =
		CASE 
			WHEN dcp_category_development = 'Alteration' THEN cofo_latestunits - units_init 
			WHEN dcp_status = 'Complete (demolition)' THEN units_net
			ELSE cofo_latestunits
		END,
	cofo_earliest =
		CASE -- capturing earliest date even though it doesn't actually have a CofO, for filtering in explorer
			WHEN dcp_status = 'Complete (demolition)' THEN dob_qdate
			ELSE cofo_earliest END,
	cofo_latest =
		CASE -- capturing lastest date even though it doesn't actually have a CofO, for filtering in explorer
			WHEN dcp_status = 'Complete (demolition)' THEN dob_qdate
			ELSE cofo_latest
		END;

-- Create and update column to capture outstanding (non-complete) units
ALTER TABLE dob_jobs
	ADD COLUMN units_incomplete_net integer;

UPDATE dob_jobs
	SET units_incomplete_net =
		CASE 
			WHEN units_complete_net is not null THEN (units_net - units_complete_net)
		ELSE units_net END;
