/*******************************************************************************
** This code merges all intermediate datasets and create the analytical data
*******************************************************************************/

/* Set up library references and format of variables */
filename librefs "libname.sas";
%include librefs;

/*******************************************************************************
*** data structures
	bene level:
	1. MBSF (bene level) - monthly (1-96) observation of dual, enrollAB, flag, mmp, pace indicator (prep_mbsf_updated.sas)
	2. SNP - year-plan level SNP info (prep_snp_plans.sas)
	3. MDS (bene level) - monthly (1-96) elig period indicator (prep_mds_updated.sas)

*** now the goal is to merge all to get a bene level file
*******************************************************************************/

/*******************************************************************************
*** restrict MBSF data to bene ids in MDS data
*******************************************************************************/
proc sql;
    create table tmp.mbsf_monthly_13_20_sub as 
    select a.* 
    from tmp.mbsf_monthly_13_20 as a 
    join (
    	select distinct bene_id 
    	from tmp.mds_elig_period_12_20) as b 
    on a.bene_id = b.bene_id;
quit;


/*******************************************************************************
*** merge MBSF with SNP plan to get monthly indicator for SNP enrollment status

*** data structures after this step
	bene level:
	1. MBSF + SNP (bene level) 
		- monthly (1-96) observation of dual, enrollAB, flag, mmp, pace indicator
		- monthly (1-96) SNP coverage type indicator 
	2. MDS (bene level) - monthly (1-96) elig indicator
*******************************************************************************/
* note MBSF is now a monthly observation at bene level, restricted to MDS sample;
* and SNP plan is at year level;

/* use MBSF data, Keep bene_id and PTC info, transpose to long, add year */
data tmp.mbsf_ptc;
    set tmp.mbsf_monthly_13_20_sub;
    keep bene_id PTC:;
run;

data tmp.mbsf_ptc_long;
	set tmp.mbsf_ptc;
	array PTC_CNTRCT_ID(96) PTC_CNTRCT_ID_1-PTC_CNTRCT_ID_96;
	array PTC_PBP_ID(96) PTC_PBP_ID_1-PTC_PBP_ID_96;

	do i = 1 to 96;
	    month = i;
	    year = floor((i-1)/12) + 2013;
	    contract = PTC_CNTRCT_ID(i);
	    pbp = PTC_PBP_ID(i);
	output;
	end;
	
	keep bene_id month year contract pbp;
run;

/* merge with SNP plan data */
proc sql;
    create table tmp.mbsf_snp_linked as 
    select a.bene_id, a.month, b.i_snp, b.fide_snp, b.c_snp, b.d_snp 
    from tmp.mbsf_ptc_long as a 
    	left join outdata.SNPs_2013_2023vFIN_updated as b 
    	on a.year = b.year 
    	    and a.contract = b.Contract_Number
	    and a.pbp = b.Plan_ID
	 order by bene_id;
quit;

/* reshape the linked data long to wide (bene level)*/
%macro reshape(var, num);

proc transpose data = tmp.mbsf_snp_linked out = tmp.mbsf_snp_linked_wide&num. (drop = _name_ _label_) prefix = &var.;
    by bene_id;
    id month;
    var &var.;
run;

%mend reshape;
%reshape(i_snp, 1)
%reshape(fide_snp, 2)
%reshape(c_snp, 3)
%reshape(d_snp, 4)

proc sql;
    create table tmp.mbsf_snp_linked_wide as 
    select *
    from tmp.mbsf_snp_linked_wide1 as a 
    join tmp.mbsf_snp_linked_wide2 as b on a.bene_id = b.bene_id
    join tmp.mbsf_snp_linked_wide3 as c on a.bene_id = c.bene_id
    join tmp.mbsf_snp_linked_wide4 as d on a.bene_id = d.bene_id
    order by bene_id;
quit;

/* merge back other indicator from MBSF */
proc sql;
    create table tmp.mbsf_snp_linked_final as 
    select *
    from tmp.mbsf_monthly_13_20_sub (drop = PTC:) as a 
    join tmp.mbsf_snp_linked_wide as b 
    	on a.bene_id = b.bene_id;
