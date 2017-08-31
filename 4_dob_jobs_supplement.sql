-- Extra step given limitations of DOB data -- append data with completions from prior datasets, which do not appear in latest dataset

ALTER TABLE dob_jobs
	ADD COLUMN x_datafreshness text,
	ADD COLUMN address text;

INSERT INTO dob_jobs
(
	the_geom,
	address,
	bbl,
	block,
	boro,
	lot,
	dob_type,
	dob_occ_init,
	dob_occ_prop,
	xunits_init_raw,
	xunits_prop_raw,
	dob_status,
	dob_status_date,
	dob_adate,
	dob_ddate,
	dob_pdate,
	dob_qdate,
	dob_rdate,
	dob_xdate,
	dob_job_number,
	x_datafreshness
)

WITH joined AS (
SELECT 
	a.*,
	b.dob_job_number as a_july2017match
FROM nchatterjee.q42016_permits_dates_cofos_v4 as a
	LEFT JOIN dob_jobs as b
ON
	a.dob_job_number = b.dob_job_number
)

SELECT
	the_geom,
	dob_permit_address as address,
	dob_permit_bbl as bbl,
	dob_permit_block as block,
	dob_permit_borough as boro,
	dob_permit_lot as lot,
	dcp_type_2 as dob_type,
	dob_permit_exist_occupancy as dob_occ_init,
	dob_permit_proposed_occupancy as dob_occ_prop,
	dob_permit_exist_units as xunits_init_raw,
	dob_permit_proposed_units as xunits_prop_raw,
	dob_permit_current_job_status as dob_status,
	dob_permit_status_update as dob_status_date,
	dob_adate,
	dob_ddate,
	dob_pdate,
	dob_qdate,
	dob_rdate,
	dob_xdate,
	dob_job_number,
	'January 2017' AS x_datafreshness
FROM
	joined
WHERE
	a_july2017match IS NULL 
	AND dcp_pipeline_status in ('Complete', 'Demolition (complete)','Partial complete');

UPDATE dob_jobs
	SET
		boro =
			(CASE
				WHEN boro = '1' THEN 'Manhattan'
				WHEN boro = '2' THEN 'Bronx'
				WHEN boro = '3' THEN 'Brooklyn'
				WHEN boro = '4' THEN 'Queens'
				WHEN boro = '5' THEN 'Staten Island'
				ELSE boro
			END),
		dob_type =
			(CASE
				WHEN dob_type = 'New Building' THEN 'NB'
				WHEN dob_type = 'Alteration' THEN 'A1'
				WHEN dob_type = 'Demolition' THEN 'DM'
				ELSE dob_type
			END);







-- SELECT
-- the_geom,
-- dob_permit_address as address,
-- dob_permit_bbl as bbl,
-- dob_permit_block as block,
-- dob_permit_borough as boro,
-- dob_permit_lot as lot,
-- dcp_type_2 as dob_type,
-- dob_permit_exist_occupancy as dob_occ_exist,
-- dob_permit_proposed_occupancy as dob_occ_prop,
-- dob_permit_exist_units as xunits_init_raw,
-- dob_permit_proposed_units as xunits_prop_raw,
-- dob_permit_current_job_status as dob_status,
-- dob_permit_status_update as dob_status_date,
-- dob_adate,
-- dob_ddate,
-- dob_pdate,
-- dob_qdate,
-- dob_rdate,
-- dob_xdate,
-- dob_job_number
-- FROM (

-- SELECT 
-- a.*,
-- b.dob_job_number as a_july2017match
-- FROM q42016_permits_dates_cofos_v4 as a
-- LEFT JOIN nchatterjee.dob_jobs as b
-- on a.dob_job_number = b.dob_job_number
-- ) as c

-- WHERE c.a_july2017match is null AND dcp_pipeline_status in ('Complete', 'Demolition (complete)','Partial complete')

-- -- Save as dob_jobs_jan17

-- -- Capture datafreshness

-- ALTER TABLE dob_jobs_jan17
-- ADD COLUMN x_datafreshness text;
-- UPDATE dob_jobs_jan17
-- SET x_datafreshness = 'January 2017';

-- --Standardize values to mimic latest data

