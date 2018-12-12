proc contents data=devdata.develop varnum;
run;


proc means data=devdata.develop;
run;


proc means data=devdata.develop min P1 P5 P10 P20 P25 P30 P40 P50 P60 P70 P75 P80 P90 P95 P99 max;
var depamt invbal;
run;


proc means data=devdata.develop nmiss;
run;


proc means data=devdata.develop;
var ddabal;
run;


proc means data=devdata.develop;
run;


                /* Class - 2 */

proc means data=devdata.develop n nmiss  min P1 P5 P10 P20 P25 P30 P40 P50 P60 P70 P75 P80 P90 P95 P99 max;
var ccbal;
run; 
 
/* Capping between P5 and P95 */ 
data devdata.capped_data;
set devdata.develop;
if ccbal >= 43604 then ccbal = 43604;
if ccbal < 0 and ccbal ne . then ccbal = 0; /* Outlier treatment done first but taking into account that
missing values are not replaced by 0 in this step */


run;

/* Replace missing values with mean */
proc stdize data= devdata.capped_data missing=mean reponly;
var ccbal;
run;

proc means data=devdata.develop mean stddev  min P1 P5 P10 P20 P25 P30 P40 P50 P60 P70 P75 P80 P90 P95 P99 max;
run;





/* Capping generalized at P5 and P95 */
data devdata.capped_data;
set devdata.develop;
if ccbal < 0 and ccbal ne . then ccbal = 0;
if ccbal >= 43604 then ccbal = 43604; /* Outlier treatment done first but taking into account that
missing values are not replaced by 0 in this step */

if ddabal < 0 and ddabal ne . then ddabal = 0;
if ddabal >= 8297.27 then ddabal = 8297.27; 

if nsfamt < 0 and nsfamt ne . then nsfamt = 0;
if nsfamt >= 9.33 then nsfamt = 9.33; 

if savbal < 0 and savbal ne . then savbal = 0;
if savbal >= 15282.76 then savbal = 15282.76; 

if atmamt < 0 and atmamt ne . then atmamt = 0;
if atmamt >= 5023.27 then atmamt = 5023.27; 

if posamt < 0 and posamt ne . then posamt = 0;
if posamt >= 5023.27 then posamt = 5023.27; 

if cdbal < 0 and cdbal ne . then cdbal = 0;
if cdbal >= 10000.00 then cdbal = 10000.00; 

if irabal < 0 and irabal ne . then irabal = 0;
if irabal >= 0 then irabal = 0; 

if locbal < 0 and locbal ne . then locbal = 0;
if locbal >= 258.5 then locbal = 258.5; 

if mmbal < 0 and mmbal ne . then mmbal = 0;
if mmbal >= 15237.86 then mmbal = 15237.86; 

if mtgbal < 0 and mtgbal ne . then mtgbal = 0;
if mtgbal >= 0 then mtgbal = 0; 

if depamt < 0 and depamt ne . then depamt = 0;
if depamt >= 7069.69 then depamt = 7069.69; 

if invbal < 0 and invbal ne . then invbal = 0;
if invbal >= 0 then invbal = 0; 
run;



/* Replace missing values with mean */
/* proc stdize data= devdata.capped_data missing=median reponly; */
/* var ddabal nsfamt savbal atmamt posamt cdbal irabal locbal mmbal mtgbal */
/* ccbal depamt invbal; */
/* run; */


proc stdize data= devdata.capped_data out=devdata.standardized_data missing=median  reponly;
run;



/* Dummy variable for branch and res (Make n-1) */
data devdata.modified_data;
set devdata.standardized_data;
res_r = (res='R');
res_u = (res='U');

branch_b1 = (branch='B1');
branch_b2 = (branch='B2');
branch_b3 = (branch='B3');
branch_b4 = (branch='B4');
branch_b5 = (branch='B5');
branch_b6 = (branch='B6');
branch_b7 = (branch='B7');
branch_b8 = (branch='B8');
branch_b9 = (branch='B9');
branch_b10 = (branch='B10');
branch_b11 = (branch='B11');
branch_b12 = (branch='B12');
branch_b13 = (branch='B13');
branch_b14 = (branch='B14');
branch_b15 = (branch='B15');
branch_b16 = (branch='B16');
branch_b17 = (branch='B17');
branch_b18 = (branch='B18');
run;

proc means data=devdata.modified_data nmiss;
run;

/* Diving the data in 10 bands */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var ddabal ;
ranks ddabal_rank;
run;

proc freq data=devdata.ranked;
tables ddabal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables ddabal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables ddabal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */




data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by ddabal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;

/* IV on both both quant. and qual. */
/* No need of proc rank on qualitative variables. */
/* proc rank done only on quantitative variables. */




