/*4. Add geo boundaries where geometry is valid*/

UPDATE capitalplanning.temp_doe_housing_20180209
SET the_geom = c.the_geom
FROM dcpadmin.dcp_nycbctcb2010 AS c
WHERE temp_doe_housing_20180209.bctcb2010 = c.bctcb2010::numeric
AND ST_IsValid(c.the_geom)

ALTER TABLE capitalplanning.temp_doe_housing_20180209
ADD COLUMN geo_csd text,
ADD COLUMN geo_subdist text,
ADD COLUMN geo_pszone201718 text,
ADD COLUMN geo_pszone_remarks text,
ADD COLUMN geo_mszone201718 text,
ADD COLUMN geo_mszone_remarks text,
ADD COLUMN geo_nta text,
ADD COLUMN geo_ntaname text;

UPDATE capitalplanning.temp_doe_housing_20180209
SET geo_csd = b.school_dis
FROM dcpadmin.doe_schooldistricts AS b
WHERE ST_Intersects (temp_doe_housing_20180209.the_geom, b.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180209
SET geo_subdist = b.distzone
FROM dcpadmin.doe_schoolsubdistricts AS b
WHERE ST_Intersects(temp_doe_housing_20180209.the_geom, b.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180209
SET geo_pszone201718 = b.dbn
FROM dcpadmin.doe_school_zones_es_2017 AS b
WHERE ST_Intersects(temp_doe_housing_20180209.the_geom, b.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180209
SET geo_pszone_remarks = b.remarks
FROM dcpadmin.doe_school_zones_es_2017 AS b
WHERE ST_Intersects(temp_doe_housing_20180209.the_geom, b.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180209
SET geo_mszone201718 = b.dbn
FROM dcpadmin.doe_school_zones_ms_2017 AS b
WHERE ST_Intersects(temp_doe_housing_20180209.the_geom, b.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180209
SET geo_mszone_remarks = b.remarks
FROM dcpadmin.doe_school_zones_ms_2017 AS b
WHERE ST_Intersects(temp_doe_housing_20180209.the_geom, b.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180209
SET geo_nta = b.ntacode
FROM dcpadmin.support_admin_ntaboundaries AS b
WHERE ST_Intersects(temp_doe_housing_20180209.the_geom, b.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180209
SET geo_ntaname = b.ntaname
FROM dcpadmin.support_admin_ntaboundaries AS b
WHERE ST_Intersects(temp_doe_housing_20180209.the_geom, b.the_geom)