-- UPDATE dob_jobs_jan17
-- SET boro = CASE
-- 	WHEN boro = '1' THEN 'Manhattan'
-- 	WHEN boro = '2' THEN 'Bronx'
-- 	WHEN boro = '3' THEN 'Brooklyn'
-- 	WHEN boro = '4' THEN 'Queens'
-- 	WHEN boro = '5' THEN 'Staten Island'
-- 	ELSE boro END;

-- UPDATE dob_jobs_jan17
-- SET type = CASE
-- 	WHEN type = 'New Building' THEN 'NB'
-- 	WHEN type = 'Alteration' THEN 'A1'
-- 	WHEN type = 'Demolition' THEN 'DM'
-- 	ELSE type END
	






-- -- Start at Part 2 of standard jobs processing


-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN dcp_occ_init text;
-- UPDATE dob_jobs_jan17
-- 	SET dcp_occ_init =
-- 	(SELECT occupancy.dcp FROM occupancy
-- 	WHERE occupancy.dob = dob_occ_exist); 

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN dcp_occ_prop text;
-- UPDATE dob_jobs_jan17
-- 	SET dcp_occ_prop =
-- 	(SELECT occupancy.dcp FROM occupancy
-- 	WHERE occupancy.dob = dob_occ_prop); 

-- -- Create field to create single category to express occupancy type; order of case/when logic is intended to capture most likely impact of development; already limited to residential, so extraction not needed

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN dcp_category_occupancy text;
-- UPDATE dob_jobs_jan17
-- 	SET dcp_category_occupancy = CASE
-- 		WHEN dcp_occ_prop = 'Other Accomodations' THEN 'Other Accomodations'
-- 		WHEN dcp_occ_prop = 'Residential' OR dcp_occ_init = 'Residential' THEN 'Residential'
-- 		WHEN dcp_occ_init = 'Other Accomodations' THEN 'Other Accomodations'
-- 		ELSE 'Other'
-- 	END;

-- --Create new fields for existing and proposed units, which is integer but also maintains null values from original DOB field (since this may imply erroneous record); modified since existing units is number in this dataset
-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN "units_init" integer;
-- UPDATE dob_jobs_jan17
-- 	SET units_init = xunits_init_raw where xunits_init_raw is not null;

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN "units_prop" integer;
-- UPDATE dob_jobs_jan17
-- 	SET units_prop = xunits_prop_raw::integer where xunits_prop_raw <>''; 

-- -- Create field to capture incremental units: negative for demolitions, proposed for new buildings, and net change for alterations (note: if an alteration is missing value for existing or proposed units, value set to null)

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN "units_net" integer;
-- UPDATE dob_jobs_jan17 
-- 	SET units_net = CASE
-- 		WHEN type = 'DM' THEN units_init * -1
-- 		WHEN type = 'NB' THEN units_prop
-- 		WHEN type = 'A1' AND units_init IS NOT null AND units_prop IS NOT null THEN units_prop - units_init
-- 		ELSE null 
-- 	END;

-- -- Create field to translate DCP status categories  (note: demolitions considered complete if status is permit issued; withdrawal flag n/a in this dataset)

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN "dcp_status" text;
-- UPDATE dob_jobs_jan17
-- SET dcp_status = 
-- 	(SELECT status.dcp FROM status
-- 	WHERE status.dob = dob_jobs_jan17.dob_status);
-- UPDATE dob_jobs_jan17
-- 	set dcp_status = 'Complete (demolition)' WHERE type = 'DM' AND dcp_status in ('Complete','Permit issued');



-- -- Create field to translate to DCP development types

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN dcp_category_development text;
-- UPDATE dob_jobs_jan17
-- 	SET dcp_category_development = CASE
-- 		WHEN type = 'NB' THEN 'New Building'
-- 		WHEN type = 'A1' THEN 'Alteration'
-- 		WHEN type = 'DM' THEN 'Demolition'
-- 		ELSE null
-- 	END;


-- -- Address field already created

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN x_dup_id text;
-- UPDATE dob_jobs_jan17
-- 	SET x_dup_id = CONCAT(type,bbl,address);

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN x_dup_id_maxdate date;
-- UPDATE nchatterjee.dob_jobs_jan17
-- 	SET x_dup_id_maxdate = x
-- 	FROM (SELECT 
--           	x_dup_id,
--           	MAX(dob_status_date) as x
--           FROM nchatterjee.dob_jobs_jan17
--           GROUP BY x_dup_id) as a
-- 	WHERE nchatterjee.dob_jobs_jan17.x_dup_id = a.x_dup_id;

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN x_dup_flag text;
-- UPDATE dob_jobs_jan17
-- 	SET x_dup_flag = 'Possible duplicate' WHERE x_dup_id_maxdate <> dob_status_date;


