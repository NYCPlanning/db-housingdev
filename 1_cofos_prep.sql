-- General background and watchouts: [ADD here about receiving data from DOB]
	--Open Data: ____

-- Data specifications (July 2017)
	--Job types: NB, A1, DM

-- Part 1: Import as CSV (e.g., "dob_cofos_orig") to Carto and replace column names with preferred columns names that will be used for rest of processing. Carto automatically makes everything lower case and replaces spaces and special characters with "_".

ALTER TABLE dob_cofos_orig
	RENAME COLUMN "job__" to "cofo_job_number";

ALTER TABLE dob_cofos_orig
	RENAME COLUMN "effective_date" to "cofo_date";
ALTER TABLE dob_cofos_orig
	ALTER COLUMN "cofo_date" TYPE date using TO_DATE(cofo_date, 'MM/DD/YYYY');

ALTER TABLE dob_cofos_orig
	RENAME COLUMN "__of_dwelling_units" to "cofo_units";	
ALTER TABLE dob_cofos_orig
	ALTER COLUMN "cofo_units" TYPE integer USING (cofo_units::text::integer);

ALTER TABLE dob_cofos_orig
	RENAME COLUMN "certificatetype" to "cofo_type";	

ALTER TABLE dob_cofos_orig
	ADD COLUMN cofo_year text;
UPDATE dob_cofos_orig
	SET cofo_year = left(cofo_date::text,4);