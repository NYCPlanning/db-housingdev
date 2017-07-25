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

-- Capture datafreshness

ALTER TABLE dob_jobs
	ADD COLUMN x_datafreshness text;
UPDATE dob_jobs
	SET x_datafreshness = 'July 2017'



--Part 2: Translate to DCP categories and extract Housing developments. Note: this will require having supplementary Occupancy table, which translate DOB field values to DCP conventions


ALTER TABLE dob_jobs
	ADD COLUMN dcp_category_development text;
UPDATE dob_jobs
	SET dcp_category_development = CASE
		WHEN type = 'NB' THEN 'New Building'
		WHEN type = 'A1' THEN 'Alteration'
		WHEN type = 'DM' THEN 'Demolition'
		ELSE null
	END;


ALTER TABLE dob_jobs_orig
	ADD COLUMN dcp_occupancy_exist text;
UPDATE dob_jobs_orig
	SET dcp_occupancy_exist =
	(SELECT occupancy.dcp FROM occupancy
	WHERE occupancy.dob = dob_occupancy_exist); 

ALTER TABLE dob_jobs_orig
	ADD COLUMN dcp_occupancy_prop text;
UPDATE dob_jobs_orig
	SET dcp_occupancy_prop =
	(SELECT occupancy.dcp FROM occupancy
	WHERE occupancy.dob = dob_occupancy_prop); 

-- Create field to create single category to express occupancy type; order of case/when logic is intended to capture most likely impact of development; extract only residential 

ALTER TABLE dob_jobs_orig
	ADD COLUMN dcp_category_occupancy text;
UPDATE dob_jobs_orig
	SET dcp_category_occupancy = CASE
		WHEN dcp_occupancy_prop = 'Other Accomodations' THEN 'Other Accomodations'
		WHEN dcp_occupancy_prop = 'Residential' OR dcp_occupancy_exist = 'Residential' THEN 'Residential'
		WHEN dcp_occupancy_exist = 'Other Accomodations' THEN 'Other Accomodations'
		ELSE 'Other'
	END;

SELECT *
FROM dob_jobs_orig
WHERE dcp_category_occupancy in ('Other Accomodations', 'Residential') 

-- Save as new file (e.g., dob_jobs)


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
	SET units_net = CASE
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
	(SELECT status.dcp FROM status
	WHERE status.dob = dob_jobs.dob_status);
UPDATE dob_jobs
	SET dcp_status = 'Withdrawn' WHERE withdrawal_flag = 'Withdrawn';
UPDATE dob_jobs
	set dcp_status = 'Complete (demolition)' WHERE type = 'DM' AND dcp_status in ('Complete','Permit issued');


-- Part 5 Create address field and flag suspected duplicates; create unique ID based on matching job types, address and BBL; identify most recent status update date associated with unique ID; if records status update date does not match, flagged as potential duplicate

ALTER TABLE dob_jobs
	ADD COLUMN address text;
UPDATE dob_jobs
	SET address = CONCAT(address_house,' ',address_street);

ALTER TABLE dob_jobs
	ADD COLUMN x_dup_id text;
UPDATE dob_jobs
	SET x_dup_id = CONCAT(type,bbl,address);

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


-- Part 6: GEOCODE
-- Part 6a: pull in geographies from previous pipeline
UPDATE dob_jobs
SET the_geom = b.the_geom
FROM q42016_permits_dates_cofos_v4 as b
WHERE dob_jobs.dob_job_number = b.dob_job_number

--Part 6b: pull in geographies from PLUTO
UPDATE dob_jobs
SET the_geom = st_centroid(b.the_geom)
FROM dcp_mappluto as b
WHERE 
	dob_jobs.the_geom is null AND 
	dob_jobs.bbl= b.bbl::text

--Part 6c: pull in geographies from PLUTO, using old BBLs
UPDATE dob_jobs
SET the_geom = st_centroid(b.the_geom)
FROM dcp_mappluto as b
WHERE 
	dob_jobs.the_geom is null AND 
	dob_jobs.bbl= b.appbbl::text

-- Note: engage GSS for further manual geocoding


-- DATA INTEGREation
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



