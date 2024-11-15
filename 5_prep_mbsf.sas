/*******************************************************************************
This code prepares MBSF data to get bene characteristics and monthly enrollment inforamtion
*******************************************************************************/

/* Set up library references and format of variables */
filename librefs "libname.sas";
%include librefs;

/*******************************************************************************
*** Note variable naming differences
*******************************************************************************/
%macro check_varnames;

%varlist(mbsfcc.mbsf_abcd_summary_2013);
%varlist(Denom.Dn100mod_2015);
%varlist(Denom.mbsf_abcd_summary_2019);

%mend check_varnames;
%check_varnames;


/*******************************************************************************
*** Read data from Denominator data 2013-2020;
*******************************************************************************/

%let demo_vars1 = DUAL_STUS_CD_: BENE_RACE_CD SEX_IDENT_CD;
%let demo_vars2 = DUAL_STUS_CD_: RACE SEX;
%let geo_vars1 = STATE_CODE COUNTY_CD STATE_CNTY_FIPS_CD:;
%let geo_vars2 = STATE_CD CNTY_CD STATE_CNTY_FIPS_CD:;

%let ma_vars1  = HMO_IND_: 
				 PTC_CNTRCT_ID_: 
				 PTC_PBP_ID_: 
				 PTC_PLAN_TYPE_CD_:
				 ;
%let ma_vars2  = HMOIND:
				 PTC_CNTRCT_ID: 
				 PTC_PBP_ID: 
				 PTC_PLAN_TYPE_CD:
				 ;

%let enroll_vars1 = MDCR_ENTLMT_BUYIN_IND_: ENTLMT_RSN_ORIG BENE_PTA_TRMNTN_CD BENE_PTB_TRMNTN_CD;
%let enroll_vars2 = BUYIN: OREC A_TRM_CD B_TRM_CD;