-- -- Create fields to capture join with CofOs (requires processing CofO data first)

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN units_complete_2007_net integer,
-- 	ADD COLUMN units_complete_2008_increm_net integer,
-- 	ADD COLUMN units_complete_2009_increm_net integer,
-- 	ADD COLUMN units_complete_2010_increm_net integer,
-- 	ADD COLUMN units_complete_2011_increm_net integer,
-- 	ADD COLUMN units_complete_2012_increm_net integer,
-- 	ADD COLUMN units_complete_2013_increm_net integer,
-- 	ADD COLUMN units_complete_2014_increm_net integer,
-- 	ADD COLUMN units_complete_2015_increm_net integer,
-- 	ADD COLUMN units_complete_2016_increm_net integer,
-- 	ADD COLUMN units_complete_2017_increm_net integer,
-- 	ADD COLUMN cofo_latestunits integer,
-- 	ADD COLUMN units_complete_net integer,
-- 	ADD COLUMN cofo_latest date,
-- 	ADD COLUMN cofo_earliest date,
-- 	ADD COLUMN cofo_latesttype text;


-- UPDATE dob_jobs_jan17
-- SET
-- 	units_complete_2007_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2007 <> 0 THEN b.units_2007 - units_init ELSE b.units_2007 END,
-- 	units_complete_2008_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2008_increm <> 0  THEN b.units_2008_increm - units_init ELSE b.units_2008_increm END,
-- 	units_complete_2009_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2009_increm <> 0  THEN b.units_2009_increm - units_init ELSE b.units_2009_increm END,
-- 	units_complete_2010_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2010_increm <> 0  THEN b.units_2010_increm - units_init ELSE b.units_2010_increm END,
-- 	units_complete_2011_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2011_increm <> 0  THEN b.units_2011_increm - units_init ELSE b.units_2011_increm END,
-- 	units_complete_2012_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2012_increm <> 0  THEN b.units_2012_increm - units_init ELSE b.units_2012_increm END,
-- 	units_complete_2013_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2013_increm <> 0  THEN b.units_2013_increm - units_init ELSE b.units_2013_increm END,
-- 	units_complete_2014_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2014_increm <> 0  THEN b.units_2014_increm - units_init ELSE b.units_2014_increm END,
-- 	units_complete_2015_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2015_increm <> 0  THEN b.units_2015_increm - units_init ELSE b.units_2015_increm END,
-- 	units_complete_2016_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2016_increm <> 0  THEN b.units_2016_increm - units_init ELSE b.units_2016_increm END,
-- 	units_complete_2017_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2017_increm <> 0  THEN b.units_2017_increm - units_init ELSE b.units_2017_increm END,
-- 	cofo_latestunits = b.units_latest,
-- 	cofo_latest = b.cofo_latest,
-- 	cofo_earliest = b.cofo_earliest,
-- 	cofo_latesttype = b.cofo_latesttype

-- FROM dob_cofos b

-- WHERE dob_jobs_jan17.dob_job_number = b.cofo_job_number;

-- --Update status based on CofO data

-- UPDATE dob_jobs_jan17
-- SET
-- 	dcp_status = CASE 
-- 		WHEN cofo_latestunits is null THEN dcp_status
-- 		WHEN units_prop = 0 THEN dcp_status
-- 		WHEN (cofo_latestunits / units_prop) >= 0.8 THEN 'Complete'
-- 		WHEN (cofo_latestunits / units_prop) < 0.8 THEN 'Partial complete'
-- 		ELSE dcp_status END;


-- -- Update units complete column, also capturing demolitions demolitions

