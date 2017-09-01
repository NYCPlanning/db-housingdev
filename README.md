# Housing Developments Pipeline Database
This repo contains SQL code used to build the Housing Development Pipeline Database and run frequently used analyses in Carto.

## Table of Contents
- [Data Sources](https://github.com/NYCPlanning/housingpipeline-db#data-sources)
- [Scripts](https://github.com/NYCPlanning/housingpipeline-db#scripts)
- [Process Diagram](https://github.com/NYCPlanning/housingpipeline-db#process-diagram)
- [Data Dictionary](https://github.com/NYCPlanning/housingpipeline-db#data-dictionary)
- [Analysis: Important Caveats and Limitations](https://github.com/NYCPlanning/housingpipeline-db#caveats-and-limitations)

## Data Sources

### DOB Jobs Data
- This data is requested from DOB, because the NYC Open Data datasets exclude key fields that are needed for developing the housing pipline dataset.
- The jobs data provides the more comprehensive list of projects,
- For each projects, the jobs data captures the initial # of existing units and proposed units.

### DOB Certificates of Occupancy (CofOs) Data
- This data is also requested from DOB. It cannot yet be obtained via [NYC Open data](https://data.cityofnewyork.us/dataset/DOB-Certificate-Of-Occupancy/bs8b-p36w/data), because the open data is critically missing the number of dwelling units that each CofO certifies.
- The CofOs data captures the legal # of existing units at a given point in time - multiple temporary CofOs can be issued over time for same job before the final CofO is given, meaning there can be multiple rows per job ID.
- CofOs enable the calculation of incremental change in housing units per year.

The two datasets must be combined, because the jobs data doesn't capture change over time, and the CofOs data lacks context for determining the net change in units. CofO's don't account for how many units already existed or how many outstanding units are still planned to be built.

## Scripts

| Script | Function |
| :-- | :-- | 
| 1_cofos_prep.sql | This script renames the column names in the CofO data to DCP's preferred column names that are used in the rest of the SQL code. |
| 2_cofos_process.sql | This script aggregates CofOs to the DOB job ID, and transposes the data to capture the number of units reported per year in the CofO data. |
| 3_jobs_prep.sql | This script renames the column names in the jobs data to DCP's preferred column names that are used in the rest of the SQL code. |
| 4_jobs_supplement.sql | Non-recurring step: This script supplements the new data with old housing pipeline data to fill in the gaps for records that were accidentially exlcuded during the most recent data transfer from DOB. |
| 5_jobs_process.sql | This script recodes DOB's labels to match DCP's preferred status, type, and occupancy values. It then calculates the proposed net change in units (units proposed - units existing) and flags potential duplicate records. |
| 6_integrate.sql | This script joins the CofO data onto the jobs data, calculating the incremental yearly net change in units. Demos are accounted for in the incremental net change fields, and the number of net completed and net outstanding, incomplete units is calculated. The job status is updated to "complete" based on whether 80% of units of have completed and the final CofO has been issued.
| 7_geocode.sql | This script geocodes all the jobs records and assigns their NTA, CD, school district, etc. boundaries. |


## Process Diagram

![process](https://github.com/NYCPlanning/housingpipeline-db/blob/master/diagram_housingdb_build.png)

## Data Dictionary

| Field Name | Definition |
| :-- | :-- |
| cartodb_id | Unique ID created by Carto |
| the_geom | Point geometry for the record |
| address | Full address of a site |
| address_house | The house number of the address |
| address_street | The street name of the address |
| bbl | Borough-Block-Lot tax lot ID number |
| block | City block ID number |
| boro | Borough |
| c_date_earliest | Date of earliest CofO issued |
| c_date_latest | Date of most recent CofO issued |
| c_type_latest | Specificies most recent CofO type (Temporary or Final) |
| c_u_latest | Number of units captured in most recent CofO issued |
| dcp_dev_category | Field created by DCP to translate the DOB job type (dob_type): New Building, Alteration, or Demolition |
| dcp_occ_category | Indicates whether a building is a full-time residential building or another type of accomdation, like a hotel or dormitory |
| dcp_occ_init | Simplified label for the initial occupancy type of the building |
| dcp_occ_prop | Simplified label for the proposed occupancy type of the building |
| dcp_status | Field created by DCP to capture statuses assigned by DCP. Complete: most recent CofO lists >80% of permit proposed units. Partial complete: most recent CofO lists <80% of permit proposed units. Permit outstanding: first permit issued but no CofOs issued. Permit pending: permit application complete but first permit not issued |
| dob_bldg_type | DOB's description for the building classification type |
| dob_job_number | Unique ID per job application |
| dob_occ_init | Exisiting occupancy type at time of job application. This indicates whether a site is/was initially a hotel, 1-2 family home, commercial space, etc. |
| dob_occ_prop | Proposed occupancy type at time of job application. This indicates whether the site is being converted into a hotel, 1-2 family home, commercial space, etc. |
| dob_type | DOB's type catgory for the job (NB = New Building, A1 = Alteration, Dm = Demolition) |
| far_prop | The proposed Floor-Area-Ratio (FAR) for the project |
| geo_cd | NYC Community District |
| geo_censusblock | US Census Block |
| geo_csd | DOE school district |
| geo_mszone201718 | DOE middle school zone |
| geo_ntacode | NTA Code |
| geo_ntaname | NTA Name |
| geo_pszone201718 | DOE elementary school zone |
| geo_subdistrict | DOE school subdistrict |
| lot | City lot ID number |
| status_a | Date of pre-filing application |
| status_d | Date of completed application on file |
| status_date | Date of most recent job status update |
| status_latest | Most recent job status, listed in DOB jobs data |
| status_p | Date of plan examination approval |
| status_q | Date of first partial permit issuance |
| status_r | Date of full permit issuance |
| status_x | Date of job completion |
| stories_init | Initial number of building stories |
| stories_prop | Proposed number of building stories |
| u_2007_existtotal - u_2017_existtotal | Total legal units that exist in the building in this year. This values are populated using the number of units initially reported at the time of the job application and the subsequent temporary and final CofOs issued. |
| u_2007_increm - u_2017_increm | Incremental change in total units in each year (i.e. u_2017_existtotal - u_2016_existtotal). If no previous CofO was issued by this date and the initial number of units was not reported in the DOB job application, the incremental change is assumed to be zero. |
| u_2007_netcomplete - u_2017_netcomplete | Cummulative net units completed in building in this year compared to number that initially existed when job application was filed (units_totalexist_XXXX - units_init) |
| u_init | Number of units that initially existed in building at time of job application |
| u_net | Net change in unit count proposed in application |
| u_net_complete | Cummulative number of proposed units that have been completed to date |
| u_net_incomplete | Number of proposed units that have not yet been completed to date |
| u_prop | Number of final units proposed in job application |
| x_datafreshness | Flag for which batch of DOB data provided the reord |
| x_dup_flag | Flag that identifies likely duplicate records that should be excluded from analyses |
| x_dup_id | Unique ID, comprised of a concatentation of address, job ID, and project type used to check for duplicates |
| x_dup_maxdate | Most recent status date from the most recently updaetd record in the grouping of likely duplicate records |
| x_edited | Flag that indicates whether the geometry or geographic intersection assignments were manually edited for the record |
| x_inactive | Flag that indicates if more than 5 years have passed since a permit was issued and there have still been no changes to the count of units in the building |
| x_outlier | Flag that indicates whether a record is an outlier or DOB data error and should be excluded from analysis calculations |
| x_withdrawal | Flag that indicates whether an application or permit has been withdrawn. |
| xunits_init_raw | Raw, unmodified number of initial units reported in DOB jobs data |
| xunits_prop_raw | Raw, unmodified number of proposed units reported in DOB jobs data |
| zoning_init | Initial zoning reported in DOB job application |
| zoning_prop | Proposed zoning reported in DOB job application |

[Link to old data dictionary and use guide](https://github.com/NYCPlanning/cpdocs/blob/master/docs/pipeline.md)

## Caveats and Limitations

Notes on Analysis:
- Need to be wary of aggregations using u_net and u_net_complete and _incomplete for aggregations
- It is better to use the annual incremental changes for most analyses
- Important filtering criteria for all analyses:
	- Withdrawn
	- Applications (depending on degree of confidence you’re looking for — only 30% of job applications progress to getting permits)
	- Duplicates
	- Outliers
