-- This is the filter currently being applied by default in the explorer

https://cartoprod.capitalplanning.nyc/user/cpp/api/v2/sql?skipfields=cartodb_id& = 
SELECT
*
FROM
housingdevdb_170906
WHERE
the_geom IS NOT NULL
AND
(
	dcp_status = 'Complete'
	OR dcp_status = 'Partial complete'
	OR dcp_status = 'Permit issued'
	OR dcp_status = 'Application filed'
	OR dcp_status = 'Complete (demolition)'
)
AND
(
	dcp_dev_category = 'New Building'
	OR dcp_dev_category = 'Alteration'
	OR dcp_dev_category = 'Demolition'
)
AND
(
	dcp_occ_category = 'Residential'
	OR dcp_occ_category = 'Other Accommodations'
)
AND x_outlier <> 'true'
AND x_dup_flag = ''
&format=csv&filename=housingdevdb_170906



-- Full dataset including duplicates, outliers, applications that are incomplete, withdrawn applications, and jobs that could not be geocoded
SELECT
*
FROM
housingdevdb_170906