quit;


/*******************************************************************************
*** merge with MDS-based eligibile period

*** data structures after this step
	bene level:
	1. MBSF + SNP + MDS (bene level) 
		- monthly (1-96) observation of dual, enrollAB, flag, mmp, pace indicator
		- monthly (1-96) SNP coverage type indicator 
		- monthly (1-96) elig indicator
*******************************************************************************/

proc sql;
    create table tmp.merged_all_1 as 
    select *
    from tmp.mbsf_snp_linked_final as a 
    join tmp.mds_elig_period_12_20 as b 
    	on a.bene_id = b.bene_id;
quit;

/*******************************************************************************
*** code montly coverage type
*******************************************************************************/
data tmp.merged_all_2;
	set tmp.merged_all_1;

	array i_snp(96) i_snp1-i_snp96;
	array fide_snp(96) fide_snp1-fide_snp96;
	array c_snp(96) c_snp1-c_snp96;
	array d_snp(96) d_snp1-d_snp96;
	array ma_enrollee(96) ma_enrollee_1-ma_enrollee_96;
	array enroll_AB(96) enroll_AB_1-enroll_AB_96;
	array mmp(96) mmp_1-mmp_96;
	array pace(96) pace_1-pace_96;

	array snp(96) snp_1-snp_96;
	array ma_non_snp(96) ma_non_snp_1-ma_non_snp_96;
	array ffs_non_snp(96) ffs_non_snp_1-ffs_non_snp_96;
	array integrated(96) integrated_1-integrated_96;
	array coverage_type(96) coverage_type_1-coverage_type_96;

	do i = 1 to 96;

		/* code model types - binary */
		if fide_snp(i) = 1 or i_snp(i) = 1 or d_snp(i) = 1 or c_snp(i) = 1 then snp(i) = 1;
		if MA_enrollee(i) = 1 and snp(i) ne 1 and mmp(i) ne 1 and pace(i) ne 1 then ma_non_snp(i) = 1;
		if enroll_AB(i) = 1 & MA_enrollee(i) ne 1 & snp(i) ne 1 and mmp(i) ne 1 and pace(i) ne 1 then ffs_non_snp(i) = 1;

		if mmp(i) = 1 or pace(i) = 1 or fide_snp(i) = 1 or i_snp(i) = 1 then integrated(i) = 1;
		else if d_snp(i) = 1 or c_snp(i) = 1 or ma_non_snp(i) = 1 or ffs_non_snp(i) = 1 then integrated(i) = 0;
	
		/* code model types - mutually exclusive */
		if mmp(i) = 1 then coverage_type(i) = 1;
			else if pace(i) = 1 then coverage_type(i) = 2;
			else if fide_snp(i) = 1 then coverage_type(i) = 3;
			else if i_snp(i) = 1 then coverage_type(i) = 4;
			else if d_snp(i) = 1 then coverage_type(i) = 5;
			else if c_snp(i) = 1 then coverage_type(i) = 6;
			else if ma_non_snp(i) = 1 then coverage_type(i) = 7;
			else if ffs_non_snp(i) = 1 then coverage_type(i) = 8;
	end;
	drop i;

run;


/*******************************************************************************
*** apply sample inclusion/exclusion criteria and create analytic file
*** data structure now:
	monthly indicator at bene level: elig, inclusion/exclusion indicator, coverage type
*** data Structure after this step:
	bene-month level indicators
*******************************************************************************/
%macro apply_inclusion;

/* approach - make data from wide to long for ease of counting by year */