%let rename1 = (BENE_RACE_CD = race
				SEX_IDENT_CD = sex
				HMO_IND_01 = HMO_IND_1
				HMO_IND_02 = HMO_IND_2
				HMO_IND_03 = HMO_IND_3
				HMO_IND_04 = HMO_IND_4
				HMO_IND_05 = HMO_IND_5
				HMO_IND_06 = HMO_IND_6
				HMO_IND_07 = HMO_IND_7
				HMO_IND_08 = HMO_IND_8
				HMO_IND_09 = HMO_IND_9
				HMO_IND_10 = HMO_IND_10
				HMO_IND_11 = HMO_IND_11
				HMO_IND_12 = HMO_IND_12

				MDCR_ENTLMT_BUYIN_IND_01 = BUYIN1
				MDCR_ENTLMT_BUYIN_IND_02 = BUYIN2
				MDCR_ENTLMT_BUYIN_IND_03 = BUYIN3
				MDCR_ENTLMT_BUYIN_IND_04 = BUYIN4
				MDCR_ENTLMT_BUYIN_IND_05 = BUYIN5
				MDCR_ENTLMT_BUYIN_IND_06 = BUYIN6
				MDCR_ENTLMT_BUYIN_IND_07 = BUYIN7
				MDCR_ENTLMT_BUYIN_IND_08 = BUYIN8
				MDCR_ENTLMT_BUYIN_IND_09 = BUYIN9
				MDCR_ENTLMT_BUYIN_IND_10 = BUYIN10
				MDCR_ENTLMT_BUYIN_IND_11 = BUYIN11
				MDCR_ENTLMT_BUYIN_IND_12 = BUYIN12

				DUAL_STUS_CD_01 = DUAL_STUS_CD_1
				DUAL_STUS_CD_02 = DUAL_STUS_CD_2
				DUAL_STUS_CD_03 = DUAL_STUS_CD_3
				DUAL_STUS_CD_04 = DUAL_STUS_CD_4
				DUAL_STUS_CD_05 = DUAL_STUS_CD_5
				DUAL_STUS_CD_06 = DUAL_STUS_CD_6
				DUAL_STUS_CD_07 = DUAL_STUS_CD_7
				DUAL_STUS_CD_08 = DUAL_STUS_CD_8
				DUAL_STUS_CD_09 = DUAL_STUS_CD_9

				PTC_CNTRCT_ID_01    = PTC_CNTRCT_ID_1   
				PTC_CNTRCT_ID_02    = PTC_CNTRCT_ID_2   
				PTC_CNTRCT_ID_03    = PTC_CNTRCT_ID_3   
				PTC_CNTRCT_ID_04    = PTC_CNTRCT_ID_4   
				PTC_CNTRCT_ID_05    = PTC_CNTRCT_ID_5   
				PTC_CNTRCT_ID_06    = PTC_CNTRCT_ID_6   
				PTC_CNTRCT_ID_07    = PTC_CNTRCT_ID_7   
				PTC_CNTRCT_ID_08    = PTC_CNTRCT_ID_8   
				PTC_CNTRCT_ID_09    = PTC_CNTRCT_ID_9   

				PTC_PBP_ID_01       = PTC_PBP_ID_1      
				PTC_PBP_ID_02       = PTC_PBP_ID_2      
				PTC_PBP_ID_03       = PTC_PBP_ID_3      
				PTC_PBP_ID_04       = PTC_PBP_ID_4      
				PTC_PBP_ID_05       = PTC_PBP_ID_5      
				PTC_PBP_ID_06       = PTC_PBP_ID_6      
				PTC_PBP_ID_07       = PTC_PBP_ID_7      
				PTC_PBP_ID_08       = PTC_PBP_ID_8      
				PTC_PBP_ID_09       = PTC_PBP_ID_9      

				PTC_PLAN_TYPE_CD_01 = PTC_PLAN_TYPE_CD_1
				PTC_PLAN_TYPE_CD_02 = PTC_PLAN_TYPE_CD_2
				PTC_PLAN_TYPE_CD_03 = PTC_PLAN_TYPE_CD_3
				PTC_PLAN_TYPE_CD_04 = PTC_PLAN_TYPE_CD_4
				PTC_PLAN_TYPE_CD_05 = PTC_PLAN_TYPE_CD_5
				PTC_PLAN_TYPE_CD_06 = PTC_PLAN_TYPE_CD_6
				PTC_PLAN_TYPE_CD_07 = PTC_PLAN_TYPE_CD_7
				PTC_PLAN_TYPE_CD_08 = PTC_PLAN_TYPE_CD_8
				PTC_PLAN_TYPE_CD_09 = PTC_PLAN_TYPE_CD_9

				STATE_CNTY_FIPS_CD_01 = STATE_CNTY_FIPS_CD_1
				STATE_CNTY_FIPS_CD_02 = STATE_CNTY_FIPS_CD_2
				STATE_CNTY_FIPS_CD_03 = STATE_CNTY_FIPS_CD_3
				STATE_CNTY_FIPS_CD_04 = STATE_CNTY_FIPS_CD_4
				STATE_CNTY_FIPS_CD_05 = STATE_CNTY_FIPS_CD_5
				STATE_CNTY_FIPS_CD_06 = STATE_CNTY_FIPS_CD_6
				STATE_CNTY_FIPS_CD_07 = STATE_CNTY_FIPS_CD_7
				STATE_CNTY_FIPS_CD_08 = STATE_CNTY_FIPS_CD_8
				STATE_CNTY_FIPS_CD_09 = STATE_CNTY_FIPS_CD_9

				ENTLMT_RSN_ORIG = OREC);

