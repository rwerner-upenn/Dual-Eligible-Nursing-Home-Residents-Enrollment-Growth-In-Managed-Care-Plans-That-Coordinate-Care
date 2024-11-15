/*******************************************************************************
This code use sall MDS quarterly + discharge assessment to 
	define eligible period for each resident
	1. find the first quarterly assessment
	2. find the associated discharge assessment
*******************************************************************************/

/* Set up library references and format of variables */
filename librefs "libname.sas";
%include librefs;

/* data inventory */
filename mds12  '<path to MDS data>/';
filename mds13  '<path to MDS data>/';
filename mds14a '<path to MDS data>/';
filename mds14b '<path to MDS data>/';
filename mds15  '<path to MDS data>/';
filename mds16  '<path to MDS data>/';
filename mds17a '<path to MDS data>/';
filename mds17b '<path to MDS data>/';
filename mds18a '<path to MDS data>/';
filename mds18b '<path to MDS data>/';
filename mds19a '<path to MDS data>/';
filename mds19b '<path to MDS data>/';
filename mds19c '<path to MDS data>/';
filename mds19d '<path to MDS data>/';
filename mds20a '<path to MDS data>/';
filename mds20b '<path to MDS data>/';
filename mds20c '<path to MDS data>/';
filename mds20d '<path to MDS data>/';


/* variable to keep */
%LET varlist30 = RSDNT_INTRNL_ID
				STATE_CD FAC_PRVDR_INTRNL_ID 
				A0100B_CMS_CRTFCTN_NUM 
				TRGT_DT /* note 2017-2020 different date format */ 
				A0310F_ENTRY_DSCHRG_CD 
				A0310A_FED_OBRA_CD 
				A0310B_PPS_CD
				A1700_ENTRY_TYPE_CD 
				A0310A_FED_OBRA_CD
				A2100_DSCHRG_STUS_CD /* discharge status code */
				A0800_GNDR_CD /* gender */
				C_RSDNT_AGE_NUM /* age */
				A1000A_AMRCN_INDN_AK_NTV_CD
				A1000B_ASN_CD
				A1000C_AFRCN_AMRCN_CD
				A1000D_HSPNC_CD
				A1000E_NTV_HI_PCFC_ISLNDR_CD
				A1000F_WHT_CD
				C0500_BIMS_SCRE_NUM
				C0600_CNDCT_STF_MENTL_STUS_CD
				B0100_CMTS_CD
				B0700_SELF_UNDRSTOD_CD
				C0700_SHRT_TERM_MEMRY_CD
				G0110H2_EATG_SPRT_CD
				G0110A1_BED_MBLTY_SELF_CD	
				G0110G1_DRESS_SELF_CD		
				G0110B1_TRNSFR_SELF_CD		
				G0110I1_TOILTG_SELF_CD		
				G0110J1_PRSNL_HYGNE_SELF_CD
				G0110H1_EATG_SELF_CD	
				G0110E1_LOCOMTN_ON_SELF_CD
				E0200a_Phys_Bhvrl_Cd /* ARBS */
				E0200b_Vrbl_Bhvrl_Cd /* ARBS */
				E0200c_Othr_Bhvrl_Cd /* ARBS */
				E0800_Rjct_Evaltn_Cd /* ARBS */
				C1000_DCSN_MKNG_CD
				C1600_CHG_MENTL_STUS_CD
				I0600_HRT_FAILR_CD
				I6300_RSPRTRY_FAILR_CD
				I7900_NO_ACTV_DEASE_CD
				J1100A_SOB_EXRTN_CD
				J1100B_SOB_SITG_CD
				J1100C_SOB_LYG_CD
				J1100Z_NO_SOB_CD
				J1400_LIFE_PRGNS_CD
				J1550C_DHYDRT_CD
				J1550Z_NO_PRBLM_COND_CD
				K0100A_LOSS_MOUTH_EATG_CD
				K0100B_HLD_FOOD_MOUTH_CD
				K0100C_CHOK_DRNG_MEAL_CD
				K0100D_CMPLNT_SWLWG_CD
				K0100Z_NO_SWLWG_CD
				M0210_STG_1_HGHR_ULCR_CD
				M0300A_STG_1_ULCR_NUM
				M0300B1_STG_2_ULCR_NUM
				M0300C1_STG_3_ULCR_NUM
				M0300D1_STG_4_ULCR_NUM
				M0300E1_UNSTGBL_ULCR_DRSNG_NUM
				M0300F1_UNSTGBL_ULCR_ESC_NUM
				M0300G1_UNSTGBL_ULCR_DEEP_NUM
				M0700_ULCR_TISUE_TYPE_CD
				;

