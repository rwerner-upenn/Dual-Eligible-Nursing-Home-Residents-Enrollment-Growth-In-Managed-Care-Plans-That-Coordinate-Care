/*******************************************************************************
** This code constructs nursing home level shares using 2019 and 2020 data (pooled)
*******************************************************************************/

/* Set up library references and format of variables */
filename librefs "libname.sas";
%include librefs;


/*******************************************************************************
* define stable cohort from LTC Focus, 2019-2020
*******************************************************************************/

proc sql;
	create table ltcfocus_stable_id_19_20 as 
	select distinct prvdr_num_ltcfocus as CCN 
	from outdata.ltcfocus_2019
	where prvdr_num_ltcfocus in (select distinct prvdr_num_ltcfocus from outdata.ltcfocus_2020);
quit;


/*******************************************************************************
* subset analytic sample (note: from unbalanced sample)
*******************************************************************************/

proc sql;
	create table sample as 
	select a.CCN, a.bene_id, a.month, a.coverage_cat, a.integrated, a.ADL_LONG_FORM, a.MDS3_CHESS
	from outdata.SNP_analytic_240310 as a 
		join ltcfocus_stable_id_19_20 as b 
		on a.CCN = b.CCN
	where a.month >= 73;

	select count(distinct CCN) as n_CCN from sample;
quit;


/*******************************************************************************
* aggregate at NH level, calculate proportion of ISNP/ICP
* aggregate at NH level, average ADL and CHESS
*******************************************************************************/

proc sql;
	create table CCN_merged as 
	select CCN, count(*) as n,
		(sum(case when integrated = 1 then 1 else 0 end) * 100 / count(*)) as pct_integrated,
		(sum(case when coverage_cat = 4 then 1 else 0 end) * 100 / count(*)) as pct_i_snp,
		avg(ADL_LONG_FORM) as avg_adl,
		avg(MDS3_CHESS) as avg_chess

	from sample
	where coverage_cat not in (2, 6) and CCN ne '' and month > 73
	group by CCN;
quit;

* summarize;
proc univariate data = CCN_merged;
	var pct_i_snp pct_integrated;
run;

proc univariate data = CCN_merged;
	where pct_i_snp > 0;
	var pct_i_snp;
run;

proc univariate data = CCN_merged;
	where pct_integrated > 0;	
	var pct_integrated;
run;


/*******************************************************************************
* divide NH based on penetration rates; add quartiles
*******************************************************************************/

%let i_snp_q25 = 12.42;
%let i_snp_q50 = 33.69;
%let i_snp_q75 = 49.58;

%let icp_q25 = 4.06;
%let icp_q50 = 25.24;
%let icp_q75 = 47.53;


data NH_group;
	set CCN_merged;

	* quartiles;
	if pct_i_snp = 0 then quartile_i_snp = 0;
		else if pct_i_snp > 0 and pct_i_snp <= &i_snp_q25. then quartile_i_snp = 1;
		else if pct_i_snp > &i_snp_q25. and pct_i_snp <= &i_snp_q50. then quartile_i_snp = 2;
		else if pct_i_snp > &i_snp_q50. and pct_i_snp <= &i_snp_q75. then quartile_i_snp = 3;
		else if pct_i_snp > &i_snp_q75.  then quartile_i_snp = 4;

	if pct_integrated = 0 then quartile_integrated = 0;
		else if pct_integrated > 0 and pct_integrated <= &icp_q25. then quartile_integrated = 1;
		else if pct_integrated > &icp_q25. and pct_integrated <= &icp_q50. then quartile_integrated = 2;
		else if pct_integrated > &icp_q50. and pct_integrated <= &icp_q75. then quartile_integrated = 3;
		else if pct_integrated > &icp_q75.  then quartile_integrated = 4;
run;

proc freq data = NH_group;
	table quartile_i_snp quartile_integrated / missing nocol norow nopercent;
run;



/*******************************************************************************
* Note now the denominator is all MDS residents, pooled 2019-2020 (from prep_mds.sas)
*******************************************************************************/

/*******************************************************************************
*** calculate %Medicaid resident (LTC+dual) using MDS 
*** calculate %black, white, hispanic, asian
*** calculate %ADRD
*** pooled estimates 2019-2020 
*******************************************************************************/
%macro calculate_nh_pct ;

* merge all MDS residents with MBSF;
proc sql;
		create table tmp.mds_all_mbsf_19_20 as 
		select mds.*, 
			mbsf.white_2020 as white, mbsf.black_2020 as black, mbsf.hispanic_2020 as hispanic, mbsf.asian_2020 as asian, 
			mbsf.female_2020 as female,
			max(mbsf.full_dual_73-mbsf.full_dual_96) as dual_indicator
		from outdata.mds_all_bene_lvl_13_20 (keep = year CCN bene_id mds_indicator longstay age) as mds
			join tmp.mbsf_monthly_13_20 as mbsf 
			on mds.bene_id = mbsf.bene_id and mds.year >= 2019;
quit;

* define Medicaid resident (LTC + full dual);
data tmp.mds_all_mbsf_19_20;
	set tmp.mds_all_mbsf_19_20;
	if longstay = 1 and dual_indicator = 1 then medicaid = 1;
		else medicaid = 0;
run;

