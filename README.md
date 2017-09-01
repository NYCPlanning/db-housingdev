# Housing Developments Pipeline Database
This repo contains SQL code used to build the Housing Development Pipeline Database in Carto and run frequenctly used analyses.

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


## Contents

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

[Link to old data dictionary and use guide](https://github.com/NYCPlanning/cpdocs/blob/master/docs/pipeline.md)
