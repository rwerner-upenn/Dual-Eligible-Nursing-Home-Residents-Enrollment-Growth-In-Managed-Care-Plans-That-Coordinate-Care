/*******************************************************************************
This code prepares the enrollment files from the MBSF data 
*******************************************************************************/

/* Set up library references and format of variables */
filename librefs "libname.sas";
%include librefs;


/*******************************************************************************
*** Import SNP plan data
*******************************************************************************/
proc import datafile = "<path to the enrollment file>/SNPs_2013_2023vFIN.xlsx"
			out = outdata.SNPs_2013_2023vFIN
			dbms = xlsx 
			replace;
run;

* Is the data unique at year-contract-plan level?;
* NO: unique at year-contract-plan-segment id level;

proc sql;
	select count(*) 
	from (
		select distinct year, Contract_Number, Plan_ID
		from outdata.SNPs_2013_2023vFIN);
quit;


/*******************************************************************************
*** Fix the issue where 31 year-contract-plan combo have multiple SNP types
*** solution: assign the type with more enrollees
*******************************************************************************/
proc sort data = outdata.SNPs_2013_2023vFIN;
	by year Contract_Number Plan_ID descending plan_enrollment_1;
run;

data outdata.SNPs_2013_2023vFIN_updated;
	set outdata.SNPs_2013_2023vFIN;
	by year Contract_Number Plan_ID;
	if first.Plan_ID;
run; /* now unique at year-contract-plan level */

* HOW MANY BEFORE 2021;
proc sql;
	select count(*) 
	from outdata.SNPs_2013_2023vFIN
	where year < 2021;
quit;


/*******************************************************************************
*** Sum up enrollees by year and by type
*******************************************************************************/

* number of plans per year, by type;

proc sql;
	select year, count(*) as n_i_snp_plan
	from (
		select distinct year, Contract_Number, Plan_ID 
		from outdata.SNPs_2013_2023vFIN_updated 
		where I_SNP = 1
		)
	group by year;
quit;

proc sql;
	select year, count(*) as n_fide_snp_plan
	from (
		select distinct year, Contract_Number, Plan_ID 
		from outdata.SNPs_2013_2023vFIN_updated 
		where FIDE_SNP = 1
		)
	group by year;
quit;


* number of enrollment per year, by type;

proc sql;
	select year, sum(plan_enrollment_1) as sum_enrollment_i_snp
	from outdata.SNPs_2013_2023vFIN_updated 
	where I_SNP = 1
	group by year;
quit;

proc sql;
	select year, sum(plan_enrollment_1) as sum_enrollment_fide_snp
	from outdata.SNPs_2013_2023vFIN_updated 
	where FIDE_SNP = 1
	group by year;
quit;

