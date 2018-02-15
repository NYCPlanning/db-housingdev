-- Download latest Housing New York Units by Building data from NYC Open Data https://data.cityofnewyork.us/Housing-Development/Housing-New-York-Units-by-Building/hg8x-zxpr/data

-- Upload the Housing NY file to Carto.

-- Change the latitude and longtitude fields to numeric data type.

-- Populate the_geom field using HPD's internal latitude and longtitude fields.
UPDATE housing_new_york_units_by_building
SET the_geom = ST_SetSRID(ST_Makepoint(longitude_internal, latitude_internal), 4326)
WHERE longitude IS NOT NULL;

-- Create a revised BBL field. HPD asked us to look into reassigning BBL with updated PLUTO data since their BBL values are sometimes out of date.
ALTER TABLE housing_new_york_units_by_building
ADD COLUMN dcp_bbl text;

-- Populate dcp_bbl column using a spatial join with DCP's MapPLUTO data.
UPDATE housing_new_york_units_by_building
SET dcp_bbl = p.bbl
FROM dcp_mappluto AS p
WHERE ST_Intersects(p.the_geom, housing_new_york_units_by_building.the_geom);

-- First as a test of the match rate, left join DCP's housing data onto the Housing NY data using the dcp_bbl field. Ideally all Housing NY building records that have geoms should find a match in DCP's data.
WITH temp AS (
SELECT
  h.*,
  array_to_string(array_agg(j.dob_job_number),';') as jobids
FROM
  cpadmin.housing_new_york_units_by_building AS h
LEFT JOIN
  hkates.dobdev_jobs_20170906 AS j
ON
  h.dcp_bbl = j.bbl
WHERE
  h.the_geom IS not NULL
GROUP BY project_id, h.cartodb_id
)

SELECT
COUNT(cartodb_id) AS total_hpd,
COUNT(CASE WHEN jobids <> '' THEN 1 END) AS total_matchdob,
COUNT(CASE WHEN reporting_construction_type = 'Preservation' THEN 1 END) AS pres,
COUNT(CASE WHEN reporting_construction_type = 'Preservation' AND jobids <> '' THEN 1 END) AS pres_matchdob,
COUNT(CASE WHEN reporting_construction_type = 'New Construction' THEN 1 END) AS newcons,
COUNT(CASE WHEN reporting_construction_type = 'New Construction' AND jobids <> '' THEN 1 END) AS newcons_matchdob
FROM temp

-- Out of the 1864 HPD bldg records with coordinates, only 474 (~25%) found a match in our housing dev data from DOB.
-- New Construction: 294/374 (79%) found matches
-- Preservation: 180/1490 (12%) found matches

-- Potential reasons for mismatch, to discuss with HPD: 
---- HPD preservation projects may not have any NB or A1 DOB permit actions.
---- BBLs in DCP's housing data may also not reflect that latest MapPLUTO data.

-- Left join Housing NY data onto the jobs data.
SELECT
  h.*,
  j.dob_job_number
FROM
  dobdev_jobs_20170906 AS j
LEFT JOIN
  housing_new_york_units_by_building AS h
ON
  h.dcp_bbl = j.bbl;
