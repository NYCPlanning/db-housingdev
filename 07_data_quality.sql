-----------------------------------------------------------
-- PART 1 - Ensure data processing worked as expected
-----------------------------------------------------------

-- Check to make sure these queries produce no results

(SELECT * FROM dobdev_jobs
WHERE u_net IS NOT NULL AND u_init IS NULL)
UNION
(SELECT * FROM dobdev_jobs
WHERE u_net IS NOT NULL AND u_prop IS NULL)
UNION
(SELECT * FROM dobdev_jobs
WHERE u_net IS NOT NULL AND u_net_complete IS NULL)
UNION
(SELECT * FROM dobdev_jobs
WHERE u_net IS NULL AND u_net_complete IS NOT NULL)
UNION
(SELECT * FROM dobdev_jobs
WHERE c_u_latest IS NOT NULL AND u_prop IS NOT NULL AND u_net_incomplete IS NULL)
UNION
(SELECT * FROM dobdev_jobs
WHERE dob_type = 'DM' AND (u_prop <> 0 or u_prop IS NULL))
UNION
(SELECT * FROM dobdev_jobs
WHERE dob_type = 'NB' AND (u_init <> 0 or u_init IS NULL))
UNION
(SELECT * FROM dobdev_jobs
WHERE dcp_status IS NULL)

-- ALTERATIONS WITHOUT AN INITIAL NUMBER OF UNITS REPORTED
-- Check to make sure u_XXXX_increm calculations aren't being done when first CofO appears on record for A1 records where u_init is null
SELECT * FROM dobdev_jobs
WHERE
dob_type = 'A1'
AND u_2007_existtotal IS NULL
AND c_date_latest IS NOT NULL
AND u_init IS NULL
ORDER BY random()
LIMIT 10

-- ALTERATIONS WITH AN INITIAL NUMBER OF UNITS REPORTED
-- Check to make sure u_XXXX_increm, u_XXXX_existtotal, and u_XXXX_netcomplete are filled in with u_init until first CofO, and that u_XXXX_increm, u_XXXX_existtotal, and u_XXXX_netcomplete all continue to add up afterward.

SELECT * FROM dobdev_jobs
WHERE
dob_type = 'A1'
AND c_date_latest IS NOT NULL
AND u_init IS NOT NULL
ORDER BY random()
LIMIT 10

-- NEW BUILDINGS
-- Check to make sure u_XXXX_increm, u_XXXX_existtotal, and u_XXXX_netcomplete are filled in with 0 until first CofO, and that u_XXXX_increm, u_XXXX_existtotal, and u_XXXX_netcomplete all continue to add up afterward.

SELECT * FROM dobdev_jobs
WHERE
dob_type = 'NB'
AND c_date_latest IS NOT NULL
ORDER BY random()
LIMIT 10

-- DEMOLITIONS WITH AN INITIAL NUMBER OF UNITS REPORTED
-- Check to make sure u_XXXX_existtotal fields iare filled in with u_init until demolition is completed, and that u_XXXX_increm, u_XXXX_existtotal, and u_XXXX_netcomplete all continue to add up afterward with u_XXXX_existtotal=0.

SELECT * FROM dobdev_jobs
WHERE
dob_type = 'DM'
AND u_init IS NOT NULL
AND c_date_latest IS NOT NULL
ORDER BY random()
LIMIT 10

-----------------------------------------------------------
-- PART 2 - Identify and tag outliers
-----------------------------------------------------------
-- OUTLIERS / DOB DATA ENTRY ERRORS
-- Create table of potential outliers to review and then flag in the x_outlier field (8 largest builds and 8 largest demos)

(SELECT
	* 
FROM
	hkates.dobdev_jobs
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
	hkates.dobdev_jobs
WHERE
	u_net IS NOT NULL
	AND (dcp_status <> 'Withdrawn' OR dcp_status IS NULL)
	AND x_dup_flag IS NULL
ORDER BY
	u_net ASC
LIMIT 8)
ORDER by u_net

-- To flag the records that are outliers (DOB data entry errors) and should be excluded from analysis, include their dob_job_number in this update query:

UPDATE dobdev_jobs
SET 
	x_outlier = TRUE
WHERE
	dob_job_number = '402681175'
	OR dob_job_number = '220014400'
	OR dob_job_number = '110080787'
	OR dob_job_number = '121712405';