%LET varlist_add =  C1310A_MENTL_STUS_CHG_CD; /* see more in CHESS scale note*/

/*******************************************************************************
* MDS 2013-2020: append same year data
*******************************************************************************/

%macro prep1(year, filenm, varlist);

data tmp.mds_&year.;
	set &filenm.(keep = &varlist.);
run;

%mend prep1;
%prep1(2012, mds.mds_2012, &varlist30.);
%prep1(2013, mds.mds_2013, &varlist30.);
%prep1(2015, mds.mds_2015, &varlist30. &varlist_add.);
%prep1(2016, mds.mds_2016, &varlist30. &varlist_add.);


%macro prep2(year, filenm1, filenm2, varlist);

data tmp.mds_&year.;
	set &filenm1.(keep = &varlist.)
		&filenm2.(keep = &varlist.);
run;

%mend prep2;
%prep2(2014, mds.mds_jan_jun_2014, mds.mds_jul_dec_2014, &varlist30.);
%prep2(2017, mds.mds_q1q2_2017, mds.mds_q3q4_2017, &varlist30. &varlist_add.);
%prep2(2018, mds.mds_q1q2_2018, mds.mds_q3q4_2018, &varlist30. &varlist_add.);



%macro prep3;
data tmp.mds_2019;
	set mds19.mds_q1_2019 (keep = &varlist30. &varlist_add.)
		mds19.mds_q2_2019 (keep = &varlist30. &varlist_add.)
		mds19.mds_q3_2019 (keep = &varlist30. &varlist_add.)
		mds19.mds_q4_2019 (keep = &varlist30. &varlist_add.);
run;

data tmp.mds_2020;
	set mds20.mds_q1_2020 (keep = &varlist30. &varlist_add.)
		mds20.mds_q2_2020 (keep = &varlist30. &varlist_add.)
		mds20.mds_q3_2020 (keep = &varlist30. &varlist_add.)
		mds20.mds_q4_2020 (keep = &varlist30. &varlist_add.);
run;
%mend prep3;
%prep3;


/*******************************************************************************
* MDS 2013-2020: filter assessment 
*******************************************************************************/
%macro mds_filter;

	%do year = 2012 %to 2020;

	data tmp.mds_&year._rr;
		set tmp.mds_&year.;


		/* target date */
		if &year < 2017 then do;
			assessment_date = input(TRGT_DT, YYMMDD10.);
			year = year(assessment_date);
			month = month(assessment_date);
			day = day(assessment_date);
		end;

		else if &year >= 2017 then do;
			year = input(substr(put(TRGT_DT, $10.), 3, 4), 4.);
			month = input(substr(put(TRGT_DT, $10.), 7, 2), 2.);
			day = input(substr(put(TRGT_DT, $10.), 9, 2), 2.);
			assessment_date = mdy(month, day, year);
		end;

		/* month 1-108 for align all assessments */
		m = (year - 2012) * 12 + month;

		/* code assessment types */
		if A0310F_ENTRY_DSCHRG_CD in ('10', '11', '12') then discharge = 1;
			else if A0310A_FED_OBRA_CD in ('01') or A0310B_PPS_CD in ('01') then 
			do;
				if A1700_ENTRY_TYPE_CD = 1 then	admission = 1;
				if A1700_ENTRY_TYPE_CD = 2 then reentry = 1;
			end;
			else if A0310A_FED_OBRA_CD in ('02', '03') then 
			do;
				annual_quarterly = 1;
				if A0310A_FED_OBRA_CD in ('02') then quarterly = 1;
				if A0310A_FED_OBRA_CD in ('03') then annual = 1;
			end;
			else if A0310A_FED_OBRA_CD in ('04') then sig_change = 1;


		*** filter types;
		if annual_quarterly = 1 or discharge = 1;

		*** code up type for data wrangling;
		if annual_quarterly = 1 then type = 1;
			else if discharge = 1 then type = 2;

		obs_id = _N_;
		unique_id = catx("-", year, obs_id);

		drop admission reentry annual sig_change obs_id;


	run;

	%end; 

