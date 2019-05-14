/*****************/
/* Program: SAS_REST_API_BEI_v2.051419
/* Program location: H:\DCEG Connect API Flow\REST API SAS
/* Creation date: May 9, 2019
/* Authors: Nicole Gerlanc and Praphulla Bhawsar
/* SAS Version: 9.4 TS1M3
/* Study Name: DCEG CONNECT Cohort
/*
/* Version 2: API Key removed.
/*
/* Description: 
/* Program converts SAS dataset into JSON format, POSTs JSON dataset to DCEG CONNECT API then GETs same dataset from API. 
/*****************/

/* Allows labeling of outputs with version*/
%let VERSION       = v2;
%let DATESTR       = 051419;

*** Load utility macros;
%let MACRO_FOLDER = H:\Macros;
filename macdef "&MACRO_FOLDER/Utility Macros_updated_NG.sas";
%include macdef;

***** POST *****;

/* modified from https://www.bls.gov/developers/api_sas.htm*/
%let url=https://episphere-connect.herokuapp.com/submit;
filename in  "H:\DCEG Connect API Flow\REST API SAS\Reduced_BEI_API.json";
filename out "H:\DCEG Connect API Flow\REST API SAS\BEI_out.json" recfm=v lrecl=32000;

/* https://communities.sas.com/t5/SAS-Procedures/Requesting-Guidance-on-making-a-PROC-HTTP-call-by-passing-bearer/td-p/476291*/
proc http
url="&url"
Method = "post"
ct = "application/JSON" 
in = in
out = out;
headers
"Authorization" = "Bearer Key";
run;

***** GET *****;

/* modified from https://www.bls.gov/developers/api_sas.htm*/
%let url=https://episphere-connect.herokuapp.com/files/b338f3e5-65fd-45bb-9827-15bdb5cc6789;
*filename in  "H:\DCEG Connect API Flow\REST API SAS\Reduced_BEI_API.json";
filename out_1 "H:\DCEG Connect API Flow\REST API SAS\BEI_All_Data.json" recfm=v lrecl=32000;

/* https://communities.sas.com/t5/SAS-Procedures/Requesting-Guidance-on-making-a-PROC-HTTP-call-by-passing-bearer/td-p/476291*/
proc http
url="&url"
Method = "get"
ct = "application/JSON" 
out = out_1;
headers
"Authorization" = "Bearer Key";
run;













