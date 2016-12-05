proc import datafile="G:\Competition\Pranjal\SAS\Transactional_loan.xls"
out=Loan_raw dbms=excel replace;
range="Loans$";
run;

proc import datafile="G:\Competition\Pranjal\SAS\LCDataDictionary.xls"
out=Loan_attributes dbms=excel replace;
range="LoanStats$";
run;

%let year=2011;
data Loan_&year;
set Loan_raw;
where issue_d between "01JAN&year"d and "01DEC&year"d;
run;

proc sql noprint;
select LoanStatNew into:attrib_use
separated by ','
from Loan_attributes;
quit;

%put &attrib_use;

%let year=2011;
data Loan_&year;
set Loan_&year;
keep &attrib;
run;

data Loan_2011_chrgd_off Loan_2011_Fullypaid Loan_2011_crnt Loan_2011_dflt Loan_2011_in_grace;
set Loan_2011;
if loan_status="Charged Off" then output Loan_2011_chrgd_off;
if loan_status="Fully Paid" then output Loan_2011_Fullypaid;
if loan_status="current" then output Loan_2011_crnt;
if loan_status="Default" then output Loan_2011_dflt;
if loan_status="In Grace period" then output Loan_2011_in_grace;
run;
proc dataset lib=work kill;
run;
