-- Flag suspected duplicates; create unique ID (x_dup_id) based on matching job types, address and BBL; identify most recent status update date associated with unique ID; if records status update date does not match, flagged as potential duplicate

ALTER TABLE dob_jobs
	ADD COLUMN x_dup_id text,
	ADD COLUMN x_dup_id_maxdate date,
	ADD COLUMN x_dup_flag text;	

UPDATE dob_jobs
	SET
		address = CONCAT(address_house,' ',address_street),
		x_dup_id = CONCAT(dob_type,bbl,CONCAT(address_house,' ',address_street));

-- Assign the maximum status date for each duplicate ID
UPDATE dob_jobs
	SET
		x_dup_id_maxdate = maxdate
	FROM (SELECT 
       	x_dup_id,
       	MAX(status_date) AS maxdate
       FROM dob_jobs
       GROUP BY x_dup_id) AS a
	WHERE dob_jobs.x_dup_id = a.x_dup_id;

UPDATE dob_jobs
	SET x_dup_flag = 'Possible duplicate' WHERE x_dup_id_maxdate <> status_date;
