/*4. Add geo boundaries where geometry is valid*/

ALTER TABLE capitalplanning.temp_doe_housing_20180322
ADD COLUMN geo_csd text,
ADD COLUMN geo_subdist text,
ADD COLUMN geo_pszone201718 text,
ADD COLUMN geo_pszone_remarks text,
ADD COLUMN geo_mszone201718 text,
ADD COLUMN geo_mszone_remarks text,
ADD COLUMN geo_nta text,
ADD COLUMN geo_ntaname text

-- Add boundaries (first by centroid)
-- CSD
UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_csd = b.school_dis
FROM dcpadmin.doe_schooldistricts AS b
WHERE ST_Intersects(ST_Centroid(temp_doe_housing_20180322.the_geom), b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_csd = b.school_dis
FROM dcpadmin.doe_schooldistricts AS b
WHERE ST_Intersects(temp_doe_housing_20180322.the_geom, b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom)
AND geo_csd is null

-- Subdistrict
UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_subdist = b.distzone
FROM dcpadmin.doe_schoolsubdistricts AS b
WHERE ST_Intersects(ST_Centroid(temp_doe_housing_20180322.the_geom), b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_subdist = b.distzone
FROM dcpadmin.doe_schoolsubdistricts AS b
WHERE ST_Intersects(temp_doe_housing_20180322.the_geom, b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom)
AND geo_subdist is null;

-- Primary school zone (2017-18 school year)
UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_pszone201718 = b.dbn
FROM dcpadmin.doe_school_zones_es_2017 AS b
WHERE ST_Intersects(ST_Centroid(temp_doe_housing_20180322.the_geom), b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_pszone201718 = b.dbn
FROM dcpadmin.doe_school_zones_es_2017 AS b
WHERE ST_Intersects(temp_doe_housing_20180322.the_geom, b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom)
AND geo_pszone201718 is null;

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_pszone_remarks = b.remarks
FROM dcpadmin.doe_school_zones_es_2017 AS b
WHERE ST_Intersects(ST_Centroid(temp_doe_housing_20180322.the_geom), b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_pszone_remarks = b.remarks
FROM dcpadmin.doe_school_zones_es_2017 AS b
WHERE ST_Intersects(temp_doe_housing_20180322.the_geom, b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom)
AND geo_pszone_remarks is null;

-- Intermediate school zone (2017-18 school year)
UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_mszone201718 = b.dbn
FROM dcpadmin.doe_school_zones_ms_2017 AS b
WHERE ST_Intersects(ST_Centroid(temp_doe_housing_20180322.the_geom), b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_mszone201718 = b.dbn
FROM dcpadmin.doe_school_zones_ms_2017 AS b
WHERE ST_Intersects(temp_doe_housing_20180322.the_geom, b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom)
AND geo_mszone201718 is null;

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_mszone_remarks = b.remarks
FROM dcpadmin.doe_school_zones_ms_2017 AS b
WHERE ST_Intersects(ST_Centroid(temp_doe_housing_20180322.the_geom), b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_mszone_remarks = b.remarks
FROM dcpadmin.doe_school_zones_ms_2017 AS b
WHERE ST_Intersects(temp_doe_housing_20180322.the_geom, b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom)
AND geo_mszone_remarks is null;

-- NTA
UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_nta = b.ntacode
FROM dcpadmin.support_admin_ntaboundaries AS b
WHERE ST_Intersects(ST_Centroid(temp_doe_housing_20180322.the_geom), b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_nta = b.ntacode
FROM dcpadmin.support_admin_ntaboundaries AS b
WHERE ST_Intersects(temp_doe_housing_20180322.the_geom, b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom)
AND geo_nta is null;

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_ntaname = b.ntaname
FROM dcpadmin.support_admin_ntaboundaries AS b
WHERE ST_Intersects(ST_Centroid(temp_doe_housing_20180322.the_geom), b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom);

UPDATE capitalplanning.temp_doe_housing_20180322
SET geo_ntaname = b.ntaname
FROM dcpadmin.support_admin_ntaboundaries AS b
WHERE ST_Intersects(temp_doe_housing_20180322.the_geom, b.the_geom)
AND ST_IsValid(temp_doe_housing_20180322.the_geom)
AND geo_ntaname is null
