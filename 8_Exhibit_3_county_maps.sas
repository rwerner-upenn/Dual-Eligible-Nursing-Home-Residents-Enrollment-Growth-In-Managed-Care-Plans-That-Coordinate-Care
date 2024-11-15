/*******************************************************************************
** This code creates county-level count and proportion data and maps
*******************************************************************************/

/* Set up library references and format of variables */
filename librefs "libname.sas";
%include librefs;


/*******************************************************************************
*** get county level count and proportion
*******************************************************************************/

proc sql;
	create table tmp.penetration_bene_county_19_20 as 
	select county_res, count(*) as n,
		(sum(case when integrated = 1 then 1 else 0 end) * 100 / count(*)) as pct_integrated,
		(sum(case when coverage_cat = 4 then 1 else 0 end) * 100 / count(*)) as pct_i_snp
	from outdata.SNP_analytic_240310
	where coverage_cat not in (2, 6) and county_res ne '' and month >= 73
	group by county_res;
quit;

proc sql;
	create table tmp.penetration_fac_county_19_20 as 
	select fips_fac, count(*) as n,
		(sum(case when integrated = 1 then 1 else 0 end) * 100 / count(*)) as pct_integrated,
		(sum(case when coverage_cat = 4 then 1 else 0 end) * 100 / count(*)) as pct_i_snp
	from outdata.SNP_analytic_240310
	where coverage_cat not in (2, 6) and fips_fac ne '' and month >= 73
	group by fips_fac;
quit;

********************************************************************************;
* USER ADJUSTS: DEFINE DATASET TO USE AND MAP OUTPUT FORMAT						;
********************************************************************************;

* Indicate whether to use beneficiary residence (0) or facility residence (1) data;
%let use_facility_residence=0;
* Indicate whether the map should be output to the results viewer (0) or as an SVG file (1);
%let generate_svg_file=0;

********************************************************************************;
* DEFINE GLOBAL VARS							;
********************************************************************************;

* Designate dataset-dependent variables;
%if &use_facility_residence=1 %then %do;
	%let prefix=fac;
	%let countyfips=FIPS_FAC;
%end;
%else %do;
	%let prefix=bene;
	%let countyfips=COUNTY_RES;
%end;

********************************************************************************;
* CREATE US COUNTY-COMPLETE DATASET	(N=3143)									;
********************************************************************************;

* Format US county map with combined state-county fips code;
data tmp.uscounty;
	set maps.uscounty; 
	state_str=put(state,z2.);
	county_str=put(county,z3.);
	county_fips=input(cat(put(state,z2.),put(county,z3.)),best12.);
run;

* Create complete county-level dataset;
proc sql;
	create table tmp.&prefix._county_lvl_cmplt as
	select distinct a.county_fips,
		case when b.n>=361 then b.pct_integrated else -99 end as pct_integrated,
		case when b.n>=361 then b.pct_i_snp else -99 end as pct_i_snp
	from tmp.uscounty a left join tmp.&prefix._county_lvl_2019_2020 b
	on a.county_fips=b.&countyfips;
quit;

* Flag counties not in the LTC focus;
%if &use_facility_residence=1 %then %do;
data tmp.fac_county_lvl_cmplt;
	set tmp.fac_county_lvl_cmplt;
	if substr(put(county_fips,z5.),1,2) in ("02","11") then do;
		pct_integrated=-98;
		pct_i_snp=-98;
	end;
run;
%end;

********************************************************************************;
* CREATE STATE OUTLINE ANNOTATION DATASET										;
********************************************************************************;

* Create state outline map from county map;
proc gremove data=tmp.uscounty out=tmp.state_anno_outline;
	by state notsorted;
	id county;
run;

* Define state outline map attributes;
data tmp.state_anno_outline;
	set tmp.state_anno_outline;
	by state segment notsorted;
	length function $8 color $8;
	color='grayff'; style='mempty'; when='a'; xsys='2';
	ysys='2'; size=2;
	if first.segment then function='poly';
	else function='polycont';
run;

********************************************************************************;
* DEFINE MAP PARAMETERS															;
********************************************************************************;

goptions
xpixels=3000
ypixels=2000;

%if generate_svg_file=1 %then %do;
	options svgheight='2000px' svgwidth='3000px';  
	goptions device=svg gsfname=graphout;
	ods _all_ close;
	ods listing;
	ods html;
%end;

* Define legend location and appearance;
legend1
position=(bottom right)
across=1
mode=share
label=none
value=(h=1 j=l c='CX003461')
shape=bar(3,4) pct;

%let titlespecs = height=40pt j=left font='Swissb' color='CX003461';

* Create choropleth format for maps;
proc format;
	value county_integrated_pct
	0-4.999 = '<5%'
	5-9.99 = '>=5% to <10%'
	10-19.99 = '>=10% to <20%'
	20-high = '>=20%'
	%if &use_facility_residence=1 %then %do;
	-98 = 'Not in LTCFocus'
	%end;
	-99 = 'No data'
	;
	value county_i_snp_pct
	0-4.999 = '<5%'
	5-9.99 = '>=5% to <10%'
	10-19.99 = '>=10% to <20%'
	20-high = '>=20%'
	%if &use_facility_residence=1 %then %do;
	-98 = 'Not in LTCFocus'
	%end;
	-99 = 'No data'
	;
run;

* Set pattern fills;
%if &use_facility_residence=1 %then %do;
	pattern1 v=m5n45 c='CX175676';
	pattern2 v=s c='CXCCCCCC';
	pattern3 v=s c='CXABC1CE';
	pattern4 v=s c='CX608BA3';
	pattern5 v=s c='CX175676';
	pattern6 v=s c='CX003461';
%end;
%else %do;
	pattern1 v=s c='CXDBDBDB';
	pattern2 v=s c='CXABC1CE';
	pattern3 v=s c='CX608BA3';
	pattern4 v=s c='CX175676';
	pattern5 v=s c='CX003461';
%end;

********************************************************************************;
* CREATE MAPS																	;
********************************************************************************;

* Create map of proportion in integrated care plans;
%if generate_svg_file=1 %then %do; filename graphout /* "path/name of SVG file to write" */; %end;
title &titlespecs 'Percentage of dual eligible long-term nursing home resident enrollment months in integrated care plans, 2019-2020';
proc gmap
	map=tmp.uscounty
	data=tmp.&prefix._county_lvl_cmplt
	anno=tmp.state_anno_outline
	all;
	id county_fips;
	choro pct_integrated / discrete legend=legend1 coutline=white;
	format pct_integrated county_integrated_pct.;
run;
quit;

* Create map of proportion in I-SNPs;
%if generate_svg_file=1 %then %do; filename graphout /* "path/name of SVG file to write" */; %end;
title &titlespecs 'Percentage of dual eligible long-term nursing home resident enrollment months in I-SNPs, 2019-2020';
proc gmap
	map=tmp.uscounty
	data=tmp.&prefix._county_lvl_cmplt
	anno=tmp.state_anno_outline
	all;
	id county_fips;
	choro pct_i_snp / discrete legend=legend1 coutline=white;
	format pct_i_snp county_i_snp_pct.;
	run;
quit;

%if generate_svg_file=1 %then %do; ods listing close; %end;
