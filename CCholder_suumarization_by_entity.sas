libname MBRDEV "G:\New_Project\MBRDEV";

%let month=%sysfunc(substr(&sysdate,3,3));
%let run_month=%sysfunc(propcase(&month));
%put &run_month;

data _null_;
run_year="20OCT2016"d;
year=year(run_year);
call symputx ("year1",year);
run;
%put &year;

data _null_;
run_year="20OCT2015"d;
year=year(run_year);
call symputx("year",year);
run;
%let  MBRDEV= G:\Gangadhar\MBRDEV;

proc import datafile="&MBRDEV\Members-&run_month..xls"
out=MEMBERSMTD dbms=excel replace;
range="ccmembers-&year$";
run;
proc sort data=Membersmtd out=members_raw
dupout=	members_dup nodupkey;
by id;
run;

data members_raw1;
set members_raw;
if branch_code="" then branch_code=card_code;
if card_code="" then card_code=branch_code;
run;

data valid_members invalid_members;
set members_raw1;
if branch_code="" and card_code="" then output invalid_members;
else output valid_members;
run;

%let run_month=&sysdate;
%put &run_month;

data deactivated_members valid_members;
set valid_members;
if deactivated="yes" then output deactivated_members;
else output valid_members;
run;

proc means data=valid_members ;
var iso_country iso_region;
run;
proc sort data=valid_members;
by iso_region;
run;

data member_total;
set valid_members;
by iso_region;
if first.iso_region then member_count=0;
member_count+1;
if last.iso_region;
keep iso_country iso_region member_count;
run;

proc export outfile="&MBRDEV\Member_total..xls"
data=Member_total dbms=excel replace;
sheet="&run_month";
run;