%mend mds_filter;
%mds_filter;


/*******************************************************************************
* MDS 2013-2020: merge in bene_id
*******************************************************************************/

%macro get_bene_id(year, xwalk);

	proc sql;
		create table tmp.mds_&year._rr_bene as 
		select mds.*, xwalk.bene_id, 1 as mds_indicator
		from tmp.mds_&year._rr as mds 
			join &xwalk. as xwalk
			on mds.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and mds.state_cd=xwalk.state_cd;
	quit;
	

%mend get_bene_id;
%get_bene_id(2011, mds.mds3_res_bene_xwalk);
%get_bene_id(2013, mds.mds3_res_bene_xwalk);
%get_bene_id(2014, mds.Mds3_res_bene_xwalk_2014);
%get_bene_id(2015, mds.Mds_res_bene_xwalk_2016);
%get_bene_id(2016, mds.Mds_res_bene_xwalk_2016);
%get_bene_id(2017, mds.Mds_res_bene_xwalk_1718);
%get_bene_id(2018, mds.Mds_res_bene_xwalk_1718);
%get_bene_id(2019, mds19x.res_bene_xwalk);
%get_bene_id(2020, mds20x.mds3_res_bene_xwalk_20);


/*******************************************************************************
* MDS 2013-2020: add useful variables to assessment level data
*******************************************************************************/

