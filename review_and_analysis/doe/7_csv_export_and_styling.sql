-- Change to desired column order by creating new table

ALTER TABLE capitalplanning.doe_housing_20180322
ADD COLUMN borough text,
ADD COLUMN bctcb2010 text,
ADD COLUMN baseline_units_2010 numeric,
ADD COLUMN u_2010pre_increm numeric,
ADD COLUMN u_2010post_increm numeric,
ADD COLUMN u_2011_increm numeric,
ADD COLUMN u_2012_increm numeric,
ADD COLUMN u_2013_increm numeric,
ADD COLUMN u_2014_increm numeric,
ADD COLUMN u_2015_increm numeric,
ADD COLUMN u_2016_increm numeric,
ADD COLUMN u_2017_increm numeric,
ADD COLUMN u_permitted numeric,
ADD COLUMN geo_csd text,
ADD COLUMN geo_subdist text,
ADD COLUMN geo_pszone201718 text,
ADD COLUMN geo_pszone_remarks text,
ADD COLUMN geo_mszone201718 text,
ADD COLUMN geo_mszone_remarks text,
ADD COLUMN geo_nta text,
ADD COLUMN geo_ntaname text;
  
INSERT INTO capitalplanning.doe_housing_20180322(
  the_geom,
  borough,
  bctcb2010,
  baseline_units_2010,
  u_2010pre_increm,
  u_2010post_increm,
  u_2011_increm,
  u_2012_increm,
  u_2013_increm,
  u_2014_increm,
  u_2015_increm,
  u_2016_increm,
  u_2017_increm,
  u_permitted,
  geo_csd,
  geo_subdist,
  geo_pszone201718,
  geo_pszone_remarks,
  geo_mszone201718,
  geo_mszone_remarks,
  geo_nta,
  geo_ntaname)
  
SELECT
  the_geom,
  borough,
  bctcb2010,
  baseline_units_2010,
  u_2010pre_increm,
  u_2010post_increm,
  u_2011_increm,
  u_2012_increm,
  u_2013_increm,
  u_2014_increm,
  u_2015_increm,
  u_2016_increm,
  u_2017_increm,
  u_permitted,
  geo_csd,
  geo_subdist,
  geo_pszone201718,
  geo_pszone_remarks,
  geo_mszone201718,
  geo_mszone_remarks,
  geo_nta,
  geo_ntaname
FROM capitalplanning.temp_doe_housing_20180322
ORDER BY borough, bctcb2010 ASC

-- Export as CSV for modeling

SELECT
    borough,
    bctcb2010,
    baseline_units_2010,
    u_2010pre_increm,
    u_2010post_increm
    u_2011_increm,
    u_2012_increm,
    u_2013_increm,
    u_2014_increm,
    u_2015_increm,
    u_2016_increm,
    u_2017_increm,
    u_permitted,
    geo_csd,
    geo_subdist,
    geo_pszone201718,
    geo_pszone_remarks,
    geo_mszone201718,
    geo_mszone_remarks,
    geo_nta,
    geo_ntaname
FROM capitalplanning.capitalplanning.doe_housing_20180322
ORDER BY borough, bctcb2010 ASC

-- Styling for map (based on # of permitted units)

#layer [ u_permitted > 250] {
   polygon-fill: #BD0026;
   polygon-opacity: 1;
}
#layer [ u_permitted <= 250] {
   polygon-fill: #FF5C00;
   polygon-opacity: 1
}
#layer [ u_permitted <= 100] {
  polygon-fill: #FD8D3C;
  polygon-opacity: 1
}
#layer [ u_permitted <= 50] {
  polygon-fill: #FECC5C;
  polygon-opacity: 1
}
#layer [ u_permitted <= 20] {
  polygon-fill: #FFFFB2;
  polygon-opacity: 1
}

#layer {
  polygon-fill: #FFFFB2;
  polygon-opacity: 1
}

#layer::outline {
  line-width: 0.5;
  line-color: #FFFFFF;
  line-opacity: 1;
}
