%let month=%sysfunc (substr(&sysdate,3,3));
%let run_month=%sysfunc (propcase(&month));

%put &month &run_month;

data _null_;
format run_year ddmmyy10.;
run_year="01JAN2016"d;
year_month=cats(year(run_year),put(month(run_year),z2.));
call symputx ("yearmonth",year_month);
run;
%put &yearmonth;

libname CSRDEV "G:\Gangadhar\CSRDEV";
%let CSRDEV=G:\Gangadhar\CSRDEV ;
%put &csrdev;


PROC IMPORT datafile="&CSRDEV\Cashflow-&yearmonth..xls"
out=csrdev.sol_id_grouping dbms=excel replace;
range="Cashflow-&yearmonth$";
run;


proc sort data=Sol_id_grouping;
by Sol_id_grouping;
run;

data occured_flow;
set sol_id_grouping;
by sol_id_grouping;
if first.sol_id_grouping then occured=0;
occured+1;
Total_Average=mean(of Monday_Avg--Thursday_avg);
run;

data forecast_data;
set occured_flow;
if Monday_Avg--Thursday_avg gt total_average;
run;

data All_forecasted_data;
set forecast_data;
array avg(4) monday_avg--thursday_avg;
do i= 1 to 4;
array  forecasted(4) Forecasted_monday forecasted_tuesday forecasted_wednesday forecasted_thursday;
do i= 1 to 4;
forecasted(i)=avg(i)*forecast_percent;
end;
end;
run;

proc sql;
create table occured_averages as
select sol_id_grouping, mean(monday_avg) as occured_monday_avg,
mean(tuesday_avg) as occured_tuesaday_avg,
mean(wednesday_avg) as occured_wednesday_avg,
mean(thursday_avg) as occured_thursday_avg
from all_forecasted_data
group by sol_id_grouping;
quit;


proc sql;
create table forecasted_averages as
select sol_id_grouping, mean(Forecasted_monday) as forecast_avg_monday,
mean(forecasted_tuesday) as forecast_avg_tuesday,
mean(forecasted_wednesday) as forecast_avg_wednesday,
mean(forecasted_thursday) as forecast_avg_thursday
from all_forecasted_data
group by sol_id_grouping;
quit;

proc sql;
create table contingency_table as
select a.*,b.* from occured_averages a 
full join forecasted_averages b
on occured_averages.sol_id_grouping=forecasted_averages.sol_id_grouping;
quit;
