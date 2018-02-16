-- Part 1: Import original data as CSV to Carto, naming the table "dobdev_cofos_orig_20171231", and replace column names with preferred columns names that will be used for rest of processing. Carto automatically makes everything lower case and replaces spaces and special characters with "_".

ALTER TABLE dobdev_cofos_orig_20171231
	RENAME COLUMN "job__" to "cofo_job_number";

ALTER TABLE dobdev_cofos_orig_20171231
	RENAME COLUMN "effective_date" to "cofo_date";

ALTER TABLE dobdev_cofos_orig_20171231
	RENAME COLUMN "__of_dwelling_units" to "cofo_units";	
ALTER TABLE dobdev_cofos_orig_20171231
	ALTER COLUMN "cofo_units" TYPE integer USING (cofo_units::text::integer);

ALTER TABLE dobdev_cofos_orig_20171231
	RENAME COLUMN "certificatetype" to "cofo_type";	

ALTER TABLE dobdev_cofos_orig_20171231
	ADD COLUMN cofo_year text;
UPDATE dobdev_cofos_orig_20171231
    SET cofo_year = (
        CASE
            WHEN cofo_date < TO_DATE('04/01/2010', 'MM/DD/YYYY')
                AND cofo_date >= TO_DATE('01/01/2010', 'MM/DD/YYYY')
                THEN '2010-PreCensus'
            WHEN cofo_date >= TO_DATE('04/01/2010', 'MM/DD/YYYY')
                AND cofo_date < TO_DATE('01/01/2011', 'MM/DD/YYYY')
                THEN '2010-PostCensus'
            ELSE left(cofo_date::text,4)
        END);

ALTER TABLE dobdev_cofos_orig_20171231
	ALTER COLUMN "cofo_date" TYPE date using TO_DATE(cofo_date, 'MM/DD/YYYY');