/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var acctage ;
ranks acctage_rank;
run;

proc freq data=devdata.ranked;
tables acctage_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables acctage_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables acctage_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by acctage_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;















/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var cashbk ;
ranks cashbk_rank;
run;

proc freq data=devdata.ranked;
tables cashbk_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables cashbk_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables cashbk_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by cashbk_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;















/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var checks ;
ranks checks_rank;
run;

proc freq data=devdata.ranked;
tables checks_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables checks_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables checks_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by checks_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;













/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var nsfamt ;
ranks nsfamt_rank;
run;

proc freq data=devdata.ranked;
tables nsfamt_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables nsfamt_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables nsfamt_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by nsfamt_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;







/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var savbal ;
ranks savbal_rank;
run;

proc freq data=devdata.ranked;
tables savbal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables savbal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables savbal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by savbal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;







/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var atmamt ;
ranks atmamt_rank;
run;

proc freq data=devdata.ranked;
tables atmamt_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables atmamt_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables atmamt_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by atmamt_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;





















/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var phone ;
ranks phone_rank;
run;

proc freq data=devdata.ranked;
tables phone_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables phone_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables phone_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by phone_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;




















/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var teller ;
ranks teller_rank;
run;

proc freq data=devdata.ranked;
tables teller_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables teller_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables teller_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by teller_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;




































/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var pos ;
ranks pos_rank;
run;

proc freq data=devdata.ranked;
tables pos_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables pos_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables pos_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by pos_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;







/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var posamt ;
ranks posamt_rank;
run;

proc freq data=devdata.ranked;
tables posamt_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables posamt_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables posamt_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by posamt_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;







/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var cdbal ;
ranks cdbal_rank;
run;

proc freq data=devdata.ranked;
tables cdbal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables cdbal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables cdbal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by cdbal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var irabal ;
ranks irabal_rank;
run;

proc freq data=devdata.ranked;
tables irabal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables irabal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables irabal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by irabal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;







/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var locbal ;
ranks locbal_rank;
run;

proc freq data=devdata.ranked;
tables locbal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables locbal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables locbal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by locbal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;







/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var ilsbal ;
ranks ilsbal_rank;
run;

proc freq data=devdata.ranked;
tables ilsbal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables ilsbal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables ilsbal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by ilsbal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;

















/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var mmbal ;
ranks mmbal_rank;
run;

proc freq data=devdata.ranked;
tables mmbal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables mmbal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables mmbal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by mmbal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;



















/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var mmcred ;
ranks mmcred_rank;
run;

proc freq data=devdata.ranked;
tables mmcred_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables mmcred_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables mmcred_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by mmcred_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;






















/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var mtgbal ;
ranks mtgbal_rank;
run;

proc freq data=devdata.ranked;
tables mtgbal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables mtgbal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables mtgbal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by mtgbal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;













/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var ccbal ;
ranks ccbal_rank;
run;

proc freq data=devdata.ranked;
tables ccbal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables ccbal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables ccbal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by ccbal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;












/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var ccpurc ;
ranks ccpurc_rank;
run;

proc freq data=devdata.ranked;
tables ccpurc_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables ccpurc_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables ccpurc_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by ccpurc_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;













/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var income ;
ranks income_rank;
run;

proc freq data=devdata.ranked;
tables income_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables income_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables income_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by income_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var lores ;
ranks lores_rank;
run;

proc freq data=devdata.ranked;
tables lores_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables lores_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables lores_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by lores_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var hmval ;
ranks hmval_rank;
run;

proc freq data=devdata.ranked;
tables hmval_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables hmval_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables hmval_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by hmval_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var age ;
ranks age_rank;
run;

proc freq data=devdata.ranked;
tables age_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables age_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables age_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by age_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var crscore ;
ranks crscore_rank;
run;

proc freq data=devdata.ranked;
tables crscore_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables crscore_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables crscore_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by crscore_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;












/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var dep ;
ranks dep_rank;
run;

proc freq data=devdata.ranked;
tables dep_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dep_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dep_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dep_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var depamt ;
ranks depamt_rank;
run;

proc freq data=devdata.ranked;
tables depamt_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables depamt_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables depamt_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by depamt_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */

proc rank data=devdata.modified_data groups = 10 out = devdata.ranked;
var invbal ;
ranks invbal_rank;
run;

proc freq data=devdata.ranked;
tables invbal_rank/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables invbal_rank/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables invbal_rank/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by invbal_rank;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;






