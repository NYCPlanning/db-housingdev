https://cartoprod.capitalplanning.nyc/user/cpp/api/v2/sql?skipfields=cartodb_id& = 
SELECT
*
FROM
pipeline_projects_201707
WHERE
(
	dcp_status = 'Complete'
	OR dcp_status = 'Partial complete'
	OR dcp_status = 'Permit issued'
	OR dcp_status = 'Application filed'
	OR dcp_status = 'Complete (demolition)''
)
AND
(
	dcp_category_development = 'New Building'
	OR dcp_category_development = 'Alteration'
	OR dcp_category_development = 'Demolition
)
AND
(
	dcp_category_occupancy = 'Residential'
	OR dcp_category_occupancy = 'Other Accommodations'
)
AND
(
	units_net > -1100 AND
	units_net < 1700
)
&format=csv&filename=developments_filtered_2017-08-25