%macro addvar;
	%do year = 2013 %to 2020;
	
		data tmp.mds_&year._rr_bene_prep;
			set tmp.mds_&year._rr_bene
				(rename = (
					G0110A1_BED_MBLTY_SELF_CD	= BED_SELF
					G0110G1_DRESS_SELF_CD		= DRESS_SELF 
					G0110B1_TRNSFR_SELF_CD		= TRANS_SELF 
					G0110I1_TOILTG_SELF_CD		= TOILET_SELF
					G0110J1_PRSNL_HYGNE_SELF_CD = HYGNE_SELF
					G0110H1_EATG_SELF_CD		= EAT_SELF
					G0110E1_LOCOMTN_ON_SELF_CD	= LOC_UNIT_SELF
					C_RSDNT_AGE_NUM = age
					A0100B_CMS_CRTFCTN_NUM = CCN));

			/* code long/short stay */
			if A0310B_PPS_CD in ('01') then shortstay = 1;
				else shortstay = 0;

			/* gender */
			if A0800_GNDR_CD = 2 then female = 1;
				else if A0800_GNDR_CD = 1 then female = 0;

			/* race */			
			if A1000F_WHT_CD				eq '1' then white = 1; 
				else if A1000F_WHT_CD		eq '0' then white = 0;
			if A1000C_AFRCN_AMRCN_CD				eq '1' then black = 1;
				else if A1000C_AFRCN_AMRCN_CD		eq '0' then black = 0;
			if A1000D_HSPNC_CD				eq '1' then hispanic = 1; 
				else if A1000D_HSPNC_CD		eq '0' then hispanic = 0;
			if A1000A_AMRCN_INDN_AK_NTV_CD  eq '1' 
				or A1000B_ASN_CD			eq '1'
				or A1000E_NTV_HI_PCFC_ISLNDR_CD eq '1' then other = 1; 
				else if A1000A_AMRCN_INDN_AK_NTV_CD  eq '0' 
					and A1000B_ASN_CD				 eq '0'
					and A1000E_NTV_HI_PCFC_ISLNDR_CD eq '0' then other = 0;

			/* cognition - CFS*/

			if C0600_CNDCT_STF_MENTL_STUS_CD = "0" then cognitive_impairment = C0500_BIMS_SCRE_NUM;
			if cognitive_impairment = . then cognitive_impairment = "99";
			cognitive_impairment = input(cognitive_impairment, 12.);

			label cognitive_impairment = "cognitive impairment based on the BIMS scale";

				* Calculate CPS
				* Documentation: https://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/NursingHomeQualityInits/Downloads/NHQIPAC_QM_Appendix2.pdf;
				if B0100_CMTS_CD eq "1" OR (C1000_DCSN_MKNG_CD  eq "3" and G0110H2_EATG_SPRT_CD in ("4","8","-")) then cps=6;
					else if C1000_DCSN_MKNG_CD eq "3" 
							and G0110H2_EATG_SPRT_CD in ("0","1","2","3") then cps = 5;
					else if C1000_DCSN_MKNG_CD eq "2" 
							and B0700_SELF_UNDRSTOD_CD in ("1","2","3") then cps = 4;
					else if (C1000_DCSN_MKNG_CD eq "2" or B0700_SELF_UNDRSTOD_CD in ("1","2","3")) 
							and (C0700_SHRT_TERM_MEMRY_CD eq "1" and C1000_DCSN_MKNG_CD in ("1","2"))
						 OR (C0700_SHRT_TERM_MEMRY_CD eq "1" and B0700_SELF_UNDRSTOD_CD in ("1","2","3"))
						 OR (C1000_DCSN_MKNG_CD in ("1","2") and B0700_SELF_UNDRSTOD_CD in ("1","2","3")) then cps = 3;
					else if (C1000_DCSN_MKNG_CD ne "2" and B0700_SELF_UNDRSTOD_CD ne "1" and B0700_SELF_UNDRSTOD_CD ne "2" and B0700_SELF_UNDRSTOD_CD ne "3") 
							and (C0700_SHRT_TERM_MEMRY_CD eq "1" and C1000_DCSN_MKNG_CD in ("1","2"))
						  OR (C0700_SHRT_TERM_MEMRY_CD eq "1" and B0700_SELF_UNDRSTOD_CD in ("1","2","3"))
						  OR (C1000_DCSN_MKNG_CD in ("1","2") and B0700_SELF_UNDRSTOD_CD in ("1","2","3")) then cps = 2;
					else if C0700_SHRT_TERM_MEMRY_CD eq "1" 
						OR C1000_DCSN_MKNG_CD in ("1","2") 
						OR B0700_SELF_UNDRSTOD_CD in ("1","2","3") then cps = 1;
					else if C0700_SHRT_TERM_MEMRY_CD ne "1" 
							and C1000_DCSN_MKNG_CD ne "1" 
							and C1000_DCSN_MKNG_CD ne "2" 
							and B0700_SELF_UNDRSTOD_CD ne "1" 
							and B0700_SELF_UNDRSTOD_CD ne "2" 
							and B0700_SELF_UNDRSTOD_CD ne "3" then cps = 0;

				* Calculate CFS
				* Documentation: The Minimum Data Set 3.0 cognitive Function Scale (by Kali Thomas, et al);

				if cognitive_impairment>=13 and cognitive_impairment<=15 then cfs = 1;
					else if cognitive_impairment>=8 and cognitive_impairment<=12 then cfs = 2;
					else if cognitive_impairment>=0 and cognitive_impairment<=7 then cfs = 3;
					else if cps in (0,1,2) then cfs = 2;
					else if cps in (3,4) then cfs = 3;
					else if cps in (5,6) then cfs = 4;
				label cfs = "cognitive functional status";

			/* define ADRD */
			if cfs in (3, 4) then adrd = 1;
				else if cfs in (1, 2) then adrd = 0;
				else adrd = .;

			/* functioning: ADL - LONG FORM*/
			array adl_self_char{7} BED_SELF TRANS_SELF LOC_UNIT_SELF DRESS_SELF TOILET_SELF EAT_SELF HYGNE_SELF;
			array adl_self_num{7} num_bed num_trans num_loc num_dress num_toilet num_eat num_hygne;

			do i = 1 to 7;
				adl_self_num(i) = input(adl_self_char(i), 1.);
				if adl_self_num(i) in (7, 8) then adl_self_num(i) = 4; /* recode not occured to total dependence */
			end;

			drop i;

			adl_long_form = sum(num_bed, num_trans, num_loc, num_dress, num_toilet, num_eat, num_hygne);
			drop num_: BED_SELF DRESS_SELF TRANS_SELF TOILET_SELF HYGNE_SELF EAT_SELF;

			/* ARBS */

			if '0'<=E0200a_Phys_Bhvrl_Cd<='3'
				and '0'<=E0200b_Vrbl_Bhvrl_Cd<='3' 
				and '0'<=E0200c_Othr_Bhvrl_Cd<='3' 
				and '0'<=E0800_Rjct_Evaltn_Cd<='3'
				then MDS3_ARBS = E0200a_Phys_Bhvrl_Cd + E0200b_Vrbl_Bhvrl_Cd + E0200c_Othr_Bhvrl_Cd + E0800_Rjct_Evaltn_Cd;

  				else if A0310f_Entry_Dschrg_Cd in('01','12')
				  	or (A0310f_Entry_Dschrg_Cd in('01','10','11','12') and MDS3_Target_Date<MDY(10,1,2012))
					or (A0310b_PPS_Cd='07' and MDS3_Target_Date<MDY(10,1,2019))
					or (A0310a_Fed_OBRA_Cd='99' and A0310b_PPS_Cd='99' and A0310f_Entry_Dschrg_Cd='99')
					then MDS3_ARBS=.A;		* Missing because assessment type is out of range.	;

  				else if B0100_Cmts_Cd='1'
					then MDS3_ARBS=.P;		* Missing because not in eligible population (Comatose)	;

  				else if E0200a_Phys_Bhvrl_Cd='-' 
  					or E0200b_Vrbl_Bhvrl_Cd='-' 
  					or E0200c_Othr_Bhvrl_Cd='-' 
  					or E0800_Rjct_Evaltn_Cd='-'
					then MDS3_ARBS=.I;		* Missing because of missing item(s) that should have been asked.	;

  			label MDS3_ARBS	= 'MDS3_ARBS|MDS 3.0 Agitated and Reactive Behavior Scale (Range: 0-12), by multiply validated algorithm of the PHARE team';


  			/* CHESS scale */

			*** 1) End-Stage disease;

			  if J1400_Life_Prgns_Cd='0' then temp_EndStage=0;
				else if J1400_Life_Prgns_Cd='1' then temp_EndStage=1;

			*** 2) ADL score of 21 or greater;	
									
			  if 0<=adl_long_form<21 then temp_ADL_21=0;
				else if 21<=adl_long_form then temp_ADL_21=1;

			*** 3) Any of 4 indicators of Cognitive impairment and/or instability;
			  if cfs=4 then temp_CFS=1; 
			  	else if 0<=cfs<4 then temp_CFS=0;

			  if C1600_Chg_Mentl_Stus_Cd='1' or C1310a_Mentl_Stus_Chg_Cd='1' then temp_Change_Mental=1;
				else if C1600_Chg_Mentl_Stus_Cd='0' or C1310a_Mentl_Stus_Chg_Cd='0' then temp_Change_Mental=0;

			  if MDS3_ARBS>=3 then temp_ARBS_3=1;
				else if 0<=MDS3_ARBS<3 then temp_ARBS_3=0;

			  if C1000_Dcsn_Mkng_Cd in('2','3') then temp_Decision=1;
				else if C1000_Dcsn_Mkng_Cd in('0','1') then temp_Decision=0;
				else if C1000_Dcsn_Mkng_Cd='^' and ('00'<=C0500_Bims_Scre_Num<='15' or C0600_CNDCT_STF_MENTL_STUS_CD='0') then temp_Decision=0;

			  if temp_CFS=1 or temp_Change_Mental=1 or temp_ARBS_3=1 or temp_Decision=1 then temp_Cognitive=1;
				else if temp_ARBS_3=0 and temp_Change_Mental=0 and temp_Decision=0 then temp_Cognitive=0;

			*** 4) Signs and Symptoms;

			  if I6300_Rsprtry_Failr_Cd='1' then temp_Sx_Respiratory=1;
				else if I6300_Rsprtry_Failr_Cd='0' or I7900_No_Actv_Dease_Cd='1' then temp_Sx_Respiratory=0;

			  if I0600_Hrt_Failr_Cd='1' then temp_Sx_HF=1;
				else if I0600_Hrt_Failr_Cd='0' or I7900_No_Actv_Dease_Cd='1' then temp_Sx_HF=0;

			  if J1550c_Dhydrt_Cd='1' then temp_Sx_Dehydration=1;
				else if J1550c_Dhydrt_Cd='0' or J1550z_No_Prblm_Cond_Cd='1' then temp_Sx_Dehydration=0;

			  if J1100a_SOB_Exrtn_Cd='1' or J1100b_SOB_Sitg_Cd='1' or J1100c_SOB_Lyg_Cd='1' then temp_Sx_SOB=1;
				else if J1100a_SOB_Exrtn_Cd='0' and J1100b_SOB_Sitg_Cd='0' and J1100c_SOB_Lyg_Cd='0' then temp_Sx_SOB=0;
				else if J1100z_No_SOB_Cd='1' then temp_Sx_SOB=0;

			  if K0100a_Loss_Mouth_Eatg_Cd='1' or K0100b_Hld_Food_Mouth_Cd='1' or K0100c_Chok_Drng_Meal_Cd='1' or K0100d_Cmplnt_Swlwg_Cd='1' then temp_Sx_Swallowing=1;
				else if K0100a_Loss_Mouth_Eatg_Cd='0' and K0100b_Hld_Food_Mouth_Cd='0' and K0100c_Chok_Drng_Meal_Cd='0' and K0100d_Cmplnt_Swlwg_Cd='0' then temp_Sx_Swallowing=0;
				else if K0100z_No_Swlwg_Cd='1' then temp_Sx_Swallowing=0;

			  if '1'<=M0300c1_Stg_3_Ulcr_Num<='9' 
					or '1'<=M0300d1_Stg_4_Ulcr_Num<='9'
					or '1'<=M0300f1_Unstgbl_Ulcr_Esc_Num<='9'
					or '1'<=M0300g1_Unstgbl_Ulcr_Deep_Num<='9'
					or M0700_Ulcr_Tisue_Type_Cd in('3','4') then temp_Sx_PU3=1;
				else if M0210_Stg_1_Hghr_Ulcr_Cd='0' or M0700_Ulcr_Tisue_Type_Cd in('1','2')
					or (M0210_Stg_1_Hghr_Ulcr_Cd='1'
							and ('1'<=M0300a_Stg_1_Ulcr_Num<='9' or '1'<=M0300b1_Stg_2_Ulcr_Num<='9' or '1'<=M0300e1_Unstgbl_Ulcr_Drsng_Num<='9')
							and ( M0300c1_Stg_3_Ulcr_Num='0' and M0300d1_Stg_4_Ulcr_Num='0'
									and M0300f1_Unstgbl_Ulcr_Esc_Num='0' and M0300g1_Unstgbl_Ulcr_Deep_Num='0') )
				then temp_Sx_PU3=0;

			  if sum(temp_Sx_Respiratory,temp_Sx_HF,temp_Sx_Dehydration,temp_Sx_SOB,temp_Sx_Swallowing,temp_Sx_PU3)>=2 then temp_Symptoms=2;
				else if temp_Sx_Respiratory + temp_Sx_HF + temp_Sx_Dehydration + temp_Sx_SOB + temp_Sx_Swallowing + temp_Sx_PU3 in(0,1)
					then temp_Symptoms = temp_Sx_Respiratory + temp_Sx_HF + temp_Sx_Dehydration + temp_Sx_SOB + temp_Sx_Swallowing + temp_Sx_PU3;

			*** Final scale;

			  MDS3_CHESS = temp_EndStage + temp_ADL_21 + temp_Cognitive + temp_Symptoms ;
			  if MDS3_CHESS=. then do;
				if A0310f_Entry_Dschrg_Cd in('01','10','11','12') then MDS3_CHESS=.A;
				else if A0310a_Fed_OBRA_Cd='99' and A0310b_PPS_Cd in('07','99') and A0310f_Entry_Dschrg_Cd='99' then MDS3_CHESS=.A;
				else if B0100_Cmts_Cd='1' then MDS3_CHESS=.P;
				else if J1400_Life_Prgns_Cd='-'
					or adl_long_form in(.,.I)
					or C1600_Chg_Mentl_Stus_Cd='-' or C1310a_Mentl_Stus_Chg_Cd='-'
					or MDS3_ARBS in(.,.I)
					or I6300_Rsprtry_Failr_Cd='-' or I0600_Hrt_Failr_Cd='-' or J1550c_Dhydrt_Cd='-' or J1100z_No_SOB_Cd='-' or K0100z_No_Swlwg_Cd='-'
					or M0210_Stg_1_Hghr_Ulcr_Cd='-'
					then MDS3_CHESS=.I;
				else MDS3_CHESS=.I;
				end;

			  label MDS3_CHESS	= 'MDS3_CHESS|Minimum Data Set 3.0 Changes in Health, End-stage disease and Symptoms and Signs (CHESS) Score, defined by PHARE multiply validated algorithm';

			  drop
				temp_EndStage
				temp_ADL_21
				temp_CFS temp_Change_Mental temp_ARBS_3 temp_Decision temp_Cognitive
				temp_Sx_Respiratory temp_Sx_HF temp_Sx_Dehydration temp_Sx_SOB temp_Sx_Swallowing temp_Sx_PU3 temp_Symptoms
				;
			  
			  keep year m unique_id bene_id state_cd
				shortstay annual_quarterly
				age female white black hispanic other cfs adrd
				CCN mds_indicator adl_long_form MDS3_CHESS
				;
		run;
		
	%end;
	