data tmp.merged_all_3;
	set tmp.merged_all_2
	    (keep = bene_id elig: flag_nonmainland: enroll_AB: full_dual: coverage_type: integrated: ssacounty_: STATE_CNTY_FIPS_CD:);
	array elig(96) elig1-elig96;
	array flag_nonmainland(8) flag_nonmainland_2013-flag_nonmainland_2020;
	array ssacounty(8) ssacounty_2013-ssacounty_2020;
	array enroll_AB(96) enroll_AB_1-enroll_AB_96;
	array full_dual(96) full_dual_1-full_dual_96;
	array coverage_type(96) coverage_type_1-coverage_type_96;
	array integrate(96) integrated_1-integrated_96;
	array fips(96) STATE_CNTY_FIPS_CD_1-STATE_CNTY_FIPS_CD_96;

	do i = 1 to 96;
	    month = i;
	    year = floor((i-1)/12) + 1;
	    elig_ind = elig(i);
	    enroll_AB_ind = enroll_AB(i);
	    full_dual_ind = full_dual(i);
	    coverage_cat = coverage_type(i);
	    integrated = integrate(i);
	    flag_nonmainland_ind = flag_nonmainland(year);
	    state_code = substr(ssacounty(year), 1, 2);
	    county = fips(i);
	output;
	end;

	keep bene_id month year elig_ind enroll_AB_ind full_dual_ind coverage_cat integrated flag_nonmainland_ind state_code county;
run;

proc print data = tmp.merged_all_3 (obs = 100); run;


data tmp.elig_res_month_analytic;
	set tmp.merged_all_3;
	if elig_ind = 1 and flag_nonmainland_ind ne 1 and enroll_AB_ind = 1 and full_dual_ind = 1;
run;


proc export data = tmp.elig_res_month_analytic
		    outfile = '<path to output>/elig_res_month_analytic.csv'
		    dbms = csv 
		    replace;
run;

%mend apply_inclusion;
%apply_inclusion;



/*******************************************************************************
*** merge monthly indicator file with MDS to get facility info and patient characteristics for each elig month
*** goal - for each elig res-month, find the closest quarterly assessment
*******************************************************************************/
* approach:;
* 1. keep all quarterly assessment for residents in the sample;
* 2. merge monthly observation data with assessments - keep the closest one;
* 3. for facility - we need facility id and facility county;
* 4. for resident characteristics - we need age, gender, race, ADRD, ADL, CHESS;


* 1. keep all quarterly assessment for residents in the sample;

%macro append_mds;

	proc sql;

		create table res_list as 
		select distinct bene_id
		from tmp.elig_res_month_analytic;

		create table tmp.mds_fac_res_for_merge as 
		select bene_id, unique_id, m, CCN, age, female, adrd, cfs, adl_long_form, mds3_chess
		from tmp.mds_2013_rr_bene_prep where bene_id in (select bene_id from res_list) and annual_quarterly = 1
		UNION 
			select bene_id, unique_id, m, CCN, age, female, adrd, cfs, adl_long_form, mds3_chess from tmp.mds_2014_rr_bene_prep where bene_id in (select bene_id from res_list) and annual_quarterly = 1 
		UNION 
			select bene_id, unique_id, m, CCN, age, female, adrd, cfs, adl_long_form, mds3_chess from tmp.mds_2015_rr_bene_prep where bene_id in (select bene_id from res_list) and annual_quarterly = 1
		UNION 
			select bene_id, unique_id, m, CCN, age, female, adrd, cfs, adl_long_form, mds3_chess from tmp.mds_2016_rr_bene_prep where bene_id in (select bene_id from res_list) and annual_quarterly = 1
		UNION 
			select bene_id, unique_id, m, CCN, age, female, adrd, cfs, adl_long_form, mds3_chess from tmp.mds_2017_rr_bene_prep where bene_id in (select bene_id from res_list) and annual_quarterly = 1
		UNION 
			select bene_id, unique_id, m, CCN, age, female, adrd, cfs, adl_long_form, mds3_chess from tmp.mds_2018_rr_bene_prep where bene_id in (select bene_id from res_list) and annual_quarterly = 1
		UNION 
			select bene_id, unique_id, m, CCN, age, female, adrd, cfs, adl_long_form, mds3_chess from tmp.mds_2019_rr_bene_prep where bene_id in (select bene_id from res_list) and annual_quarterly = 1
		UNION 
			select bene_id, unique_id, m, CCN, age, female, adrd, cfs, adl_long_form, mds3_chess from tmp.mds_2020_rr_bene_prep where bene_id in (select bene_id from res_list) and annual_quarterly = 1
		ORDER BY bene_id, m
		;
	
	quit;


