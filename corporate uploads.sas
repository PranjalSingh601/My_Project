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

libname CSRDEV "G:\New_Project _1\CSRDEV\Corporate uploads";
%let CSRDEV=G:\Gangadhar\CSRDEV\Corporate uploads;
%put &csrdev;
proc import datafile="G:\Gangadhar\CSRDEV\Corporate uploads\uploads.xls"
out=YTDLoading dbms=excel replace;
range="2015Jan-Aug$";
run;

data YTDloading;
set ytdloading;	
drop f20-f30;
if Jan--Aug=" " then delete;
run;

proc transpose data=ytdloading out=ytdloading1(DROP=_LABEL_  RENAME=(COL1=Uploads)); 
BY UIN ;
VAR Jan--Aug;

run;

DATA ytdloading1;
set ytdloading1;
label _NAME_=Month;
run;
data valid_uploads;
set ytdloading1;
Run_month="&sysdate";
run;
data Target_uploads;
set Target_uploads(drop= f3-f10);
run;
proc sort data=target_uploads;
by UAN;
run;

proc sql;
create table TargetVsuploads
as select a.UIN,a._Name_,a.Uploads,
b.Target
from valid_uploads a
join
target_uploads b
on a.UIN=b.UAN;
quit;

data missed_uploads;
set targetVsuploads;
if target gt uploads;
run;

data Jan_missed Feb_Missed Mar_missed Apr_missed May_Missed Jun_missed Jul_missed Aug_Missed;
set Missed_uploads;
if _NAME_="Jan" then output Jan_missed;
if _NAME_="Feb" then output Feb_missed;
if _NAME_="Mar" then output Mar_missed;
if _NAME_="Apr" then output Apr_missed;
if _NAME_="May" then output May_missed;
if _NAME_="Jun" then output Jun_missed;
if _NAME_="Jul" then output Jul_missed;
if _NAME_="Aug" then output Aug_missed;
run;

%let Month=Mar;
%put &month;

proc export outfile="G:\Gangadhar\CSRDEV\Corporate uploads\Missed uploads by month.xls"
data=aug_missed dbms=excel replace;
sheet="aug";
run;