/* NO NEED OF proc rank ON QUALITATIVE VARIABLES. */





/* ---------------------------------------------------------------- */


proc freq data=devdata.modified_data;
tables dirdep/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.modified_data;
tables dirdep/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.modified_data;
tables dirdep/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dirdep;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dirdep/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dirdep/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dirdep/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dirdep;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables nsf/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables nsf/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables nsf/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by nsf;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables sav/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables sav/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables sav/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by sav;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables atm/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables atm/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables atm/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by atm;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables cd/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables cd/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables cd/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by cd;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables ira/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables ira/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables ira/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by ira;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables loc/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables loc/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables loc/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by loc;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;







/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables ils/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables ils/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables ils/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by ils;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;




/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables mm/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables mm/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables mm/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by mm;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables mtg/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables mtg/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables mtg/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by mtg;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables cc/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables cc/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables cc/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by cc;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables sdb/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables sdb/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables sdb/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by sdb;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables hmown/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables hmown/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables hmown/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by hmown;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables moved/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables moved/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables moved/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by moved;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables inarea/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables inarea/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables inarea/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by inarea;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables ins/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables ins/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables ins/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by ins;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables inv/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables inv/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables inv/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by inv;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables branch_r/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables branch_r/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables branch_r/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by branch_r;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;










/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;











/* ---------------------------------------------------------------- */


proc freq data=devdata.ranked;
tables dda/out = devdata.one_all(rename = (count = count_all percent = percent_all));
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables dda/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

/* Dataset having all the description of total customers, responders and 
   non-responders in the form of numbers and percentages in the bands of age.	 */

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by dda;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;























































































proc freq data=devdata.ranked;
tables (res_r res_u);/*out = devdata.one_all(rename = (count = count_all percent = percent_all)); */
run;

/* How many people in each band are buying that product */

proc freq data=devdata.ranked;
tables (res_r res_u)/out = devdata.one_event(rename = (count = count_one_event percent = percent_one_event));
where ins = 1;
run;

/* How many people in each band are not buying that product */

proc freq data=devdata.ranked;
tables res_r res_u/out = devdata.one_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

data devdata.final_merged;
merge devdata.one_all devdata.one_event devdata.one_non_event;
by res_r res_u;
/* Weight Of Evidence */
/* woe = 100 * log(percent_one_event/percent_non_event); */
IV =(percent_one_event-percent_non_event)* log(percent_one_event/percent_non_event);
/* Information Value becomes the basis of picking up variables. */
total_IV + IV;
run;
























/* ---------------------------------------------------------------------- */


/* To print the output of the following code using a single snippet of code. */


proc means data=sashelp.class;
var weight;
run;


proc means data=sashelp.class;
var weight;
class age;
run;



proc means data=sashelp.class;
var weight;
class sex;
run;


proc means data=sashelp.class;
class sex;
class age;
var weight;
run;


/* Printing using a single snippet  */


proc means data=sashelp.class printalltypes;
class sex;
class age;
var weight;
run;


/* proc freq */

proc freq data=sashelp.class;
tables sex;
run;

proc freq data=sashelp.class;
tables sex/out = sukrit;
run;


/* ---------------------------------------------------------------------- */














/* Class - 3 */




proc corr data = devdata.modified_data rank nosimple;
with ins;
var SavBal DDABal CDBal DepAmt DDA Dep ATMAmt MMBal MM Sav CC ccbal atm phone
ira irabal posamt checks inv mmcred pos ccpurc dirdep invbal  
;
run;


proc sort data = devdata.modified_data out = devdata.sorted_ins;
by ins;
run;


proc surveyselect data=devdata.sorted_ins out = devdata.surveyed_data
				  rate = 0.7 seed = 1234 method = srs outall;
strata ins;
run;

/* 70 % trained and 30 % checking of validity */


data devdata.train devdata.valid;
set devdata.surveyed_data;
if selected=1 then output devdata.train;
else output devdata.valid;
run;				



/* Detect multi collinearity using vif of proc reg*/

proc reg data=devdata.train;
model ins =  SavBal DDABal CDBal DepAmt DDA Dep ATMAmt MMBal MM Sav CC ccbal atm phone
ira irabal posamt checks inv mmcred pos ccpurc dirdep invbal /vif;
run;





/* Selecting variables having vif greater than 3*/


/* 
VARIABLE   vif

mmbal = 166.51508
mm = 166.56738
posamt = 3.45365
pos = 3.51519 
*/




/* We need to remove variables having high multi collinearity  */


/* Betas would be inflated if multi-collinearity is not removed.
   Individual effect would not be visible if multi-collinearity is not removed.	 */