%mend append_mds;
%append_mds;

* 2. merge monthly observation data with assessments - keep the closest one;

%macro merge;

	proc sql;
		* check;
		select count(*)
		from tmp.elig_res_month_analytic
		where month >=73;

		create table tmp.merge_fac_res1 as 
		select *, 
			(case when a.month - b.m >= 0 then a.month - b.m else b.m - a.month end) as gap
		from (
			select bene_id, month, coverage_cat, integrated, county as county_res
			from tmp.elig_res_month_analytic
			) as a 
		left join tmp.mds_fac_res_for_merge as b 
			on a.bene_id = b.bene_id 
		order by bene_id, month, gap;
	quit;

	proc means data = tmp.merge_fac_res1;
		var gap;
	run;

	data tmp.merge_fac_res2;
		set tmp.merge_fac_res1;
		by bene_id month;
		if first.month;
	run;

	proc sql;
		* check;
		select count(*)
		from tmp.merge_fac_res2;
	quit;


%mend merge;
%merge;


* 3. for facility - we need facility id and facility county - merge with LTCFocus ;

%macro merge_ltcfocus;

	* append LTCFocus and POS;
	proc sql;
		create table outdata.ltcfocus_pos_13_20 as  
		select year, prvdr_num_ltcfocus as CCN, totbeds_num, paymcaid, profit, multifac, metro, state as state_fac, fips as fips_fac, region_fac, 1 as ltcfocus
		from outdata.ltcfocus_13_20 
		UNION (
		select year, PRVDR_NUM_POS as CCN, totbeds_num, . as paymcaid, profit, multifac, metro, STATE_POS as state_fac, fips as fips_fac, region_fac, 0 as ltcfocus
		from outdata.pos_ak_dc_13_20);
	quit;

	proc sql;
		create table tmp.merge_fac_res3 as 
		select a.*, b.totbeds_num, b.paymcaid, b.profit, b.multifac, b.metro, b.state_fac, b.fips_fac, b.region_fac, b.ltcfocus
		from tmp.merge_fac_res2 as a 
			left join outdata.ltcfocus_pos_13_20 as b 
				on floor((a.month-1)/12) + 2013 = b.year and a.CCN = b.CCN;
				
	quit;
%mend merge_ltcfocus;
%merge_ltcfocus;



/*******************************************************************************
*** create analytical file - unbalanced panel
*******************************************************************************/
data outdata.SNP_analytic_240310;
	set tmp.merge_fac_res3;
run;

proc export data = outdata.SNP_analytic_240310
			outfile = "<path to output>/SNP_analytic_240310.csv"
			dbms = csv
			replace;
quit;



/*******************************************************************************
*** create analytical file - balanced panel
*******************************************************************************/

* subset analytic sample with stable list of NHs;
proc sql;
	create table outdata.SNP_analytic_stable_240310 as 
	select a.*, floor((a.month-1)/12) as year 
	from outdata.SNP_analytic_240310 as a 
		join tmp.stable_id as b 
		on a.CCN = b.CCN;
quit;


proc export data = outdata.SNP_analytic_stable_240310
			outfile = "<path to output>/SNP_analytic_stable_240310.csv"
			dbms = csv
			replace;
quit;



/***** Table 1 appendix *****/
proc sql;
	create table prep1 as 
	select coverage_type, count(*) as n_dual
	from tmp.merged_prep_month01
	where year = 2020 and flag_nonmainland ne 1 and enroll_AB = 1 and full_dual = 1
	group by coverage_type;

	create table prep2 as 
	select coverage_type, count(*) as n_ltc
	from tmp.merged_prep_month01
	where year = 2020 and flag_nonmainland ne 1 and enroll_AB = 1 and full_dual = 1 and mds_indicator = 1
	group by coverage_type;

	create table prop as 
	select a.*, b.n_ltc, (b.n_ltc * 100 /a.n_dual) as pct 
	from prep1 as a join prep2 as b on a.coverage_type = b.coverage_type;

quit;

proc print data = prop;
run;


