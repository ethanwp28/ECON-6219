// Question 1

// a.
clear all
freduse INDPRO
gen datem = mofd(daten)
format datem %tm
tsset datem
tsline INDPRO, xtitle("") ytitle("Index level") 
title("U.S. Industrial Production - Total Index"), if tin(1972m1,2017m12)

// b.
clear all
freduse IPGMFN
gen datem = mofd(daten)
format datem %tm
tsset datem
tsline IPGMFN, xtitle("") ytitle("Index level") 
title("U.S. Industrial Production - Manufacturing"), if tin(1972m1,2017m12)

// c.
clear all
freduse INDPRO IPGMFN
gen datem = mofd(daten)
format datem %tm
tsset datem
gen Log_Total = ln(INDPRO)
gen Log_Manufacturing = ln(IPGMFN)
tsline INDPRO, xtitle("") ytitle("Index level") 
title("U.S. Industrial Production - Total Index"), if tin(1972m1,2017m12)
tsline IPGMFN, xtitle("") ytitle("Index level") 
title("U.S. Industrial Production - Manufacturing"), if tin(1972m1,2017m12)
tsline Log_Total Log_Manufacturing,ytitle("Index Level") 
title("U.S. Industrial Production Combined"), if tin(1972m1,2017m12)

// Question 2

// a.
clear all
program findmean, rclass
 drop _all
 set obs 100
 gen x = rnormal(-1, sqrt(2))
 quietly summarize x, detail
 return scalar m1 = r(mean)
end
findmean
display r(m1)
set seed 6219
simulate xmean=r(m1), reps(5000): findmean
summarize, detail

// b.
clear all
program findmedian, rclass
 drop _all
 set obs 100
 gen x = rnormal(-1, sqrt(2))
 quietly summarize x, detail
 return scalar median = r(p50)
end
findmedian
display r(median)
set seed 6219
simulate xmedian=r(median), reps(5000): findmedian
summarize, detail

// c.
clear all
program findMeanForExp, rclass
 drop _all
 set obs 100
 gen x = rnormal(-1, sqrt(2))
 gen y = exp(x)
 quietly summarize y, detail
 return scalar mean = r(mean)
end
set seed 6219
simulate ymean=r(mean), reps(5000): findMeanForExp
summarize, detail
clear all
program findMedianForExp, rclass
 drop _all
 set obs 100
 gen x = rnormal(-1, sqrt(2))
 gen y = exp(x)
 quietly summarize y, detail
 return scalar median = r(p50)
end
set seed 6219
simulate ymedian=r(median), reps(5000): findMedianForExp
summarize, detail

// Question 3

// a.
clear all
use SPShiller.dta
gen time=tm(1871m1)+_n-1
format time %tm
tsset time
describe
regress var1 L.var1 if tin(1953m4, 2013m12)
regress D.var1 L.var1 if tin(1953m4, 2013m12)

// b.
clear all
freduse GS10
describe
tsmktim time, start(1953m4)
tsset time
describe
regress GS10 L(1/3).GS10 if tin(1953m4, 2013m12)
regress D.GS10 L(1/3).GS10 if tin(1953m4, 2013m12)

// c.
program findrsq, rclass
 drop _all
 set obs 100
 gen time= _n
 tsset time
 gen y = rnormal(0,1)
 quietly regress y L.y
 return scalar rsq = e(r2)
 quietly regress D.y L.y
 return scalar rsqdiff = e(r2)
end
set seed 6219
simulate r2=r(rsq) r2diff=r(rsqdiff), reps(1000) nodots: findrsq
summarize