%let rename2 = (STATE_CD = STATE_CODE
				CNTY_CD = COUNTY_CD

				HMOIND01 = HMO_IND_1
				HMOIND02 = HMO_IND_2
				HMOIND03 = HMO_IND_3
				HMOIND04 = HMO_IND_4
				HMOIND05 = HMO_IND_5
				HMOIND06 = HMO_IND_6
				HMOIND07 = HMO_IND_7
				HMOIND08 = HMO_IND_8
				HMOIND09 = HMO_IND_9
				HMOIND10 = HMO_IND_10
				HMOIND11 = HMO_IND_11
				HMOIND12 = HMO_IND_12

				BUYIN01 = BUYIN1
				BUYIN02 = BUYIN2
				BUYIN03 = BUYIN3
				BUYIN04 = BUYIN4
				BUYIN05 = BUYIN5
				BUYIN06 = BUYIN6
				BUYIN07 = BUYIN7
				BUYIN08 = BUYIN8
				BUYIN09 = BUYIN9
				BUYIN10 = BUYIN10
				BUYIN11 = BUYIN11
				BUYIN12 = BUYIN12

				DUAL_STUS_CD_01 = DUAL_STUS_CD_1
				DUAL_STUS_CD_02 = DUAL_STUS_CD_2
				DUAL_STUS_CD_03 = DUAL_STUS_CD_3
				DUAL_STUS_CD_04 = DUAL_STUS_CD_4
				DUAL_STUS_CD_05 = DUAL_STUS_CD_5
				DUAL_STUS_CD_06 = DUAL_STUS_CD_6
				DUAL_STUS_CD_07 = DUAL_STUS_CD_7
				DUAL_STUS_CD_08 = DUAL_STUS_CD_8
				DUAL_STUS_CD_09 = DUAL_STUS_CD_9

				PTC_CNTRCT_ID_01    = PTC_CNTRCT_ID_1   
				PTC_CNTRCT_ID_02    = PTC_CNTRCT_ID_2   
				PTC_CNTRCT_ID_03    = PTC_CNTRCT_ID_3   
				PTC_CNTRCT_ID_04    = PTC_CNTRCT_ID_4   
				PTC_CNTRCT_ID_05    = PTC_CNTRCT_ID_5   
				PTC_CNTRCT_ID_06    = PTC_CNTRCT_ID_6   
				PTC_CNTRCT_ID_07    = PTC_CNTRCT_ID_7   
				PTC_CNTRCT_ID_08    = PTC_CNTRCT_ID_8   
				PTC_CNTRCT_ID_09    = PTC_CNTRCT_ID_9   

				PTC_PBP_ID_01       = PTC_PBP_ID_1      
				PTC_PBP_ID_02       = PTC_PBP_ID_2      
				PTC_PBP_ID_03       = PTC_PBP_ID_3      
				PTC_PBP_ID_04       = PTC_PBP_ID_4      
				PTC_PBP_ID_05       = PTC_PBP_ID_5      
				PTC_PBP_ID_06       = PTC_PBP_ID_6      
				PTC_PBP_ID_07       = PTC_PBP_ID_7      
				PTC_PBP_ID_08       = PTC_PBP_ID_8      
				PTC_PBP_ID_09       = PTC_PBP_ID_9      

				PTC_PLAN_TYPE_CD_01 = PTC_PLAN_TYPE_CD_1
				PTC_PLAN_TYPE_CD_02 = PTC_PLAN_TYPE_CD_2
				PTC_PLAN_TYPE_CD_03 = PTC_PLAN_TYPE_CD_3
				PTC_PLAN_TYPE_CD_04 = PTC_PLAN_TYPE_CD_4
				PTC_PLAN_TYPE_CD_05 = PTC_PLAN_TYPE_CD_5
				PTC_PLAN_TYPE_CD_06 = PTC_PLAN_TYPE_CD_6
				PTC_PLAN_TYPE_CD_07 = PTC_PLAN_TYPE_CD_7
				PTC_PLAN_TYPE_CD_08 = PTC_PLAN_TYPE_CD_8
				PTC_PLAN_TYPE_CD_09 = PTC_PLAN_TYPE_CD_9

				STATE_CNTY_FIPS_CD_01 = STATE_CNTY_FIPS_CD_1
				STATE_CNTY_FIPS_CD_02 = STATE_CNTY_FIPS_CD_2
				STATE_CNTY_FIPS_CD_03 = STATE_CNTY_FIPS_CD_3
				STATE_CNTY_FIPS_CD_04 = STATE_CNTY_FIPS_CD_4
				STATE_CNTY_FIPS_CD_05 = STATE_CNTY_FIPS_CD_5
				STATE_CNTY_FIPS_CD_06 = STATE_CNTY_FIPS_CD_6
				STATE_CNTY_FIPS_CD_07 = STATE_CNTY_FIPS_CD_7
				STATE_CNTY_FIPS_CD_08 = STATE_CNTY_FIPS_CD_8
				STATE_CNTY_FIPS_CD_09 = STATE_CNTY_FIPS_CD_9

				A_TRM_CD = BENE_PTA_TRMNTN_CD
				B_TRM_CD = BENE_PTB_TRMNTN_CD);



