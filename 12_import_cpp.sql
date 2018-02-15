-- These queries are used to cleanup the data after it's been imported into the production carto server to be used for the Capital Planning Platform.

-- NULL values in the data get converted to fake '00001/01/01' dates when the csv file is reimported. This query fixes those and sets them to NULL again.
UPDATE dobdev_jobs
	SET
		status_a = (CASE WHEN LEFT(status_a::text, 4) = '0001' THEN NULL ELSE status_a END),
		status_d = (CASE WHEN LEFT(status_d::text, 4) = '0001' THEN NULL ELSE status_d END),
		status_p = (CASE WHEN LEFT(status_p::text, 4) = '0001' THEN NULL ELSE status_p END),
		status_q = (CASE WHEN LEFT(status_q::text, 4) = '0001' THEN NULL ELSE status_q END),
		status_r = (CASE WHEN LEFT(status_r::text, 4) = '0001' THEN NULL ELSE status_r END),
		status_x = (CASE WHEN LEFT(status_x::text, 4) = '0001' THEN NULL ELSE status_x END),
		status_date = (CASE WHEN LEFT(status_date::text, 4) = '0001' THEN NULL ELSE status_date END),
		c_date_earliest = (CASE WHEN LEFT(c_date_earliest::text, 4) = '0001' THEN NULL ELSE c_date_earliest END),
		c_date_latest = (CASE WHEN LEFT(c_date_latest::text, 4) = '0001' THEN NULL ELSE c_date_latest END);

-- After importing the table and cleaning up the dates, rename the table as housingdevdb_YYMMDD

-- Add the fields used for geographic filtering in the Capital Planning Platform. The tables used for the spatial joins should already be uploaded on the production Carto server.

ALTER TABLE housingdevdb_170906 ADD admin_cd text;
UPDATE housingdevdb_170906 AS f
    SET	admin_cd = geo_cd;

ALTER TABLE housingdevdb_170906 ADD admin_borocode text;
UPDATE housingdevdb_170906 AS f
    SET	admin_borocode = LEFT(geo_cd::text,1)::int;

ALTER TABLE housingdevdb_170906 ADD admin_nta text;
UPDATE housingdevdb_170906 AS f
    SET	admin_nta = geo_ntacode;

ALTER TABLE housingdevdb_170906 ADD admin_censtract text;
UPDATE housingdevdb_170906 AS f
    SET	admin_censtract = p.boroct2010
    FROM
        support_admin_censustracts AS p
    WHERE
        f.the_geom IS NOT NULL AND ST_Intersects(p.the_geom, f.the_geom);

ALTER TABLE housingdevdb_170906 ADD admin_council text;
UPDATE housingdevdb_170906 AS f
    SET	admin_council = p.coundist
    FROM
        support_admin_nyccouncildistricts AS p
    WHERE
        f.the_geom IS NOT NULL AND ST_Intersects(p.the_geom, f.the_geom);

ALTER TABLE housingdevdb_170906 ADD admin_policeprecinct text;
UPDATE housingdevdb_170906 AS f
    SET	admin_policeprecinct = p.precinct
    FROM
        support_admin_nypdprecincts AS p
    WHERE
        f.the_geom IS NOT NULL AND ST_Intersects(p.the_geom, f.the_geom);

ALTER TABLE housingdevdb_170906 ADD admin_schooldistrict int;
UPDATE housingdevdb_170906 AS f
    SET	admin_schooldistrict = geo_csd;
