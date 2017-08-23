-- General background and watchouts: [ADD here about receiving data from DOB]
	--Open Data: ____

-- Data specifications (July 2017)
	--Job types: NB, A1, DM

--Part 2: Clean data and pivot to capture incremental units, per year, per job

-- SAVE THE RESULTS OF THIS FOLLOWING QUERY (steps 1-4) AS dob_cofos

-- STEP 1.
-- This selects the largest CofO per job, for each year. Multiple temporary CofOs could be issued in one year. We select the largest in order to get a single value for each year. If no CofO were issued in a cgiven year, the units_20XX field will be blank
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

-- STEP 2.
-- This adds a new field units_latest that captures the number of units on the CofO from the most recent year
dob_cofos_byjob_unitslatest AS
(SELECT
	*,
	coalesce(units_2017,units_2016,units_2015,units_2014, units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) as units_latest
FROM
	dob_cofos_byjob),

-- STEP 3.
-- Compares earlier CofOs to most recent; if earlier years are erroneously higher than the most recent CofO, this query replaces the unit count with most recent, lower unit count.
-- This query also replaces all NULL values with 0, because....
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

-- STEP 4.
-- Calculate incremental unit change per year from most recent increase in units. If the incremental change is the first 

-- ** I think subtracting the greatest might be wrong in cases where the number of units decreases over time and then increases **

SELECT
	cofo_job_number,
	units_2007,          
	units_2008,
	units_2009,           
	units_2010,
 	units_2011,
 	units_2012,  
	units_2013,
 	units_2014,
 	units_2015,
 	units_2016,
 	units_2017,
	CASE WHEN units_2008 <> 0 THEN units_2008 - units_2007 ELSE 0 END as units_2008_increm,
	CASE WHEN units_2009 <> 0 THEN units_2009 - GREATEST(units_2008,units_2007) ELSE 0 END as units_2009_increm,
	CASE WHEN units_2010 <> 0 THEN units_2010 - GREATEST(units_2009,units_2008,units_2007) ELSE 0 END as units_2010_increm,
	CASE WHEN units_2011 <> 0 THEN units_2011 - GREATEST(units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2011_increm,
	CASE WHEN units_2012 <> 0 THEN units_2012 - GREATEST(units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2012_increm,
	CASE WHEN units_2013 <> 0 THEN units_2013 - GREATEST(units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2013_increm,
	CASE WHEN units_2014 <> 0 THEN units_2014 - GREATEST(units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2014_increm,
	CASE WHEN units_2015 <> 0 THEN units_2015 - GREATEST(units_2014,units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2015_increm,
	CASE WHEN units_2016 <> 0 THEN units_2016 - GREATEST(units_2015,units_2014,units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2016_increm,
	CASE WHEN units_2017 <> 0 THEN units_2017 - GREATEST(units_2016,units_2015,units_2014,units_2013,units_2012,units_2011,units_2010,units_2009,units_2008,units_2007) ELSE 0 END as units_2017_increm,
	units_latest,
	cofo_latest,
	cofo_earliest,
	cofo_latesttype
FROM
	dob_cofos_byjob_cleaned

-- SAVE THE RESULTS OF THIS QUERY AS dob_cofos