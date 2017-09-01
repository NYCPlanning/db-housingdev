-- SAVE THE RESULTS OF THIS FOLLOWING QUERY (steps 1-4) AS dob_cofos
-- RUN ALL STEPS AT ONCE


-- Overview:
-- STEP 1: This selects the largest CofO per job, for each year. Multiple temporary CofOs could be issued in one year. We select the largest in order to get a single value for each year. If no CofO were issued in a cgiven year, the u_20XX_totalexist field will be blank
-- -- Step 1 Note: Make sure to check that cofo_type is still in same format and the complete status is earlier in ABC
-- STEP 2: This adds a new field u_latest that captures the number of units on the CofO from the most recent year
-- STEP 3: Compares earlier CofOs to most recent; if earlier years are erroneously higher than the most recent CofO this query replaces the unit count with most recent lower unit count.
-- -- Step 3 Note: Not sure we should trust Step 3 as is. There are many cases of building alterations where units are taken out of comission while renovations are being done, so an earlier CofO would have a higher unit count if the project is still being developed.



-- STEP 1
-- Create table called dob_cofos as the results of the following query
WITH dob_cofos_byjob AS
(SELECT
	cofo_job_number,
	max(CASE WHEN cofo_year = '2007' THEN cofo_units END) as u_2007_totalexist,
	max(CASE WHEN cofo_year = '2008' THEN cofo_units END) as u_2008_totalexist,
	max(CASE WHEN cofo_year = '2009' THEN cofo_units END) as u_2009_totalexist,
	max(CASE WHEN cofo_year = '2010' THEN cofo_units END) as u_2010_totalexist,
 	max(CASE WHEN cofo_year = '2011' THEN cofo_units END) as u_2011_totalexist,
 	max(CASE WHEN cofo_year = '2012' THEN cofo_units END) as u_2012_totalexist,
	max(CASE WHEN cofo_year = '2013' THEN cofo_units END) as u_2013_totalexist,
 	max(CASE WHEN cofo_year = '2014' THEN cofo_units END) as u_2014_totalexist,
 	max(CASE WHEN cofo_year = '2015' THEN cofo_units END) as u_2015_totalexist,
 	max(CASE WHEN cofo_year = '2016' THEN cofo_units END) as u_2016_totalexist,
 	max(CASE WHEN cofo_year = '2017' THEN cofo_units END) as u_2017_totalexist,
 	max(cofo_date) AS cofo_latest,
 	min(cofo_date) AS cofo_earliest,
 	min(cofo_type) AS cofo_latesttype
FROM dob_cofos_orig
GROUP BY cofo_job_number),

-- STEP 2
dob_cofos_byjob_unitslatest AS
(SELECT
	*,
	COALESCE(
		u_2017_totalexist,
		u_2016_totalexist,
		u_2015_totalexist,
		u_2014_totalexist,
		u_2013_totalexist,
		u_2012_totalexist,
		u_2011_totalexist,
		u_2010_totalexist,
		u_2009_totalexist,
		u_2008_totalexist,
		u_2007_totalexist) as u_latest
FROM
	dob_cofos_byjob)

-- STEP 3
SELECT
	cofo_job_number,
	(CASE
		WHEN u_2007_totalexist > u_latest THEN u_latest
		ELSE u_2007_totalexist 
	END) as u_2007_totalexist,
	(CASE
		WHEN u_2008_totalexist > u_latest THEN u_latest
		ELSE u_2008_totalexist 
	END) as u_2008_totalexist,
	(CASE
		WHEN u_2009_totalexist > u_latest THEN u_latest
		ELSE u_2009_totalexist 
	END) as u_2009_totalexist,
	(CASE
		WHEN u_2010_totalexist > u_latest THEN u_latest
		ELSE u_2010_totalexist 
	END) as u_2010_totalexist,
	(CASE
		WHEN u_2011_totalexist > u_latest THEN u_latest
		ELSE u_2011_totalexist 
	END) as u_2011_totalexist,
	(CASE
		WHEN u_2012_totalexist > u_latest THEN u_latest
		ELSE u_2012_totalexist 
	END) as u_2012_totalexist,
	(CASE
		WHEN u_2013_totalexist > u_latest THEN u_latest
		ELSE u_2013_totalexist 
	END) as u_2013_totalexist,
	(CASE
		WHEN u_2014_totalexist > u_latest THEN u_latest
		ELSE u_2014_totalexist 
	END) as u_2014_totalexist,
	(CASE
		WHEN u_2015_totalexist > u_latest THEN u_latest
		ELSE u_2015_totalexist 
	END) as u_2015_totalexist,
	(CASE
		WHEN u_2016_totalexist > u_latest THEN u_latest
		ELSE u_2016_totalexist 
	END) as u_2016_totalexist,
	(CASE
		WHEN u_2017_totalexist > u_latest THEN u_latest
		ELSE u_2017_totalexist 
	END) as u_2017_totalexist,
	u_latest,
	cofo_latest,
	cofo_earliest,
	cofo_latesttype		
FROM
	dob_cofos_byjob_unitslatest

-- SAVE THE RESULTS OF THIS QUERY AS dob_cofos