%macro read_mbsf;

	%do year = 2013 %to 2020;

		%if &year. < 2015 %then %do;

			data tmp.mbsf_&year._rr;
				set mbsfcc.mbsf_abcd_summary_&year.
					(keep = BENE_ID 
							&geo_vars1. 
							&demo_vars1.
							&ma_vars1.
							&enroll_vars1.
					rename = &rename1.);
				year = &year.;
			run;

		%end;

		%if &year. >= 2015 and &year. < 2019 %then %do;

			data tmp.mbsf_&year._rr;
				set Denom.Dn100mod_&year. 
					(keep = BENE_ID 
							&geo_vars2. 
							&demo_vars2.
							&ma_vars2.
							&enroll_vars2.
					rename = &rename2.);
				year = &year.;	
			run;

		%end;


		%if &year. >= 2019 %then %do;

			data tmp.mbsf_&year._rr;
				set Denom.mbsf_abcd_summary_&year. 
					(keep = BENE_ID 
							&geo_vars1. 
							&demo_vars1.
							&ma_vars1.
							&enroll_vars1.
					rename = &rename1.);
				year = &year.;
			run;

		%end;

		proc sort data = tmp.mbsf_&year._rr; 
			by BENE_ID; 
		run;

	%end;


proc sql;
	select memname, nobs, nvar
	from dictionary.tables
	where libname = 'tmp' and memtype = 'DATA';
quit;

%mend read_mbsf;
%read_mbsf;


/*******************************************************************************
*** Prep MBSF; add indicator
*******************************************************************************/

%macro prep_mbsf(mm);

	%do year = 2013 %to 2020;

		data tmp.mbsf_&year._rr2;
			set tmp.mbsf_&year._rr;

			/* Exclusions */
			if (BENE_PTA_TRMNTN_CD in (2, 3, 9) or BENE_PTB_TRMNTN_CD in (2, 3, 9)) then flag_termination_&year. = 1;

			if STATE_CODE in ('', ' ', '40', '48', '54', '56', '57', '58', '59', '60', '61', '62', '63', '64', '65', '66', '97', '98', '99') 
				then flag_nonmainland_&year. = 1;/* exclude benes with missing state IDs and benes in US territories */
		
			*if COUNTY_CD not in ('', ' '); /* exclude benes with missing county IDs */

			/* Concatenate state and county codes */
			ssacounty_&year. = strip(STATE_CODE)||strip(COUNTY_CD);

			/* full dual indicator - December */
			array dual_status_cd(12) DUAL_STUS_CD_1 - DUAL_STUS_CD_12;
			array full_dual(12) full_dual_1 - full_dual_12;
			do i = 1 to 12;
				full_dual(i) = (dual_status_cd(i) in ('02' '04' '08'));
			end;
			drop i;

			/* Enrollment variables */
			array hmoind(12) HMO_IND_1 - HMO_IND_12;
			array PTC_CNTRCT_ID(12) PTC_CNTRCT_ID_1 - PTC_CNTRCT_ID_12;
			array PTC_PLAN_TYPE_CD(12) PTC_PLAN_TYPE_CD_1 - PTC_PLAN_TYPE_CD_12;
			array BUYIN(12) BUYIN1 - BUYIN12;

			array ma_enrollee(12) ma_enrollee_1 - ma_enrollee_12;
			array ma_contract_type(12) ma_contract_type_1 - ma_contract_type_12;
			array mmp(12) mmp_1 - mmp_12;
			array pace(12) pace_1 - pace_12;
			array enroll_AB(12) enroll_AB_1 - enroll_AB_12;

			do i = 1 to 12;
				/* Medicare Advantage (MA) enrollment variables */
				ma_enrollee(i) = (hmoind(i) in ('1' '2' 'A' 'B' 'C'));
				ma_contract_type(i) = substr(PTC_CNTRCT_ID(i),1,1);

				/* Flag MMPs and PACE plans */
				mmp(i)  = (PTC_PLAN_TYPE_CD(i) = '48' or PTC_PLAN_TYPE_CD(i) = '49');
				pace(i) = (PTC_PLAN_TYPE_CD(i) = '20');

				/* Enrolled Part A & B - December */
				enroll_AB(i) = (BUYIN(i) in ('3','C'));
			end;
			drop i;

			/* race dummies for counting */
			if RACE = 1 then white_&year. = 1;
				else if RACE = 2 then black_&year. = 1;
				else if RACE = 5 then hispanic_&year. = 1;
				else if RACE = 4 then asian_&year. = 1;
			
			/* code gender */
			if sex = '1' then female_&year. = 0;
				else if sex = '2' then female_&year. = 1;
				else female_&year. = .;
				
			/* code original reason */
			disabled_&year. = (OREC in ('1', '3'));

			drop DUAL_STUS_CD_: HMO_IND_: BUYIN: PTC_PLAN_TYPE_CD:
				BENE_PTA_TRMNTN_CD BENE_PTB_TRMNTN_CD
				RACE sex OREC; 

		run;
	%end;

