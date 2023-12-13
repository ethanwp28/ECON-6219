// Question 1

// a.
import excel using "C:\Users\28epi\Downloads\PS3data.xlsx", firstrow clear
save "C:\Users\28epi\Downloads\PS3data.dta", replace
use "C:\Users\28epi\Downloads\PS3data.dta"
drop in 236/237
save "cleanData.dta", replace
use cleanData.dta

gen time =_n

tsset time

dfuller CPI, lags(2) trend regress
dfuller USDEuro, lags(2) regress

// b.
arima cpi if time >=5, arima(1,1,0)
 estimates store m1
arima cpi if time >=5, arima(2,1,0)
 estimates store m2
arima cpi if time >=5, arima(3,1,0)
 estimates store m3
arima cpi if time >=5, arima(1,1,1)
 estimates store m4
estimates stats m1 m2 m3 m4

// c.

arima usdeuro if time >=5, arima(1,1,0)
 estimates store m1
arima usdeuro if time >=5, arima(2,1,0)
 estimates store m2
arima usdeuro if time >=5, arima(3,1,0)
 estimates store m3
arima usdeuro if time >=5, arima(1,1,1)
 estimates store m4
estimates stats m1 m2 m3 m4

// d.
gen y1=D.cpi
gen y2=D.usdeuro
label variable y1 "D.CPI"
label variable y2 "D.usdeuro"
varsoc y1 y2, maxlag(6)

// e.
quietly var y1 y2 if time<=201, lags(1/2)
 predict y1for, equation(#1)
 label variable y1for "Predicted Change in CPI"
 predict res, equation(#1) residuals
 egen sdf=sd(res)
 gen lcl = y1for – 1.96*sdf
 gen hcl = y1for + 1.96*sdf
twoway (rarea lcl hcl time, fintensity(inten20)) ///
(line y1 y1for time, lpattern(solid dash)) in -36/1, ///
legend(order(2 3 1) label(1 "95% CI"))

// f.
quietly var y1 y2 if time<=201, lags(1/2)
vargranger

// g.
irf create order1, set(myExamp) step(10) replace
irf graph oirf
erase myExamp.irf
quietly var y1 y2 if time<=201, lags(1/2)
irf create order2, set(myExamp) step(10) replace
irf graph oirf
erase myExamp.irf

// Question 2

// a. 
clear all
ssc install tsmktim
import excel "\\apporto. com\dfs \CLT\Users \rkamath1_clt\Documents \industry.×lsx",
sheet("49_Industry Portfolios") firstrow
gen time=_n
tsset time
arch Drugs, garch(1) arch(1)
predict conVar1, variance
gen conVolDrugs = sqrt(conVar1)
arch Util, garch (1) arch (1)
predict conVar2, variance
gen conVolUtils = sqrt (conVar2)
arch Banks, garch(1) arch(1)
predict conVar3, variance
gen conVolBanks = sqrt (conVar3)
tsline conVolDrugs conVolUtils conVolBanks, lpattern (solid) xtitle("Time") ytitle("Conditional
Volatilities") title("Conditional Volatility of all 3 Industry Portfolios")

// b.
mgarch dcc (Drug Util Banks), arch(1) garch(1)

// c.
predict rho*, correlation
tsline rho_Banks_Util rho_Banks_Drugs rho_Util_Drugs, Ipattern (solid) xtitle("Correlation")
title("Conditional Correlations")

// d.
predict m*, xb
predict s*, variance
gen m_Hat = (m_Drugs+m_Banks+m_Util)/3
gen v_Hat = (s Drugs _Drugs+s _Util_Util+s _Banks _Banks +
2*(s_Util_Drugs+s_Banks_Drugs+s_Banks_Uti))/9
gen VaR = (m_Hat - (1.645 * sqrt(v_Hat)))
tsline VaR, xtitle ("Time") ytitle("VaR") title("Portfolio VaR") name (VAR1)

// e.
gen portfolioReturns = (Drugs + Util + Banks)/3
arch portfolioReturns, garch(1) arch(1)
predict me, xb
predict conVar, variance
gen VaR2 = (me - (1.645 * sqrt(conVar)))
tsline VaR2, pattern(solid) xtitle("Time") ytitle("Conditional Volatility") title("VaR from GARCH")
name (VAR2)
graph combine VAR1 VAR2, row(2) col(1)
gen VaR_spread = VaR - VaR2
tsline VaR_spread, Ipattern(solid) xtitle ("Time") ytitle("VaR") title("VaR Spread") name
(VARspread)
graph combine VAR1 VARspread, row(2) col(1)

// f.
generate hit1 = (portfolioReturns-VaR < 0)
summarize hit1
egen aHat1=mean (hit1)
egen tOne1=sum(portfolioReturns-VaR < 0)
gen LogNum1 = (tOne1*log (0.05))+((_N-tOne1)*log(0.95))
gen logDenom1 = (tOne1*log(aHat1))+((_N-tOne1)*log(1-aHat1))
gen UC1=-2* (logNum1-logDenom1)
gen pval1=1-chi2(1, UC1)
disp UC1[_N]
disp pval1[_N]
generate hit2 = (portfolioReturns-VaR2 < 0)
summarize hit2
egen aHat2-mean (hit2)
egen tOne2=sum(portfolioReturns-VaR2 < 0)
gen logNum2 = (tOne2*log(0.05))+((_N-tOne2)*log(0.95))
gen logDenom2 = (tOne2*log(aHat2))+((_N-tOne2)*log(1-aHat2))
gen UC2=-2* (logNum2-logDenom2)
gen pval2=1-chi2(1,UC2)
disp UC2[_N]
disp pval2[_N]