-- General background and watchouts: [ADD here about receiving data from DOB]
	--Open Data: ____

-- Data specifications (July 2017)
	--Job types: NB, A1, DM

-- Part 1: Import as CSV (e.g., "dob_cofos_orig") to Carto for cleaning (carto makes lower case and replaces spaces and special characters with _)

ALTER TABLE dob_cofos_orig
	RENAME COLUMN "job__" to "cofo_job_number";

ALTER TABLE dob_cofos_orig
	RENAME COLUMN "effective_date" to "cofo_date";
ALTER TABLE dob_cofos_orig
	ALTER COLUMN "cofo_date" TYPE date using TO_DATE(cofo_date, 'MM/DD/YYYY');

ALTER TABLE dob_cofos_orig
	RENAME COLUMN "__of_dwelling_units" to "cofo_units";	
ALTER TABLE dob_cofos_orig
	ALTER COLUMN "cofo_units" TYPE integer USING (cofo_units::text::integer);

ALTER TABLE dob_cofos_orig
	RENAME COLUMN "certificatetype" to "cofo_type";	

ALTER TABLE dob_cofos_orig
	ADD COLUMN cofo_year text;
UPDATE dob_cofos_orig
	SET cofo_year = left(cofo_date::text,4);


--Part 2: Clean data and pivot to capture incremental units, per year, per job

CREATE TABLE dob_cofos AS (

-- This selects the largest CofO per job, for each year
WITH dob_cofos_byjob AS
(SELECT
	cofo_job_number,
	max(CASE WHEN cofo_year = '2007' THEN cofo_units END) as units_2007,           
	max(CASE WHEN cofo_year = '2008' THEN cofo_units END) as units_2008,
	max(CASE WHEN cofo_year = '2009' THEN cofo_units END) as units_2009,           
	max(CASE WHEN cofo_year = '2010' THEN cofo_units END) as units_2010,
 	max(CASE WHEN cofo_year = '2011' THEN cofo_units END) as units_2011,
 	max(CASE WHEN cofo_year = '2012' THEN cofo_units END) as units_2012,  
	max(CASE WHEN cofo_year = '2013' THEN cofo_units END) as units_2013,
 	max(CASE WHEN cofo_year = '2014' THEN cofo_units END) as units_2014,
 	max(CASE WHEN cofo_year = '2015' THEN cofo_units END) as units_2015,
 	max(CASE WHEN cofo_year = '2016' THEN cofo_units END) as units_2016,
 	max(CASE WHEN cofo_year = '2017' THEN cofo_units END) as units_2017,
 	max(cofo_date) as cofo_latest,
 	min(cofo_date) as cofo_earliest,
 	min(cofo_type) as cofo_latesttype -- MAKE SURE TO CHECK THIS IS STILL IN SAME FORMAT AND LASTEST IS EARLIEST IN ABC
FROM dob_cofos_orig
GROUP BY cofo_job_number),

-- This selects CofO units each year, as well as units in the most recent year
dob_cofos_byjob_unitslatest AS
(SELECT
	*,
	coalesce(units_2017,units_2016,units_2015,units_2014, units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) as units_latest
FROM
	dob_cofos_byjob),

-- Compares earlier CofOs to most recent; if earlier years are erroneously higher than most recent, replaces with most recent  
dob_cofos_byjob_cleaned AS
(SELECT
	cofo_job_number,
	CASE
		WHEN units_2007 > units_latest THEN units_latest
		WHEN units_2007 IS NULL THEN 0
		ELSE units_2007 
	END as units_2007,
	CASE
		WHEN units_2008 > units_latest THEN units_latest
		WHEN units_2008 IS NULL THEN 0
		ELSE units_2008 
	END as units_2008,
	CASE
		WHEN units_2009 > units_latest THEN units_latest
		WHEN units_2009 IS NULL THEN 0
		ELSE units_2009 
	END as units_2009,
	CASE
		WHEN units_2010 > units_latest THEN units_latest
		WHEN units_2010 IS NULL THEN 0
		ELSE units_2010 
	END as units_2010,
	CASE
		WHEN units_2011 > units_latest THEN units_latest
		WHEN units_2011 IS NULL THEN 0
		ELSE units_2011 
	END as units_2011,
	CASE
		WHEN units_2012 > units_latest THEN units_latest
		WHEN units_2012 IS NULL THEN 0
		ELSE units_2012 
	END as units_2012,
	CASE
		WHEN units_2013 > units_latest THEN units_latest
		WHEN units_2013 IS NULL THEN 0
		ELSE units_2013 
	END as units_2013,
	CASE
		WHEN units_2014 > units_latest THEN units_latest
		WHEN units_2014 IS NULL THEN 0
		ELSE units_2014 
	END as units_2014,
	CASE
		WHEN units_2015 > units_latest THEN units_latest
		WHEN units_2015 IS NULL THEN 0
		ELSE units_2015 
	END as units_2015,
	CASE
		WHEN units_2016 > units_latest THEN units_latest
		WHEN units_2016 IS NULL THEN 0
		ELSE units_2016 
	END as units_2016,
	CASE
		WHEN units_2017 > units_latest THEN units_latest
		WHEN units_2017 IS NULL THEN 0
		ELSE units_2017 
	END as units_2017,
	units_latest,
	cofo_latest,
	cofo_earliest,
	cofo_latesttype		
FROM
	dob_cofos_byjob_unitslatest)

-- Calculate incremental unit change per change
SELECT
	cofo_job_number,
	units_2007,
	CASE WHEN units_2008 <> 0 THEN units_2008 - units_2007 ELSE 0 END as units_2008_increm,
	CASE WHEN units_2009 <> 0 THEN units_2009 - greatest(units_2008,units_2007) ELSE 0 END as units_2009_increm,
	CASE WHEN units_2010 <> 0 THEN units_2010 - greatest(units_2009,units_2008,units_2007) ELSE 0 END as units_2010_increm,
	CASE WHEN units_2011 <> 0 THEN units_2011 - greatest(units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2011_increm,
	CASE WHEN units_2012 <> 0 THEN units_2012 - greatest(units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2012_increm,
	CASE WHEN units_2013 <> 0 THEN units_2013 - greatest(units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2013_increm,
	CASE WHEN units_2014 <> 0 THEN units_2014 - greatest(units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2014_increm,
	CASE WHEN units_2015 <> 0 THEN units_2015 - greatest(units_2014,units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2015_increm,
	CASE WHEN units_2016 <> 0 THEN units_2016 - greatest(units_2015,units_2014,units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2016_increm,
	CASE WHEN units_2017 <> 0 THEN units_2017 - greatest(units_2016,units_2015,units_2014,units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2017_increm,
	units_latest,
	cofo_latest,
	cofo_earliest,
	cofo_latesttype
FROM
	dob_cofos_byjob_cleaned)