%mend addvar;
%addvar;


/*******************************************************************************
* Append all quarterly/dischareg assessment
*******************************************************************************/

%macro append_mds;

	proc sql;
		create table tmp.mds_elig_period_prep1 as 
		select distinct bene_id, m, type
		from tmp.mds_2012_rr_bene
		UNION 
			select distinct bene_id, m, type from tmp.mds_2013_rr_bene
		UNION 
			select distinct bene_id, m, type from tmp.mds_2014_rr_bene
		UNION 
			select distinct bene_id, m, type from tmp.mds_2015_rr_bene
		UNION 
			select distinct bene_id, m, type from tmp.mds_2016_rr_bene
		UNION 
			select distinct bene_id, m, type from tmp.mds_2017_rr_bene
		UNION 
			select distinct bene_id, m, type from tmp.mds_2018_rr_bene
		UNION 
			select distinct bene_id, m, type from tmp.mds_2019_rr_bene
		UNION 
			select distinct bene_id, m, type from tmp.mds_2020_rr_bene
		ORDER BY bene_id, m
		;

		select count(distinct bene_id) as n_bene 
		from tmp.mds_elig_period_prep1;
	
	quit;


%mend append_mds;
%append_mds;

/*******************************************************************************
* transpose to bene level (line up all quarterly discharge assessment by bene)
*******************************************************************************/

