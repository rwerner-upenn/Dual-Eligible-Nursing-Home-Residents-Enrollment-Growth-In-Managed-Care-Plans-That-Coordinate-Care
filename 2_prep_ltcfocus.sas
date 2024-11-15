/*******************************************************************************
** This code import and clean LTCFocus 2013-2020;
*******************************************************************************/

/* Set up library references and format of variables */
filename librefs "libname.sas";
%include librefs;


/*******************************************************************************
* import LTCFocus 2013-2020 (downloaded from website)
*******************************************************************************/

%macro import_ltcfocus;

	%do year = 2013 %to 2016;

		proc import datafile = "<path to folder containing LTCFocus data>/facility_&year..xls"
				out = tmp.facility_&year.
				dbms = xls
				replace;
		quit;

	%end;

	%do year = 2017 %to 2020;

		proc import datafile = "<path to folder containing LTCFocus data>/facility_&year..xlsx"
				out = tmp.facility_&year.
				dbms = xlsx
				replace;
		quit;
	
	%end;

%mend import_ltcfocus;
%import_ltcfocus;


/*******************************************************************************
* keep useful variables
*******************************************************************************/

%macro prep_ltcfocus;

	%do year = 2013 %to 2020;

		data outdata.ltcfocus_&year.;
			set tmp.facility_&year.
				(keep = state
						county 
						prov1680
						prov2905
						year
						paymcaid
						paymcare
						anymdex
						cnahrppd
						dchrppd
						lpnhrppd
						rn2nrs
						rnhrppd
						hospbase
						totbeds
						profit
						multifac
				rename = (	prov1680  = prvdr_num_ltcfocus
							paymcaid  = paymcaid_char
							paymcare  = paymcare_char
							cnahrppd  = cnahrppd_char
							dchrppd   = dchrppd_char 
							lpnhrppd  = lpnhrppd_char
							rn2nrs    = rn2nrs_char  
							rnhrppd   = rnhrppd_char 
							));
				
			paymcaid  = input(paymcaid_char, best12.);
			paymcare  = input(paymcare_char, best12.);
			cnahrppd  = input(cnahrppd_char, best12.);
			dchrppd   = input(dchrppd_char , best12.);
			lpnhrppd  = input(lpnhrppd_char, best12.);
			rn2nrs    = input(rn2nrs_char  , best12.);
			rnhrppd   = input(rnhrppd_char , best12.);
			totbeds_num	  = input(totbeds, best12.);
			prvdr_zip = input(prov2905, best12.);
			county_fips = input(county, best12.);

			if hospbase eq "Yes" then hospital_based_ltc = 1;
				else if hospbase eq "No" then hospital_based_ltc = 0;

			/* define accepting Medicaid as having >0% Medicaid patient 
			- then look at paymcaid within those accpet Medicaid */
			paymcaid2 = paymcaid;
			if paymcaid2 = 0 then paymcaid2 = .;
			
			drop paymcaid_char
			     paymcare_char
			     cnahrppd_char
			     dchrppd_char 
			     lpnhrppd_char
			     rn2nrs_char  
			     rnhrppd_char 
				 county;

		run;

	%end;

%mend prep_ltcfocus;
%prep_ltcfocus;


/*******************************************************************************
* append to a single file
*******************************************************************************/

proc sql;
	create table ltcfocus_13_20 as 
	select *
	from outdata.ltcfocus_2013
	UNION (
		select * from outdata.ltcfocus_2014)
	UNION (
		select * from outdata.ltcfocus_2015)
	UNION (
		select * from outdata.ltcfocus_2016)
	UNION (
		select * from outdata.ltcfocus_2017)
	UNION (
		select * from outdata.ltcfocus_2018)
	UNION (
		select * from outdata.ltcfocus_2019)
	UNION (
		select * from outdata.ltcfocus_2020)
	ORDER BY year, prvdr_num_ltcfocus;
quit;

* check - if unique at year-prvdr_num_ltcfocus - no;
proc sql;
	select count(*) 
	from (
		select distinct year, prvdr_num_ltcfocus
		from ltcfocus_13_20);
quit;

%checkmiss(ltcfocus_13_20); /* there are missing provider number */

proc sql;
	select a.*
	from ltcfocus_13_20 as a 
		join (	
		select year, prvdr_num_ltcfocus, count(*) as n  
		from ltcfocus_13_20
		where prvdr_num_ltcfocus ne ""
		group by year, prvdr_num_ltcfocus
		having n > 1
		) as b 
		on a.year = b.year and a.prvdr_num_ltcfocus = b.prvdr_num_ltcfocus;
quit;

* De-duplicate - keep only one provider number per year;
data tmp.ltcfocus_13_20;
	set ltcfocus_13_20;
	by year prvdr_num_ltcfocus;
	if first.prvdr_num_ltcfocus;
run;

* check again - if unique at year-prvdr_num_ltcfocus - yes;
proc sql;
	select count(*) 
	from (
		select distinct year, prvdr_num_ltcfocus
		from tmp.ltcfocus_13_20);
quit;


/*******************************************************************************
* merge with Rural Urban code
*******************************************************************************/

proc import datafile = '<path to RUCC code>/ruralurbancodes2013.xls'
			out = rucc_2013
			dbms = xls
			replace;
