-----------------------------------------------------------
-- PART 1 - Ensure data processing worked as expected
-----------------------------------------------------------

-- Check to make sure these queries produce no results

(SELECT * FROM dob_jobs
WHERE u_net IS NOT NULL AND u_init IS NULL)
UNION
(SELECT * FROM dob_jobs
WHERE u_net IS NOT NULL AND u_prop IS NULL)
UNION
(SELECT * FROM dob_jobs
WHERE u_net IS NOT NULL AND u_net_complete IS NULL)
UNION
(SELECT * FROM dob_jobs
WHERE u_net IS NULL AND u_net_complete IS NOT NULL)
UNION
(SELECT * FROM dob_jobs
WHERE u_net IS NOT NULL AND u_net_incomplete IS NULL)
UNION
(SELECT * FROM dob_jobs
WHERE u_net IS NULL AND u_net_incomplete IS NOT NULL)
UNION
(SELECT * FROM dob_jobs
WHERE dob_type = 'DM' AND (u_prop <> 0 or u_prop IS NULL))
UNION
(SELECT * FROM dob_jobs
WHERE dob_type = 'NB' AND (u_init <> 0 or u_init IS NULL))

-- ALTERATIONS WITHOUT AN INITIAL NUMBER OF UNITS REPORTED
-- Check to make sure u_XXXX_increm calculations aren't being done when first CofO appears on record for A1 records where u_init is null
SELECT * FROM dob_jobs
WHERE
dob_type = 'A1'
AND u_2007_totalexist IS NULL
AND cofo_latest IS NOT NULL
AND u_init IS NULL
ORDER BY random()
LIMIT 10

-- ALTERATIONS WITH AN INITIAL NUMBER OF UNITS REPORTED
-- Check to make sure u_XXXX_increm, u_XXXX_totalexist, and u_XXXX_netcomplete are filled in with u_init until first CofO, and that u_XXXX_increm, u_XXXX_totalexist, and u_XXXX_netcomplete all continue to add up afterward.

SELECT * FROM dob_jobs
WHERE
dob_type = 'A1'
AND cofo_latest IS NOT NULL
AND u_init IS NOT NULL
ORDER BY random()
LIMIT 10

-- NEW BUILDINGS
-- Check to make sure u_XXXX_increm, u_XXXX_totalexist, and u_XXXX_netcomplete are filled in with 0 until first CofO, and that u_XXXX_increm, u_XXXX_totalexist, and u_XXXX_netcomplete all continue to add up afterward.

SELECT * FROM dob_jobs
WHERE
dob_type = 'NB'
AND cofo_latest IS NOT NULL
ORDER BY random()
LIMIT 10

-- DEMOLITIONS WITH AN INITIAL NUMBER OF UNITS REPORTED
-- Check to make sure u_XXXX_totalexist fields iare filled in with u_init until demolition is completed, and that u_XXXX_increm, u_XXXX_totalexist, and u_XXXX_netcomplete all continue to add up afterward with u_XXXX_totalexist=0.

SELECT * FROM dob_jobs
WHERE
dob_type = 'DM'
AND u_init IS NOT NULL
AND cofo_latest IS NOT NULL
ORDER BY random()
LIMIT 10

-----------------------------------------------------------
-- PART 2 - Research of records and manual data editing
-----------------------------------------------------------
-- OUTLIERS / DOB DATA ENTRY ERRORS
-- Create table of potential outliers to review and then flag in the x_outlier field (8 largest builds and 8 largest demos)

(SELECT
	* 
FROM
	hkates.dob_jobs
WHERE
	u_net IS NOT NULL
	AND (dcp_status <> 'Withdrawn' OR dcp_status IS NULL)
	AND x_dup_flag IS NULL
ORDER BY
	u_net DESC
LIMIT 8)
UNION
(SELECT
	* 
FROM
	hkates.dob_jobs
WHERE
	u_net IS NOT NULL
	AND (dcp_status <> 'Withdrawn' OR dcp_status IS NULL)
	AND x_dup_flag IS NULL
ORDER BY
	u_net ASC
LIMIT 8)
ORDER by u_net

-- To flag the records that are outliers (DOB data entry errors) and should be excluded from analysis, include their dob_job_number in this update query:

UPDATE dob_jobs
SET 
	x_outlier = TRUE
WHERE
	dob_job_number = '402681175'
	OR dob_job_number = '220014400'
	OR dob_job_number = '110080787';


-----------------------------------------------------------
-- MANUAL GEOCODING
-- Create table of records that couldn't be geocoded or were geocoded incorrectly in the water. Flag records in the x_edited field after they get manually geocoded.

SELECT
	the_geom,
	dob_job_number,
	address,
	boro,
	x_edited,
	u_net,
	dcp_status
FROM
	hkates.dob_jobs
WHERE
	u_net IS NOT NULL
	AND (the_geom IS NULL OR geog_ntacode IS NULL)
	AND x_outlier IS NOT TRUE
	AND (u_net > 100 OR u_net < -100)
	AND (dcp_status <> 'Withdrawn' OR dcp_status IS NULL)
	AND x_dup_flag IS NULL
ORDER BY
	the_geom,
	address

-- After manually geocoding, make sure to re-rerun the NTA, CN, etc assignment steps in 6_dob_jobs_geocode.sql
-- To flag the records that were manually edited, include their dob_job_number one of the two update query methods:

-- For records that were already incorrectly mapped and could be edited by moving point on Carto map
UPDATE dob_jobs
SET 
	x_edited = TRUE
WHERE
	dob_job_number = '320917503'
	OR dob_job_number = '320914310'
	OR dob_job_number = '121324129';

-- For records where coordinates were found via Google Maps and coordinates have to be typed in, the following needs to be run for each one
UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.935202, 40.847832),4326), 
	x_edited = TRUE
WHERE
	dob_job_number = '121712405';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.940440, 40.746249),4326),
	x_edited = TRUE
WHERE
	dob_job_number = '410047417';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.983116, 40.752585),4326),
	x_edited = TRUE
WHERE
	dob_job_number = '110172401';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.997042, 40.764302),4326),
	x_edited = TRUE
WHERE
	dob_job_number = '110411359';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.867691, 40.656642),4326),
	x_edited = TRUE
WHERE
	dob_job_number = '321193301';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.868040, 40.656987),4326),
	x_edited = TRUE
WHERE
	dob_job_number = '321193793';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.978218, 40.694029),4326),
	x_edited = TRUE
WHERE
	dob_job_number='321186541';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.984330, 40.758841),4326),
	x_edited = TRUE
WHERE
	dob_job_number='121191236';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.955006, 40.756203),4326),
	x_edited = TRUE
WHERE
	dob_job_number='121203697';

UPDATE dob_jobs
SET
	the_geom = ST_SetSRID(ST_MakePoint(-73.983971, 40.743722),4326),
	x_edited = TRUE
WHERE
	dob_job_number='104631720';

-- Make sure to save a backup table of your manual edits using the query in the reapply_manual_edits.sql script.

-----------------------------------------------------------
-- DUPLICATE RECORDS
-- Create table of all the potential duplicate records for further investigation

SELECT
	*
FROM
	dob_jobs
WHERE
	x_dup_id IN (
		SELECT
			DISTINCT x_dup_id
		FROM
			dob_jobs
		WHERE
			x_dup_flag IS NOT NULL
		)
	AND (u_net > 50 OR u_net < -50)
	AND (dcp_status <> 'Withdrawn' OR dcp_status IS NULL)



