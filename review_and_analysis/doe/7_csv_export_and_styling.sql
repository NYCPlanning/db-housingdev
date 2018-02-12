-- Export as CSV for modeling

SELECT
    borough,
    bctcb2010,
    baseline_units_2010,
    u_2010_increm,
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
FROM capitalplanning.temp_doe_housing_20180209
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