* for each CCN, calculate % medicaid resident, %white/black/hispanic, %ADRD;
proc sql;
	create table tmp.nh_19_20_pct as 
	select CCN, 
			sum(mds_indicator) as n_all_resident,
			(sum(medicaid) * 100 / sum(mds_indicator)) as pct_medicaid,
			(sum(white) * 100 / sum(mds_indicator)) as pct_white,
			(sum(black) * 100 / sum(mds_indicator)) as pct_black,
			(sum(hispanic) * 100 / sum(mds_indicator)) as pct_hispanic,
			(sum(asian) * 100 / sum(mds_indicator)) as pct_asian,
			(sum(female) * 100 / sum(mds_indicator)) as pct_female,
			avg(age) as mean_age
	from tmp.mds_all_mbsf_19_20 
	group by CCN 
	order by CCN;
quit;

* clean pct variables;
data tmp.nh_19_20_pct;
	set tmp.nh_19_20_pct;
	array pct(*) pct_:;
	do i = 1 to dim(pct);
		if pct(i) = . then pct(i) = 0;
	end;
	drop i;
run;
		

%mend calculate_nh_pct;
%calculate_nh_pct;



/*******************************************************************************
* now merge all NH-lvl characteristics back to MDS resident file, to get weight for NHs
*******************************************************************************/
%macro final;

* now start from all MDS residents, 2019-2020, limited to stable NHs with flags for categories;
proc sql;
	create table tmp.mds_19_20_prep1 as 
	select *
	from outdata.mds_all_bene_lvl_13_20 (keep = year CCN bene_id) as a 
		join NH_group as b 
		on a.ccn = b.ccn
	where a.year >= 2019;
quit;


* merge with LTCFocus to get # bed and other facility level characteristics;
proc sql;
	create table tmp.mds_19_20_prep2 as 
	select a.*, b.paymcaid, b.totbeds_num, b.region_fac, b.profit, b.multifac, b.metro,
		b.ma_penetration, b.sdi_score
	from tmp.mds_19_20_prep1 as a 
		join outdata.ltcfocus_13_20 as b 
		on a.ccn = b.prvdr_num_ltcfocus and a.year = b.year and a.year >= 2019;
quit;


* merge with MDS derived %;
proc sql;
	create table tmp.mds_19_20_prep3 as 
	select a.*, b.*
	from tmp.mds_19_20_prep2 as a 
		join tmp.nh_19_20_pct (keep = ccn pct_: mean_age) as b 
		on a.ccn = b.ccn;
quit;

%checkmiss(tmp.mds_19_20_prep3);


proc export data = tmp.mds_19_20_prep3
			outfile = "./mds_2019_2020_w_fac_info_updated.csv"
			dbms = csv
			replace;
quit;

%mend final;
%final;

/* calculate # nursing homes in each categories */

%macro calc_n;

proc sql;
	/* 3grp */
	select pct_i_snp_cat, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 1
	group by pct_i_snp_cat;

	select pct_integrated_cat, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 1
	group by pct_integrated_cat;

	select pct_i_snp_cat, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 0
	group by pct_i_snp_cat;

	select pct_integrated_cat, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 0
	group by pct_integrated_cat;

	/* 4grp */
	select pct_i_snp_cat2, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 1
	group by pct_i_snp_cat2;

	select pct_integrated_cat2, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 1
	group by pct_integrated_cat2;

	select pct_i_snp_cat2, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 0
	group by pct_i_snp_cat2;

	select pct_integrated_cat2, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 0
	group by pct_integrated_cat2;
	
	
	/* quartiles */
	select quartile_i_snp, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	group by quartile_i_snp;

	select quartile_integrated, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	group by quartile_integrated;


	select quartile_i_snp, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 1
	group by quartile_i_snp;
	
	select quartile_i_snp, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 0
	group by quartile_i_snp;
	
	select quartile_integrated, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 1
	group by quartile_integrated;
	
	select quartile_integrated, count(distinct CCN) as n_CCN
	from tmp.mds_19_20_prep3
	where metro = 0
	group by quartile_integrated;
	
	
quit;
%mend calc_n;
%calc_n;


/*******************************************************************************
 =create output dataset for two way plots 
(a nursing home-level file (of nursing homes in LTCFocus in 2019 and 2020) with 4 variables:
 1) % of all residents on Medicaid, 
 2) % of dual eligible residents in I-SNPs
 3) % of dual eligible residents in any integrated care model (MMP, FIDE-SNP, or I-SNP),
 4) bed size)
*******************************************************************************/

%macro twoway;

* merge with LTCFocus to get # bed, % Medicaid;
proc sql;
	create table tmp.nh_19_20_plot_data as 
	select a.*, b.pct_medicaid, b.bed_size
	from CCN_merged (keep = ccn pct_: avg:)as a 
		join (
			select prvdr_num_ltcfocus, avg(paymcaid) as pct_medicaid, avg(totbeds_num) as bed_size
			from outdata.ltcfocus_13_20
			where year >= 2019 
			group by prvdr_num_ltcfocus) as b 
		on a.ccn = b.prvdr_num_ltcfocus;


	select count(distinct ccn) from tmp.nh_19_20_plot_data;
quit;

proc means data = tmp.nh_19_20_plot_data n nmiss mean min max;
	var pct_: bed_size;
run;


proc export data = tmp.nh_19_20_plot_data
			outfile = "./nh_19_20_plot_data.csv"
			dbms = csv
			replace;
quit;

%mend twoway;
%twoway;

