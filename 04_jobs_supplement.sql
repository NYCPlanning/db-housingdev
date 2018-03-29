-- This is an extra step given limitations of July 2017 round of DOB data -- append data with completions from prior Jan 2017, which do not appear in latest dataset

INSERT INTO dobdev_jobs
(
	the_geom,
	address,
	bin,
	bbl,
	block,
	boro,
	lot,
	dob_type,
	dob_occ_init,
	dob_occ_prop,
	x_units_init_raw,
	x_units_prop_raw,
	status_latest,
	status_date,
	status_a,
	status_d,
	status_p,
	status_q,
	status_r,
	status_x,
	dob_job_number,
	x_datafreshness
)

WITH joined AS (
SELECT 
	a.*,
	b.dob_job_number as a_july2017match
FROM dobdev_jobs_20161231 as a
	LEFT JOIN dobdev_jobs_orig_20171231 as b
ON
	a.dob_job_number::text = b.dob_job_number::text
)

SELECT
	the_geom,
	dob_permit_address as address,
	dob_permit_bin as bin,
	dob_permit_bbl as bbl,
	dob_permit_block as block,
	dob_permit_borough as boro,
	dob_permit_lot as lot,
	dcp_type_2 as dob_type,
	dob_permit_exist_occupancy as dob_occ_init,
	dob_permit_proposed_occupancy as dob_occ_prop,
	dob_permit_exist_units as x_units_init_raw,
	dob_permit_proposed_units as x_units_prop_raw,
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


UPDATE dobdev_jobs
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
			
UPDATE dobdev_jobs
	SET status_latest = 'SIGNED OFF'
	WHERE status_latest = 'X';

UPDATE dobdev_jobs
	SET status_latest = 'PERMIT ISSUED - ENTIRE JOB/WORK'
	WHERE status_latest = 'R';

	