%mend prep_mbsf;
%prep_mbsf;


/*******************************************************************************
*** Rename variables so that they can be comapred to elig period data
*******************************************************************************/
%macro rename_mbsf;

	%do year = 2013 %to 2020;

	%let start = %eval((&year - 2013) * 12 + 1);
	%let end = %eval(&start. + 11);

		data tmp.mbsf_&year._rr3;
			set tmp.mbsf_&year._rr2
			(rename = (
				full_dual_1 - full_dual_12 = full_dual_&start. - full_dual_&end.
				ma_enrollee_1 - ma_enrollee_12 = ma_enrollee_&start. - ma_enrollee_&end.
				ma_contract_type_1 - ma_contract_type_12 = ma_contract_type_&start. - ma_contract_type_&end.
				mmp_1 - mmp_12 = mmp_&start. - mmp_&end.
				pace_1 - pace_12 = pace_&start. - pace_&end.
				enroll_AB_1 - enroll_AB_12 = enroll_AB_&start. - enroll_AB_&end.
				PTC_CNTRCT_ID_1-PTC_CNTRCT_ID_12 = PTC_CNTRCT_ID_&start.-PTC_CNTRCT_ID_&end.
				PTC_PBP_ID_1-PTC_PBP_ID_12 = PTC_PBP_ID_&start.-PTC_PBP_ID_&end.
				STATE_CNTY_FIPS_CD_1-STATE_CNTY_FIPS_CD_12 = STATE_CNTY_FIPS_CD_&start.-STATE_CNTY_FIPS_CD_&end.
				));
		run;

	%end;

%mend rename_mbsf;
%rename_mbsf;

* check;
%varlist(tmp.mbsf_2020_rr3);

/*******************************************************************************
*** Flatten all to bene level
*******************************************************************************/


/* create a master list of all bene 2013-2020 */
proc sql;
	create table tmp.mbsf_13_20_bene_lst as 
	select distinct bene_id 
	from tmp.mbsf_2013_rr3
	UNION 
		select distinct bene_id 
		from tmp.mbsf_2014_rr3
	UNION 
		select distinct bene_id 
		from tmp.mbsf_2015_rr3
	UNION 
		select distinct bene_id 
		from tmp.mbsf_2016_rr3
	UNION 
		select distinct bene_id 
		from tmp.mbsf_2017_rr3
	UNION 
		select distinct bene_id 
		from tmp.mbsf_2018_rr3
	UNION 
		select distinct bene_id 
		from tmp.mbsf_2019_rr3
	UNION 
		select distinct bene_id 
		from tmp.mbsf_2020_rr3
	;
quit;

%macro sort;

	%do year = 2013 %to 2020;

	proc sort data = tmp.mbsf_&year._rr3;
		by bene_id;
	run;

	%end;


%mend sort;
%sort;

/* merge all monthly indicators */
proc sql;
	create table tmp.mbsf_monthly_13_20 as 
	select * 
	from tmp.mbsf_13_20_bene_lst as a 
	left join tmp.mbsf_2013_rr3(drop = STATE_CODE COUNTY_CD year)as mbsf2013 on a.bene_id = mbsf2013.bene_id
	left join tmp.mbsf_2014_rr3(drop = STATE_CODE COUNTY_CD year)as mbsf2014 on a.bene_id = mbsf2014.bene_id
	left join tmp.mbsf_2015_rr3(drop = STATE_CODE COUNTY_CD year)as mbsf2015 on a.bene_id = mbsf2015.bene_id
	left join tmp.mbsf_2016_rr3(drop = STATE_CODE COUNTY_CD year)as mbsf2016 on a.bene_id = mbsf2016.bene_id
	left join tmp.mbsf_2017_rr3(drop = STATE_CODE COUNTY_CD year)as mbsf2017 on a.bene_id = mbsf2017.bene_id
	left join tmp.mbsf_2018_rr3(drop = STATE_CODE COUNTY_CD year)as mbsf2018 on a.bene_id = mbsf2018.bene_id
	left join tmp.mbsf_2019_rr3(drop = STATE_CODE COUNTY_CD year)as mbsf2019 on a.bene_id = mbsf2019.bene_id
	left join tmp.mbsf_2020_rr3(drop = STATE_CODE COUNTY_CD year)as mbsf2020 on a.bene_id = mbsf2020.bene_id;
quit;

%varlist(tmp.mbsf_monthly_13_20);
