ALTER TABLE dobdev_jobs
ADD COLUMN x_dup_notes text;

UPDATE capitalplanning.dobdev_jobs
	SET
		x_dup_id = CONCAT(dob_type,bbl,bin,CONCAT(address_house,' ',address_street))
	WHERE
		dcp_status <> 'Withdrawn'
		AND dcp_status <> 'Disapproved'
		AND dcp_status <> 'Suspended'
		AND x_inactive <> 'true'
		AND xunits_binary = 'Y';


UPDATE capitalplanning.dobdev_jobs
	SET
		x_dup_maxstatusdate = maxdate
	FROM (SELECT 
       	x_dup_id,
       	MAX(status_date) AS maxdate
       FROM capitalplanning.dobdev_jobs
       WHERE x_dup_id IS NOT NULL
       GROUP BY x_dup_id) AS a
	WHERE capitalplanning.dobdev_jobs.x_dup_id = a.x_dup_id;


UPDATE capitalplanning.dobdev_jobs
	SET
		x_dup_maxcofodate = maxdate
	FROM (SELECT
       	x_dup_id,
       	MAX(c_date_latest) AS maxdate
       FROM capitalplanning.dobdev_jobs
       WHERE x_dup_id IS NOT NULL
       GROUP BY x_dup_id) AS a
	WHERE capitalplanning.dobdev_jobs.x_dup_id = a.x_dup_id;

-- 
UPDATE capitalplanning.dobdev_jobs
	SET
		x_dup_flag = 'Possible duplicate',
		x_dup_notes = 'No CofOs - Job status is earlier than latest job status update'
	WHERE
		x_dup_id IS NOT NULL
		AND x_dup_maxstatusdate > status_date
		AND x_dup_maxcofodate IS NULL
		AND c_date_latest IS NULL
		AND dcp_status <> 'Complete';

-- 
UPDATE capitalplanning.dobdev_jobs
	SET
		x_dup_flag = 'Possible duplicate',
		x_dup_notes = 'CofOs - Job status is earlier than latest CofO update'
	WHERE
		x_dup_id IS NOT NULL
		AND x_dup_maxcofodate > status_date
		AND x_dup_maxcofodate IS NOT NULL
		AND c_date_latest IS NULL
		AND dcp_status <> 'Complete';


-- -- Tests
-- -- How many sets of dup_ids found duplicates? 237
-- SELECT count(distinct x_dup_id) FROM capitalplanning.dobdev_jobs
-- where x_dup_flag is not null


-- -- Look at all duplicate sets
-- with dups AS (SELECT distinct x_dup_id FROM capitalplanning.dobdev_jobs
-- where x_dup_flag is not null
-- and bbl <> '1000010001' )

-- select
-- x_dup_id,
-- x_dup_flag,
-- x_dup_notes,
-- dcp_status,
-- x_inactive,
-- dob_job_number,
-- dob_type,
-- dob_occ_init,
-- dob_occ_prop,
-- dcp_occ_prop,
-- status_date,
-- c_date_latest,
-- c_u_latest,
-- u_init,
-- u_prop
-- from dobdev_jobs where x_dup_id in (select x_dup_id from dups)
-- order by x_dup_id, status_date desc