%macro transpose;

/* handle multiple types in the same month */
/* notice here the only possibility is Q + D in the same month - we assign this a new type (3) */

proc sql;
	create table tmp.mds_elig_period_prep2 as 
	select a.*, (case when b.n > 1 then 3 else a.type end) as type2
	from tmp.mds_elig_period_prep1 as a 
	join (
		select bene_id, m, count(*) as n
		from tmp.mds_elig_period_prep1
		group by bene_id, m
		) as b 
		on a.bene_id = b.bene_id and a.m = b.m;
quit;

proc print data = tmp.mds_elig_period_prep1 (obs = 200);
run;

proc print data = tmp.mds_elig_period_prep2 (obs = 200);
run;

proc sql;
	create table tmp.mds_elig_period_prep3 as 
	select distinct bene_id, m, type2 as type
	from tmp.mds_elig_period_prep2;
quit;

proc transpose data = tmp.mds_elig_period_prep3 out = tmp.mds_elig_period_prep4 (drop = _name_);
	by bene_id;
	id m;
	var type;
run;

%varlist(tmp.mds_elig_period_prep4);

proc print data = tmp.mds_elig_period_prep4 (obs = 200);
run;

%mend transpose;
%transpose;


/*******************************************************************************
* code eligible period by traversing assessments
*******************************************************************************/

