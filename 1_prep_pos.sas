
/*******************************************************************************
This code:
	* imports POS data
	* fixes POS data (carry backward for late catches)
*******************************************************************************/

/* Set up library references and format of variables */
filename librefs "libname.sas";
%include librefs;


/*****************************************************************************
**** import POS 
*****************************************************************************/

filename pos13	"<path to POS folders>/POS_OTHER_DEC13.csv";
filename pos14	"<path to POS folders>/POS_OTHER_DEC14.csv";
filename pos15	"<path to POS folders>/POS_OTHER_DEC15.csv";
filename pos16	"<path to POS folders>/POS_OTHER_DEC16.csv";
filename pos17	"<path to POS folders>/POS_OTHER_DEC17.csv";
filename pos18	"<path to POS folders>/POS_OTHER_DEC18.csv";
filename pos19	"<path to POS folders>/POS_OTHER_DEC19.csv";
filename pos20	"<path to POS folders>/POS_OTHER_DEC20.csv";


%macro import_pos;

	%do yr = 13 %to 20;

		proc import datafile = pos&yr.
					out = tmp.pos_20&yr.
					dbms = csv
					replace;
					guessingrows = max;
		quit;

	%end;

%mend import_pos;

%import_pos;


/*****************************************************************************
**** check
*****************************************************************************/

%macro check_pos;
	%do year = 2013 %to 2020;
		proc freq data = tmp.pos_&year.;
			tables HOSP_BSD_SW MLT_OWND_FAC_ORG_SW / missing;
		run;
	%end;
%mend check_pos;
%check_pos;


/*****************************************************************************
**** clean POS, keep useful variables
*****************************************************************************/

%macro clean_pos;

	%do year = 2013 %to 2020;

		data outdata.pos_&year.;
			set tmp.pos_&year. 
				(keep = prvdr_num 
						PRVDR_CTGRY_CD
						CITY_NAME
						FAC_NAME
						ZIP_CD
						STATE_CD
						ST_ADR
						FIPS_CNTY_CD
						CBSA_URBN_RRL_IND
						BED_CNT
						HOSP_BSD_SW
						GNRL_CNTL_TYPE_CD
						MLT_OWND_FAC_ORG_SW
				rename = (prvdr_num = PRVDR_NUM_POS
						PRVDR_CTGRY_CD = CATEGORY_POS
						CITY_NAME = CITY_POS
						FAC_NAME = NAME_POS
						ZIP_CD = ZIP_pos
						STATE_CD = STATE_POS
						ST_ADR = ADDRESS_POS
						FIPS_CNTY_CD = FIPS_POS
						CBSA_URBN_RRL_IND = URBAN_RURAL
						BED_CNT = BED_CNT_POS
						HOSP_BSD_SW = hospital_based_pos
						GNRL_CNTL_TYPE_CD = ownership_type_pos
						MLT_OWND_FAC_ORG_SW = part_of_chain_pos
						));

			if ownership_type_pos in ("01", "02", "03", "13") then for_profit = 0;
				else if ownership_type_pos in ("04", "05", "06", "07", "08", "09", "10", "11", "12") then for_profit = 1;

			if hospital_based_pos in ("Y", "y") then hospital_based = 1;
				else if hospital_based_pos in ("N", "n") then hospital_based = 0;

			if part_of_chain_pos in ("Y", "y") then part_of_chain = 1;
				else if part_of_chain_pos in ("N", "n") then part_of_chain = 0;

			/* add a few so to compatible with LTCFocus */
			if for_profit = 1 then profit = "Yes";
				else if for_profit = 0 then profit = "No";

			totbeds_num = BED_CNT_POS;

			if part_of_chain = 1 then multifac = "Yes";
				else if part_of_chain = 0 then multifac = "No";
	

		run;

		proc sql;
			select count(distinct prvdr_num_pos) as n_&year. from outdata.pos_&year.;
		quit;

	%end;


%mend clean_pos;
%clean_pos;


/*******************************************************************************
* append to a single file
*******************************************************************************/

proc sql;
	create table outdata.pos_13_20 as 
	select *, 2013 as year
	from outdata.pos_2013
	UNION (
		select *, 2014 as year from outdata.pos_2014)
	UNION (
		select *, 2015 as year from outdata.pos_2015)
	UNION (
		select *, 2016 as year from outdata.pos_2016)
	UNION (
		select *, 2017 as year from outdata.pos_2017)
	UNION (
		select *, 2018 as year from outdata.pos_2018)
	UNION (
		select *, 2019 as year from outdata.pos_2019)
	UNION (
		select *, 2020 as year from outdata.pos_2020);
quit;



/*******************************************************************************
* extract AK and DC NHs, since LTC focus does not have them
*******************************************************************************/

proc print data = outdata.pos_13_20 (obs = 20);
	var STATE_POS FIPS_POS;
run;

proc sql;
	create table tmp.pos_ak_dc_13_20 as 
	select *, 
		(case when STATE_POS = "AK" then "Pacific" 
		when STATE_POS = "DC" then "south" else "" end) as region_fac
	from outdata.pos_13_20
	where STATE_POS in ("AK", "DC");
quit;


/*******************************************************************************
* merge with Rural Urban code
*******************************************************************************/
proc import datafile = '<path to RUCC code>/ruralurbancodes2013.xls'
			out = rucc_2013
			dbms = xls
			replace;
run;

data rucc_2013;
	set rucc_2013;
	county_fips = input(substr(fips, 3, 3), best12.);
	metro = (rucc_2013 in (1, 2, 3));
run;

proc sql;
	create table outdata.pos_ak_dc_13_20 as 
	select a.*, b.fips, b.metro 
	from tmp.pos_ak_dc_13_20 as a 
		left join rucc_2013 as b 
		on a.STATE_POS = b.state and a.FIPS_POS = b.county_fips;
quit;



/*******************************************************************************
* define balanced panel in AK and DC
*******************************************************************************/

proc sql;
	create table tmp.pos_ak_dc_stable_id as 
	select distinct PRVDR_NUM_POS as CCN 
	from outdata.pos_ak_dc_13_20
	where PRVDR_NUM_POS in (select distinct PRVDR_NUM_POS from outdata.pos_ak_dc_13_20 where year = 2013)
		and PRVDR_NUM_POS in (select distinct PRVDR_NUM_POS from outdata.pos_ak_dc_13_20 where year = 2014)
		and PRVDR_NUM_POS in (select distinct PRVDR_NUM_POS from outdata.pos_ak_dc_13_20 where year = 2015)
		and PRVDR_NUM_POS in (select distinct PRVDR_NUM_POS from outdata.pos_ak_dc_13_20 where year = 2016)
		and PRVDR_NUM_POS in (select distinct PRVDR_NUM_POS from outdata.pos_ak_dc_13_20 where year = 2017)
		and PRVDR_NUM_POS in (select distinct PRVDR_NUM_POS from outdata.pos_ak_dc_13_20 where year = 2018)
		and PRVDR_NUM_POS in (select distinct PRVDR_NUM_POS from outdata.pos_ak_dc_13_20 where year = 2019)
		and PRVDR_NUM_POS in (select distinct PRVDR_NUM_POS from outdata.pos_ak_dc_13_20 where year = 2020);
quit;



