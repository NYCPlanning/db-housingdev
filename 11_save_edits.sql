-- Make sure to select and then save the records that were manually edited in a new table called dob_jobs_edited.

SELECT
	*
FROM
	dob_jobs
WHERE
	x_edited LIKE '%Manual%'
	OR x_outlier IS NOT NULL

-- Edits that were previously saved in the dob_jobs_edited table can be reapplied using the queries below.

-- Reapply corrected geometries

UPDATE
	dob_jobs
SET
	the_geom = edit.the_geom,
	geo_mszone201718 = edit.geog_mszone201718,
	geo_pszone201718 = edit.geog_pszone201718,
	geo_csd = edit.geog_csd,
	geo_subdistrict = edit.geog_subdistrict,
	geo_ntacode = edit.geog_ntacode,
	geo_ntaname = edit.geog_ntaname,
	geo_censusblock = edit.geog_censusblock,
	geo_cd = edit.geog_cd,
	x_edited = edit.x_edited
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