/* Removing mm from the list of variables */

proc reg data=devdata.train;
model ins =  SavBal DDABal CDBal DepAmt DDA Dep ATMAmt MMBal  Sav CC ccbal atm phone
ira irabal posamt checks inv mmcred pos ccpurc dirdep invbal /vif;
run;




/* DETECTING AND REMOVING MULTI-COLLINEARITY */

/* Removing pos from the list of variables */

/* Betas from here are not used . */
/* We are concerned with the VIFs calculated from here. */

proc reg data=devdata.train;
model ins =  SavBal DDABal CDBal DepAmt DDA Dep ATMAmt MMBal  Sav CC ccbal atm phone
ira irabal posamt checks inv mmcred ccpurc dirdep invbal /vif;
run;


/* All VIFs are less than 3 now. */


/* Use betas from here. */

proc logistic data=devdata.train;
model ins =  SavBal DDABal CDBal DepAmt DDA Dep ATMAmt MMBal  Sav CC ccbal atm phone
ira irabal posamt checks inv mmcred ccpurc dirdep invbal / selection=stepwise sle = 0.05 sls = 0.05;
run;



/* Write top 7 contributing variables(High wald square value indicates more contribution.)  */

proc logistic data=devdata.train desc outest=devdata.est;
model ins =  SavBal mmbal cdbal ddabal dda cc checks / outroc = devdata.roc; /* New equation of betas in roc  */
run;

/* Area under curve of devdata.valid is same as that of devdata.train. Hence our model is 
correctly formed.  */

proc logistic data=devdata.valid desc outest=devdata.est; 
model ins =  SavBal mmbal cdbal ddabal dda cc checks / outroc = devdata.roc; /* New equation of betas in roc  */
run;



proc logistic data=devdata.train desc outest=devdata.est;
model ins =  SavBal mmbal cdbal ddabal dda cc checks / outroc = devdata.roc; /* New equation of betas in roc  */
score data=devdata.train out = devdata.scored_train;
run;



proc logistic data=devdata.valid desc outest=devdata.est;
model ins =  SavBal mmbal cdbal ddabal dda cc checks / outroc = devdata.roc; /* New equation of betas in roc  */
score data=devdata.valid out = devdata.scored_valid;
run;







/* How do you check your model? We'll using KS-test.  */

/* ON TRAINING DATASET */

proc rank data=devdata.scored_train out=devdata.scored_train_ranked_decile groups=10 descending;
var p_1; /* Predicted probability to an event. */
ranks p_1_rank;
run;


proc freq data= devdata.scored_train_ranked_decile;
tables p_1_rank/out = devdata.scored_train_ranked_event(rename = (count = count_event percent = percent_event));
where ins = 1;
run;

proc freq data= devdata.scored_train_ranked_decile;
tables p_1_rank/out = devdata.scored_train_ranked_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

data devdata.trained_merged_event_non_event;
merge devdata.scored_train_ranked_event devdata.scored_train_ranked_non_event;
by p_1_rank;
run;

data devdata.trained_merged_event_non_event;
retain p_1_rank count_event count_non_event percent_event percent_non_event;
set devdata.trained_merged_event_non_event;
cumulative_count_percent + percent_event;
cumulative_non_count_percent + percent_non_event;
diff_percent = cumulative_count_percent - cumulative_non_count_percent;
run;

/* OUTLIER :  */


/* ON VALID DATASET */

proc rank data=devdata.scored_valid out=devdata.scored_valid_ranked_decile groups=10 descending;
var p_1; /* Predicted probability to an event. */
ranks p_1_rank;
run;


proc freq data= devdata.scored_valid_ranked_decile;
tables p_1_rank/out = devdata.scored_valid_ranked_event(rename = (count = count_event percent = percent_event));
where ins = 1;
run;

proc freq data= devdata.scored_valid_ranked_decile;
tables p_1_rank/out = devdata.scored_valid_ranked_non_event(rename = (count = count_non_event percent = percent_non_event));
where ins = 0;
run;

data devdata.validated_merged_event_non_event;
merge devdata.scored_valid_ranked_event devdata.scored_valid_ranked_non_event;
by p_1_rank;
run;

data devdata.validated_merged_event_non_event;
retain p_1_rank count_event count_non_event percent_event percent_non_event;
set devdata.validated_merged_event_non_event;
cumulative_count_percent + percent_event;
cumulative_non_count_percent + percent_non_event;
diff_percent = cumulative_count_percent - cumulative_non_count_percent;
run;


/* TO validate : KS value equality, c-Value(AUC:area under curve), percent cocordant and percent 
discordant , same signs of estimates. */

