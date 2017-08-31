-- Make sure to save your records with manual edits in a new table, dob_jobs_edited

-- Reapply corrected geometries

UPDATE
	dob_jobs
SET
	the_geom = edit.the_geom,
	geog_mszone201718 = edit.geog_mszone201718,
	geog_pszone201718 = edit.geog_pszone201718,
	geog_csd = edit.geog_csd,
	geog_subdistrict = edit.geog_subdistrict,
	geog_ntacode = edit.geog_ntacode,
	geog_ntaname = edit.geog_ntaname,
	geog_censusblock = edit.geog_censusblock,
	geog_cd = edit.geog_cd,
	x_edited = TRUE
FROM
	dob_jobs_edited AS edit 
WHERE
	dob_jobs.dob_job_number = edit.dob_job_number
	AND edit.x_edited = TRUE;

-- Reapply outlier flags

UPDATE
	dob_jobs
SET
	x_outlier = TRUE
FROM
	dob_jobs_edited AS edit 
WHERE
	dob_jobs.dob_job_number = edit.dob_job_number
	AND edit.x_outlier = TRUE;