%macro code_elig_period;

data tmp.mds_elig_period_prep5;
	set tmp.mds_elig_period_prep4;

	* counter for episode of stay;
	start= 0;

	* indicator of eligibility;
	array elig(108) elig1-elig108;
	array type(108) _1-_108;

	do i = 1 to 108;

		if start = 0 then 
		do;
			if type(i) = 1 then 
			do;
				start = 1;
				elig(i) = 1;
			end;

			else elig(i) = 0;
		end;

		else if start = 1 then 
		do;
			if type(i) in (2, 3) then 
			do;
				start = 0;
				elig(i) = 1;
			end;

			else elig(i) = 1;
		end;

	end;

	drop i;
run;

proc print data = tmp.mds_elig_period_prep4 (obs = 20);
var _1-_108;
run;
proc print data = tmp.mds_elig_period_prep5 (obs = 20);
var elig:;
run;

data tmp.mds_elig_period_12_20;
	set tmp.mds_elig_period_prep5;
	keep bene_id elig13-elig108;
	rename elig13-elig108 = elig1-elig96;
run;

%mend code_elig_period;
%code_elig_period;



/*******************************************************************************
* Keep ALL residents at CCN level in 2013-2020
*******************************************************************************/

* keep all assessment types residents in each CCN;
%macro keep_all;

	%do year = 2013 %to 2020;

	data tmp.mds_&year._all_res;
		set tmp.mds_&year. (keep = RSDNT_INTRNL_ID STATE_CD A0100B_CMS_CRTFCTN_NUM A0310B_PPS_CD
								C_RSDNT_AGE_NUM
								rename = (A0100B_CMS_CRTFCTN_NUM = CCN));

		/* code long/short stay */
		if A0310B_PPS_CD in ('01') then shortstay = 1;
			else shortstay = 0;
		longstay = 1 - shortstay;

		/* age */
		age = C_RSDNT_AGE_NUM;		

		drop C_RSDNT_AGE_NUM A0310B_PPS_CD;

	run;

	%end; 