-- UPDATE dob_jobs_jan17
-- SET
-- 	units_complete_2007_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2007' THEN units_net ELSE units_complete_2007_net END,
-- 	units_complete_2008_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2008' THEN units_net ELSE units_complete_2008_increm_net END,
-- 	units_complete_2009_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2009' THEN units_net ELSE units_complete_2009_increm_net END,
-- 	units_complete_2010_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2010' THEN units_net ELSE units_complete_2010_increm_net END,
-- 	units_complete_2011_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2011' THEN units_net ELSE units_complete_2011_increm_net END,
-- 	units_complete_2012_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2012' THEN units_net ELSE units_complete_2012_increm_net END,
-- 	units_complete_2013_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2013' THEN units_net ELSE units_complete_2013_increm_net END,
-- 	units_complete_2014_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2014' THEN units_net ELSE units_complete_2014_increm_net END,
-- 	units_complete_2015_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2015' THEN units_net ELSE units_complete_2015_increm_net END,
-- 	units_complete_2016_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2016' THEN units_net ELSE units_complete_2016_increm_net END,
-- 	units_complete_2017_increm_net = CASE WHEN dcp_status = 'Complete (demolition)' AND left (dob_qdate::text, 4) = '2017' THEN units_net ELSE units_complete_2017_increm_net END,
-- 	units_complete_net = CASE 
-- 		WHEN dcp_category_development = 'Alteration' THEN cofo_latestunits - units_init 
-- 		WHEN dcp_status = 'Complete (demolition)' THEN units_net
-- 		ELSE cofo_latestunits END;

-- ALTER TABLE dob_jobs_jan17
-- 	ADD COLUMN units_incomplete_net integer;

-- UPDATE dob_jobs_jan17
-- 	SET units_incomplete_net = CASE 
-- 	WHEN units_complete_net is not null THEN (units_net - units_complete_net)
-- 	ELSE units_net END;


-- -- Insert into jobs table

-- INSERT INTO nchatterjee.dob_jobs (
--   the_geom, 
--   the_geom_webmercator,
--   x_datafreshness,
--   address,
--   bbl,
--   block,
--   boro,
--   cofo_earliest,
--   cofo_latest,
--   cofo_latesttype,
--   cofo_latestunits,
--   dcp_category_development,
--   dcp_category_occupancy,
--   dcp_occ_init,
--   dcp_occ_prop,
--   dcp_status,
--   dob_adate,
--   dob_ddate,
--   dob_job_number,
--   dob_occ_exist,
--   dob_occ_prop,
--   dob_pdate,
--   dob_qdate,
--   dob_rdate,
--   dob_status,
--   dob_xdate,
--   lot,
--   type,
--   units_complete_2007_net,
--   units_complete_2008_increm_net,
--   units_complete_2009_increm_net,
--   units_complete_2010_increm_net,
--   units_complete_2011_increm_net,
--   units_complete_2012_increm_net,
--   units_complete_2013_increm_net,
--   units_complete_2014_increm_net,
--   units_complete_2015_increm_net,
--   units_complete_2016_increm_net,
--   units_complete_2017_increm_net,
--   units_complete_net,
--   units_incomplete_net,
--   units_init,
--   units_net,
--   units_prop,
--   x_dup_flag,
--   x_dup_id)

-- SELECT
--   the_geom, 
--   the_geom_webmercator,
--   x_datafreshness,
--   address,
--   bbl,
--   block,
--   boro,
--   cofo_earliest,
--   cofo_latest,
--   cofo_latesttype,
--   cofo_latestunits,
--   dcp_category_development,
--   dcp_category_occupancy,
--   dcp_occ_init,
--   dcp_occ_prop,
--   dcp_status,
--   dob_adate,
--   dob_ddate,
--   dob_job_number,
--   dob_occ_exist,
--   dob_occ_prop,
--   dob_pdate,
--   dob_qdate,
--   dob_rdate,
--   dob_status,
--   dob_xdate,
--   lot,
--   type,
--   units_complete_2007_net,
--   units_complete_2008_increm_net,
--   units_complete_2009_increm_net,
--   units_complete_2010_increm_net,
--   units_complete_2011_increm_net,
--   units_complete_2012_increm_net,
--   units_complete_2013_increm_net,
--   units_complete_2014_increm_net,
--   units_complete_2015_increm_net,
--   units_complete_2016_increm_net,
--   units_complete_2017_increm_net,
--   units_complete_net,
--   units_incomplete_net,
--   units_init,
--   units_net,
--   units_prop,
--   x_dup_flag,
--   x_dup_id

-- FROM nchatterjee.dob_jobs_jan17