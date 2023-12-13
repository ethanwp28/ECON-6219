// a.
clear all  
freduse GS10 TB3MS USREC  
gen datem = mofd(daten)  
format datem %tm  
gen time = mofd(daten) + 12  
format time %tm  tsset time  
 
gen tbill = 100*(365*TB3MS/100)/(360-91*TB3MS/100)  
gen spread = GS10 - tbill  
gen usreclead = USREC[_n+12]  
 
probit usreclead spread if datem >= tm(1959m1) & datem <= tm(2004m12)  
gen recprob = (normal(_b[_cons] + _b[spread] * spread))*100  
gen USREC1 = USREC*100  
label variable USREC1 "National Recession"  
label variable recprob "Predicted Probability"  
 
twoway (area USREC1 datem, color(gs14)) (tsline recprob, lcolor(navy)) if datem >= tm(1967m1) & datem <= tm(2006m12), xtitle("") ytitle("") tlabel(, format(%tmYY)) title("US Recession Probabilities(percent)") 
 
// b.
clear all  
 
freduse GS10 TB3MS GDPC1 A261RX1Q020SBEA  rename GDPC1 GDP  rename A261RX1Q020SBE GDI  
 
generate time = qofd(daten)  
format time %tq  
drop if missing(GDP)  
drop if time < tq(1958q1)  
drop if time > tq(2005q4)  
tsset time  
 
generate tbill = 100*(365*TB3MS/100)/(360-91*TB3MS/100)  
generate spread = GS10 - tbill  
generate growthrate_GDP = (log(GDP)-log(L.GDP))*100  
generate growthrate_GDI = (log(GDI)-log(L.GDI))*100  
reg growthrate_GDP L4.spread, robust  
predict for_GDP  
reg growthrate_GDI L4.spread, robust  
predict for_GDI 

// c.
reg growthrate_GDP L4.spread L4.growthrate_GDP L4.growthrate_GDI, robust  
predict for_GDP_1c  
reg growthrate_GDI L4.spread L4.growthrate_GDP L4.growthrate_GDI, robust  
predict for_GDI_1c 

// d.
drop if time <tq(1959q1)  
varsoc GDP GDI, maxlag(12) 
 var GDP GDI, lags(2)  
vecrank GDP GDI, trend(constant) lags(2) 
