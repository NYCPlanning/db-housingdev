-- CREATE COPY OF ORIGINAL DATA AS dob_jobs BEFORE RUNNING THE FOLLOWING COMMANDS

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