-- Want to correct this to only subtract units_exist from the first imcremental change
UPDATE dob_jobs
SET
	units_complete_2007_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2007 <> 0 THEN b.units_2007 - units_exist ELSE b.units_2007 END,
	units_complete_2008_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2008_increm <> 0  THEN b.units_2008_increm - units_exist ELSE b.units_2008_increm END,
	units_complete_2009_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2009_increm <> 0  THEN b.units_2009_increm - units_exist ELSE b.units_2009_increm END,
	units_complete_2010_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2010_increm <> 0  THEN b.units_2010_increm - units_exist ELSE b.units_2010_increm END,
	units_complete_2011_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2011_increm <> 0  THEN b.units_2011_increm - units_exist ELSE b.units_2011_increm END,
	units_complete_2012_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2012_increm <> 0  THEN b.units_2012_increm - units_exist ELSE b.units_2012_increm END,
	units_complete_2013_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2013_increm <> 0  THEN b.units_2013_increm - units_exist ELSE b.units_2013_increm END,
	units_complete_2014_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2014_increm <> 0  THEN b.units_2014_increm - units_exist ELSE b.units_2014_increm END,
	units_complete_2015_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2015_increm <> 0  THEN b.units_2015_increm - units_exist ELSE b.units_2015_increm END,
	units_complete_2016_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2016_increm <> 0  THEN b.units_2016_increm - units_exist ELSE b.units_2016_increm END,
	units_complete_2017_increm_net = CASE WHEN dcp_category_development = 'Alteration' AND b.units_2017_increm <> 0  THEN b.units_2017_increm - units_exist ELSE b.units_2017_increm END,
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
	units_complete_net = CASE 
		WHEN dcp_category_development = 'Alteration' THEN cofo_latestunits - units_exist 
		WHEN dcp_status = 'Complete (demolition)' THEN units_net
		ELSE cofo_latestunits END,
	cofo_earliest = CASE -- capturing earliest date even though it doesn't actually have a CofO, for filtering in explorer
		WHEN dcp_status = 'Complete (demolition)' THEN dob_qdate
		ELSE cofo_earliest END,
	cofo_latest = CASE -- capturing lastest date even though it doesn't actually have a CofO, for filtering in explorer
		WHEN dcp_status = 'Complete (demolition)' THEN dob_qdate
		ELSE cofo_latest END;

-- Create and update column to capture outstanding (non-complete) units
ALTER TABLE dob_jobs
	ADD COLUMN units_incomplete_net integer;

UPDATE dob_jobs
	SET units_incomplete_net = CASE 
	WHEN units_complete_net is not null THEN (units_net - units_complete_net)
	ELSE units_net END;


-- At this point data was supplemented with January 2017 data (completions), see that file for steps. Assuming supplement is not needed in future, proceed with steps below

-- Append dataset with key geographies used for analyses

ALTER TABLE dob_jobs
	ADD COLUMN geog_mszone201718 text,
	ADD COLUMN geog_pszone201718 text,
	ADD COLUMN geog_csd text,
	ADD COLUMN geog_subdistrict text,
	ADD COLUMN geog_ntacode text,
	ADD COLUMN geog_ntaname text,
	ADD COLUMN geog_censusblock text,
	ADD COLUMN geog_cd text;

UPDATE dob_jobs
	SET geog_mszone201718 = b.dbn
	FROM ms_zones_2017_18 as b
	WHERE st_within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_pszone201718 = b.dbn
	FROM ps_zones_2017_18 as b
	WHERE st_within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_csd = b.schooldist::text
	FROM subdistricts as b
	WHERE st_within(dob_jobs.the_geom,b.the_geom)

UPDATE dob_jobs
	SET geog_subdistrict = b.distzone
	FROM subdistricts as b
	WHERE st_within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_ntacode = b.ntacode
	FROM ntas as b
	WHERE st_within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_ntaname = b.ntaname
	FROM ntas as b
	WHERE st_within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_censusblock = b.bctcb2010
	FROM censusblocks as b
	WHERE st_within(dob_jobs.the_geom,b.the_geom); 

UPDATE dob_jobs
	SET geog_cd = b.borocd::text
	FROM dcp_cdboundaries as b
	WHERE st_within(dob_jobs.the_geom,b.the_geom);
