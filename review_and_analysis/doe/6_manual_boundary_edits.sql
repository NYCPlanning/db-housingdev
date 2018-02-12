/*6. Manual additions of boundaries where there are baseline units and/or DOB permits/completions*/

UPDATE capitalplanning.temp_doe_housing_20180209
SET 
    geo_csd = '10', 
    geo_subdist = '10 / 1',
    geo_pszone201718 = '10X081',
    geo_mszone201718 = '10X141',
    geo_nta = 'BX22',
    geo_ntaname = 'North Riverdale-Fieldston-Riverdale'
WHERE bctcb2010 = '20309001000'

UPDATE capitalplanning.temp_doe_housing_20180209
SET 
    geo_csd = '31', 
    geo_subdist = '31 / 2',
    geo_pszone201718 = '31R006',
    geo_mszone201718 = '31R034',
    geo_nta = 'SI11',
    geo_ntaname = 'Charleston-Richmond Valley-Tottenville'
WHERE bctcb2010 = '50226001011'
