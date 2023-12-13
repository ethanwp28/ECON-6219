// Question 1

// a.
clear all
use http://fmwww.bc.edu/ec-p/data/Mills2d/exchq.dta
twoway (line exchq qtr), name(graph1) xtitle("Quarter") ytitle("Exchange Rate")
title("Dollar/Sterling Exchange Rate vs Quarter")

// b.

//Create two variables
gen y_t = exchq
gen dy_t = y_t - L.y_t
//AR(0) model:
reg dy_t if qtr >= tq(1973q1)
estimate store ar_0
//AR(1) model:
reg dy_t L.dy_t if qtr >= tq(1973q1)
estimate store ar_1
//AR(2) model:
reg dy_t L(1/2).dy_t if qtr >= tq(1973q1)
estimate store ar_2
//AR(3) model:
reg dy_t L(1/3).dy_t if qtr >= tq(1973q1)
estimate store ar_3
estimate stats ar_0 ar_1 ar_2 ar_3

// c.
dfuller y_t, lags(1) regress

// d.
save y_t, replace
drop if qtr >= tq(1996q1)
arima y_t, arima(1,1,0)
tsappend, add(4)
predict fory_t, y dynamic(tq(1995q4))
drop y_t
merge m:1 qtr using y_t
gen qtr_trunc = qtr if qtr >= tq(1996q1)
format qtr_trunc %tq
gen actual = y_t if qtr >= tq(1996q1)
gen forecasted = fory_t if qtr >= tq(1996q1)
twoway (line actual qtr_trunc,title("Actual")) \\ (line forecasted qtr_trunc,title("Forecast")),
name(graph2) xtitle("Quarter") ytitle("Exchange Rate") 
title("Dollar/Sterling Exchange Rate vs Quarter")

// Question 2

// a.
clear all
use http://fmwww.bc.edu/ec-p/data/Mills2d/exchq.dta
program ar2sim, rclass
drop _all
set obs `1'
tempvar time
gen `time' = _n
tsset `time'
tempvar e
gen `e' = rnormal()
tempvar y
gen `y' = 0 in 1/2
replace `y' = (1+`2')*L.`y' - `2'*L2.`y' + (`3'*`e') in 3/l
dfuller `y', lags(1)
return scalar p = r(p)
end
reg D.exchq L(1)D.exchq
set seed 6219
ar2sim 100 0.2020 0.0917

// b. 
set seed 6219
quietly simulate pval=r(p), reps(5000): ar2sim 100 0.2020 0.0917
summarize
count if pval <=0.10
gen prob_1=551/5000
display prob

// c.
clear all
use http://fmwww.bc.edu/ec-p/data/Mills2d/exchq.dta
program ar2sim_2, rclass
drop _all
set obs `1'
tempvar time
gen `time' = _n
tsset `time'
tempvar e
gen `e' = rnormal()
tempvar y
gen `y' = 0 in 1/2
replace `y' = (1+`2'+`3')*L.`y' - `2'*L2.`y' + (`4'*`e') in 3/l
dfuller `y', lags(1)
return scalar p = r(p)
end
reg D.exchq L(1)exchq L(1)D.exchq
set seed 6219
quietly simulate pval=r(p), reps(5000): ar2sim_2 100 0.2134 -0.0664 0.0893
summarize
count if pval<=0.10
gen prob_2=1861/5000
display prob_2

// d.
program ar2sim, rclass
drop _all
set obs `1'
tempvar time
gen `time' = _n
tsset `time'
tempvar e
gen `e' = rnormal()
tempvar y
gen `y' = 0 in 1/2
replace `y' = (1+`2')*L.`y' - `2'*L2.`y' + (`3'*`e') in 3/l
dfuller `y', lags(1)
return scalar p = r(p)
end
set seed 6219
quietly simulate pval=r(p), reps(5000): ar2sim 200 0.2020 0.0917
summarize
count if pval <=0.10
gen prob_3=537/5000
display prob_3
set seed 6219
quietly simulate pval=r(p), reps(5000): ar2sim_2 200 0.2134 -0.0664 0.0893
summarize
count if pval <=0.10
gen prob_4=4197/5000
display prob_4