# Dual-Eligible Nursing Home Residents: Enrollment Growth In Managed Care Plans That Coordinate Care, 2013-20.

The code files in this repository reproduces the analytic datasets and exhibits for the following paper:

Roberts ET, Chen X, Macneal E, Werner RM. Dual-Eligible Nursing Home Residents: Enrollment Growth In Managed Care Plans That Coordinate Care, 2013-20. Health Aff (Millwood). 2024 Sep;43(9):1296-1305. doi: 10.1377/hlthaff.2023.01579. PMID: 39226503.

 [Link to the article](https://doi.org/10.1377/hlthaff.2023.01579)



## Data sources

* [LTCFocus](https://ltcfocus.org/data), 2013-2020

* [Provider of Service file (POS)](https://data.cms.gov/provider-characteristics/hospitals-and-other-facilities/provider-of-services-file-hospital-non-hospital-facilities), 2013-2020

* Medicare Beneficiary Summary Files, 2013-2020

* Minimum Data Set (MDS) 3.0, 2013-2020

* [Rural-Urban Continuum Codes](https://www.ers.usda.gov/data-products/rural-urban-continuum-codes/)

  

## Steps of recreating the analytic dataset

1. Download the required data files

2. Modify the file paths to the data files and output in the `0_libname.sas`

3. Run the SAS code in the following order (The recommended SAS version is 9.4), and update the names of the data files:

   * `1_prep_pos.sas`: cleans the raw POS data

   * `2_prep_ltcfocus.sas`: uses the LTCFocus data to create facility-level characteristics

   * `3_prep_snp_plan.sas`: imports and troubleshoots the plan enrollment data

   * `4_prep_mds.sas`: cleans the MDS assessment data to define LTC residents and eligible period for each resident

   * `5_prep_mbsf.sas`: prepares MBSF data to get bene-level characteristics and monthly enrollment information

   * `6_merge_all.sas`: merges all intermediate datasets and creates the analytical data

     

## Steps of replicating the exhibits

* Exhibit 2: Share of dual-eligible long-term nursing home residents enrolled in specified Medicare plan types per month
  * `7_Exhibit_2_summary.R`
* Exhibit 3: County-level share of nursing home resident-months for dual-eligible beneficiaries enrolled in managed care plans that contract with Medicare, Medicaid, or both
  * `8_Exhibit_3_county_maps.sas`
* Exhibit 4: Characteristics of nursing homes grouped according to the share of dual-eligible residents per month enrolled in managed care plans that contract with Medicare, Medicaid, or both
  * `9_describe_NH_level.sas`
  * `9b_Exhibit4_NH_summary.R`