run;

data outdata.rucc_2013;
	set rucc_2013;
	county_fips = input(substr(fips, 3, 3), best12.);
	metro = (rucc_2013 in (1, 2, 3));
run;

proc sql;
	create table outdata.ltcfocus_13_20 as 
	select a.*, b.fips, b.metro 
	from tmp.ltcfocus_13_20 as a 
		left join outdata.rucc_2013 as b 
		on a.state = b.state and a.county_fips = b.county_fips;
quit;


/*******************************************************************************
*** merge in factility region and county
*******************************************************************************/

%macro add_region;

* import crosswalk files;

proc import datafile = "<path to region crosswalk>/us census bureau regions and divisions.csv"
			out = tmp.census_region_crosswalk
			dbms = csv
			replace;
			guessingrows = max;
quit;


proc sql;
	create table outdata.ltcfocus_13_20 as 
	select a.*, b.region as region_fac
	from outdata.ltcfocus_13_20 as a 
		left join tmp.census_region_crosswalk as b
			on a.state = b.state_code;
			
quit;

%mend add_region;
%add_region;


/*******************************************************************************
*** merge in factility county MA penetration, SDI
*******************************************************************************/

* import MA penetration;
proc import datafile = "<path to folder containing data>/State_County_Penetration_MA_2019_03.csv"
			out = tmp.county_ma_penetration
			dbms = csv
			replace;
			guessingrows = max;
quit;

data tmp.county_ma_penetration;
	set tmp.county_ma_penetration;
	ma_penetration = input(compress(penetration, '%'), 12.);
	county_fips = input(fips, 12.);
	keep county_fips ma_penetration;
run;

* import SDI;
proc import datafile = "<path to folder containing data>/rgcsdi-2015-2019-county.csv"
			out = tmp.county_sdi
			dbms = csv
			replace;
			guessingrows = max;
quit;

data tmp.county_sdi;
	set tmp.county_sdi;
	keep county_fips sdi_score;
run;


proc sql;
	create table outdata.ltcfocus_13_20 as 
	select a.*, b.ma_penetration, c.sdi_score
	from outdata.ltcfocus_13_20 as a 
		left join tmp.county_ma_penetration as b
			on input(a.fips, 12.) = b.county_fips
		left join tmp.county_sdi as c 
			on input(a.fips, 12.) = c.county_fips;

quit;

%checkmiss(outdata.ltcfocus_13_20);


/*******************************************************************************
* cross check with POS
*******************************************************************************/

%macro crosscheck;

	%do year = 2011 %to 2019;

	proc sql;
		create table crosscheck&year. as 
		select a.*, b.hospital_based as hospital_based_pos,
			(case when hospital_based_ltc = hospital_based_pos then 1 else 0 end) as match
		from outdata.ltcfocus_&year. as a 
			join outdata.pos_&year. (drop = hospital_based_pos) as b 
			on a.prvdr_num_ltcfocus = b.prvdr_num_pos;
			
		select count(distinct prvdr_num_ltcfocus) from crosscheck&year.;

		select count(distinct prvdr_num_ltcfocus) from crosscheck&year. where match = 1;

	quit;


	%end;
%mend crosscheck;
%crosscheck;


/*******************************************************************************
* define stable cohort from LTC Focus
*******************************************************************************/

proc sql;
	create table tmp.ltcfocus_stable_id as 
	select distinct prvdr_num_ltcfocus as CCN 
	from outdata.ltcfocus_2013
	where prvdr_num_ltcfocus in (select distinct prvdr_num_ltcfocus from outdata.ltcfocus_2014)
		and prvdr_num_ltcfocus in (select distinct prvdr_num_ltcfocus from outdata.ltcfocus_2015)
		and prvdr_num_ltcfocus in (select distinct prvdr_num_ltcfocus from outdata.ltcfocus_2016)
		and prvdr_num_ltcfocus in (select distinct prvdr_num_ltcfocus from outdata.ltcfocus_2017)
		and prvdr_num_ltcfocus in (select distinct prvdr_num_ltcfocus from outdata.ltcfocus_2018)
		and prvdr_num_ltcfocus in (select distinct prvdr_num_ltcfocus from outdata.ltcfocus_2019)
		and prvdr_num_ltcfocus in (select distinct prvdr_num_ltcfocus from outdata.ltcfocus_2020);
quit;


/*******************************************************************************
* Add stable AK & DC NHs from POS
*******************************************************************************/

proc sql;
	create table tmp.stable_id as 
	select CCN 
	from tmp.ltcfocus_stable_id
	UNION 
	(select CCN from tmp.pos_ak_dc_stable_id);

	select count(*) from tmp.ltcfocus_stable_id;
	select count(*) from tmp.pos_ak_dc_stable_id; 
	select count(*) from tmp.stable_id; 
quit;


/*******************************************************************************
* subset analytic sample
*******************************************************************************/

proc sql;
	create table outdata.SNP_analytic_stable_230925 as 
	select a.*
	from outdata.SNP_analytic_230925 as a 
		join tmp.stable_id as b 
		on a.CCN = b.CCN;
quit;


proc export data = outdata.SNP_analytic_stable_230925
			outfile = "<path to output folder>/SNP_analytic_stable_230925.csv"
			dbms = csv
			replace;
quit;

