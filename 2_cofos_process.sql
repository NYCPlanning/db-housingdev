-- Create table dob_cofos as the results of the following query. 
-- This selects the largest CofO per job, for each year. Multiple temporary CofOs could be issued in one year. We select the largest in order to get a single value for each year. If no CofO were issued in a given year, the u_20XX_existtotal field will be blank
-- Note: Make sure to check that cofo_type is still in same format and the complete status is earlier in ABC

SELECT
	cofo_job_number,
	max(CASE WHEN cofo_year = '2007' THEN cofo_units END) as u_2007_existtotal,
	max(CASE WHEN cofo_year = '2008' THEN cofo_units END) as u_2008_existtotal,
	max(CASE WHEN cofo_year = '2009' THEN cofo_units END) as u_2009_existtotal,
	max(CASE WHEN cofo_year = '2010' THEN cofo_units END) as u_2010_existtotal,
 	max(CASE WHEN cofo_year = '2011' THEN cofo_units END) as u_2011_existtotal,
 	max(CASE WHEN cofo_year = '2012' THEN cofo_units END) as u_2012_existtotal,
	max(CASE WHEN cofo_year = '2013' THEN cofo_units END) as u_2013_existtotal,
 	max(CASE WHEN cofo_year = '2014' THEN cofo_units END) as u_2014_existtotal,
 	max(CASE WHEN cofo_year = '2015' THEN cofo_units END) as u_2015_existtotal,
 	max(CASE WHEN cofo_year = '2016' THEN cofo_units END) as u_2016_existtotal,
 	max(CASE WHEN cofo_year = '2017' THEN cofo_units END) as u_2017_existtotal,
 	max(cofo_date) AS c_date_latest,
 	min(cofo_date) AS c_date_earliest,
 	min(cofo_type) AS c_type_latest,
 	NULL::numeric AS c_u_latest
FROM dob_cofos_orig
GROUP BY cofo_job_number

-- Update dob_cofos to capture the latest dwelling unit count on the CofO from the most recent year

UPDATE dob_cofos
	SET 
		c_u_latest = COALESCE(
			u_2017_existtotal,
			u_2016_existtotal,
			u_2015_existtotal,
			u_2014_existtotal,
			u_2013_existtotal,
			u_2012_existtotal,
			u_2011_existtotal,
			u_2010_existtotal,
			u_2009_existtotal,
			u_2008_existtotal,
			u_2007_existtotal);
