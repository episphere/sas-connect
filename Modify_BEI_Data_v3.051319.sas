/*****************/
/* Program: Modify_BEI_Data_v3.051319
/* Program location: H:\DCEG Connect API Flow\REST API SAS
/* Creation date: May 13, 2019
/* Authors: Nicole Gerlanc 
/* SAS Version: 9.4 TS1M3
/* Study Name: DCEG CONNECT Cohort
/*
/* Version 3: One more attempt at unique IDs
/* 
/* Version 2: Previous random number technique resulted in duplicates.  New method used. siteId changed to Site_Subject_ID.
/* Ugh, new method also creates dups but output might be good for repeated measures. 
/*
/* Description: 
/* Program removes chemical analysis variables from SAShelp dataset BEI, add dummy study specific subject IDs, and saves it in variaous formats.
/*****************/

/* Allows labeling of outputs with version*/
%let VERSION       = v3;
%let DATESTR       = 051319;

*** Load utility macros;
%let MACRO_FOLDER = H:\Macros;
filename macdef "&MACRO_FOLDER/Utility Macros_updated_NG.sas";
%include macdef;

/* Reads in SAS dataset*/
/* SAShelp library is built in and does not need to be specified */
data BEI;
set SAShelp.BEI;
run;

/* List varibles, counts, and other information */
/* n = 24,205 and 24 variables */
proc contents data=BEI;
run;

/* Keep primary analytic variables and exclude nutrient variables */
data reduced_BEI (keep = X Y Elevation Gradient Trees);
set BEI;
run;

/* Assess missingness and get summary statistics */
/* n = 24,205, 5 variables */
proc means data = reduced_BEI n nmiss mean min max std;
run;

/* Add observation number for merging with study ids */
data num_BEI; 
set reduced_BEI; 
cnt+1; 
run;

/* Create a list of 5 digit random numbers to use as study ids*/
/*https://communities.sas.com/t5/SAS-Procedures/unique-random-identifiers/td-p/139370*/
proc plan seed=32329; 
   factors randomID=90000 / noprint; 
   output out=randomID randomID nvals=(10000 to 99999);
   run; 
   quit; 

/* Add observation number for each random ids for merge */
data num_ID; 
set randomID; 
cnt+1; 
run;

/* Merge random IDs with num_BEI dataset */
/* n = 24,205 */
proc sql;
create table ID_BEI as
  select RandomID as Site_Subject_ID,/*SiteID name to match expectation in API, name should be changed to avoid confusion with fields that give site or subsite IDs, also does
  capitalization matter? */
         X,
		 Y,
		 Elevation,
		 Gradient,
		 Trees
 from num_id, num_BEI
 where num_id.cnt=num_BEI.cnt;
quit; 

/* Check for duplicate ids */
/* n = 24,205, no dups */
proc sort data = ID_BEI
nodupkeys;
by Site_Subject_ID;
run;

*** CONVERT DATA TO DIFFERENT FORMATS ***;

/*JSON format only, Options: keys-retains SAS column headers, nosastags - removes SAS metadata */
proc json out="H:\DCEG Connect API Flow\REST API SAS\Reduced_BEI.json";
   export ID_BEI / keys nosastags ;
   run;

/*JSON format with API headers, Options: keys-retains SAS column headers, nosastags - removes SAS metadata */
/*http://documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=9.4_3.4&docsetId=proc&docsetTarget=p1wcs7rozjc521n13wk852dcacs0.htm&locale=en*/
proc json out="H:\DCEG Connect API Flow\REST API SAS\Reduced_BEI_API.json";
   *write open array;
   write open object;
   write values "type" "json";
   write values "filename" "Reduced_BEI_API.json";
   write values "data";
   write open array;
   export ID_BEI / keys nosastags ;
   write close;
   write close;
   *write close;
   run;

proc export data=ID_BEI replace label
    outfile="H:\DCEG Connect API Flow\REST API SAS\Reduced_BEI.csv"
    dbms=csv;
run;


























