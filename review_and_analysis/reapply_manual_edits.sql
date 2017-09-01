-- Make sure to save your records with manual edits in a new table, dob_jobs_edited

-- Reapply corrected geometries

UPDATE
	dob_jobs
SET
	the_geom = edit.the_geom,
	geo_mszone201718 = edit.geo_mszone201718,
	geo_pszone201718 = edit.geo_pszone201718,
	geo_csd = edit.geo_csd,
	geo_subdistrict = edit.geo_subdistrict,
	geo_ntacode = edit.geo_ntacode,
	geo_ntaname = edit.geo_ntaname,
	geo_censusblock = edit.geo_censusblock,
	geo_cd = edit.geo_cd,
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