%mend keep_all;
%keep_all;

* MDS 2013-2020: merge in bene_id, and keep unique resident at each CCN (if ever LTC, then LTC);

%macro get_bene_id_all(year, xwalk);

	proc sql;
		create table tmp.mds_&year._all_res_bene as 
		select mds.*, xwalk.bene_id, 1 as mds_indicator, &year. as year
		from tmp.mds_&year._all_res as mds 
			join &xwalk. as xwalk
			on mds.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and mds.state_cd=xwalk.state_cd;

		create table tmp.mds_&year._all_res_bene_unique as 
		select year, CCN, bene_id, mds_indicator, max(longstay) as longstay, max(age) as age
		from (
			select distinct year, CCN, bene_id, mds_indicator, longstay, age
			from tmp.mds_&year._all_res_bene
			)
		group by year, CCN, bene_id, mds_indicator;
	quit;

%mend get_bene_id_all;

%get_bene_id_all(2013, mds.mds3_res_bene_xwalk);
%get_bene_id_all(2014, mds.Mds3_res_bene_xwalk_2014);
%get_bene_id_all(2015, mds.Mds_res_bene_xwalk_2016);
%get_bene_id_all(2016, mds.Mds_res_bene_xwalk_2016);
%get_bene_id_all(2017, mds.Mds_res_bene_xwalk_1718);
%get_bene_id_all(2018, mds.Mds_res_bene_xwalk_1718);
%get_bene_id_all(2019, mds19x.res_bene_xwalk);
%get_bene_id_all(2020, mds20x.mds3_res_bene_xwalk_20);

* append all residents;

%macro append_mds_all;

	proc sql;
		create table outdata.mds_all_bene_lvl_13_20 as 
		select * 
		from tmp.mds_2013_all_res_bene_unique
		UNION (
			select * from tmp.mds_2014_all_res_bene_unique)
		UNION (
			select * from tmp.mds_2015_all_res_bene_unique)
		UNION (
			select * from tmp.mds_2016_all_res_bene_unique)
		UNION (
			select * from tmp.mds_2017_all_res_bene_unique)
		UNION (
			select * from tmp.mds_2018_all_res_bene_unique)
		UNION (
			select * from tmp.mds_2019_all_res_bene_unique)
		UNION (
			select * from tmp.mds_2020_all_res_bene_unique)
			;
	run;

%mend append_mds_all;
%append_mds_all;
