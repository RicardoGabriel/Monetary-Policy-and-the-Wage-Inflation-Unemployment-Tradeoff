/*
trilemma_iv.do

Here, I follow the code from Jordà, Schularick, and Taylor (2020) JME 
to re-construct the trilemma instrument until 2020.
*/ 

quietly{

**************************************************************************
* CONSTRUCT THE INSTRUMENTAL VARIABLE 
**************************************************************************
	
* extended Ireland capital openess variable (assume from 1960 onwards same capital openess as the UK) - waiting on data from Dennis Quinn to confirm this
* extend dataset until 2020 (according to their classification all countries in this dataset are today with capital openess = 100)
replace openquinn = 100 if year >2012


********* MAKE BASE INTEREST RATE DATA

* collect ibase data for DEU/USA

preserve
keep iso dateq stir
keep if iso=="USA"
keep dateq stir
rename stir stir_usa
sort dateq
save ../Data/stir_usa.dta, replace
restore

preserve
keep iso dateq stir
keep if iso=="DEU"
keep dateq stir
rename stir stir_deu
sort dateq
save ../Data/stir_deu.dta, replace
restore


cap drop _merge
sort dateq
merge m:1 dateq using ../Data/stir_usa.dta // JST us rate
drop _merge
sort dateq
merge m:1 dateq using ../Data/stir_deu.dta // JST deu rate
drop _merge
xtset id dateq

*erase ../Data/stir_usa.dta
*erase ../Data/stir_deu.dta

********** 1. Make IV using the raw change in the base country interest rate
********** IV dibpeg = dibase*peg 

* force sort tsset again
xtset id dateq, quarter

* use base coding from JST dataset
capture drop dibase
gen      dibase = .
replace  dibase = d.stir_usa   if peg_base=="USA"
replace  dibase = d.stir_deu   if peg_base=="DEU"


* IV is impulse to short rate due to change in base when pegged in year T and T-1
capture drop dibpeg
gen     dibpeg = dibase * peg * l.peg  
replace dibpeg = dibpeg * (openquinn/100)  // scale by quinn capital openness
replace dibpeg = . if peg==0 | l.peg==0



********** 2. Make IV using the residualized change in the base country interest rate
********** IV dibpegF = dibaseF*peg (without R&R forecast for base countries - here it is about peg regimes)

**************************************************************************
******** CONSTRUCT THE INSTRUMENTAL VARIABLE                      ********
********  USING TAYLOR RULE RESIDS OR FACTOR AUGMENTATION         ********
**************************************************************************

* force sort tsset again
xtset id dateq, quarter
estimates clear						

* forecasting equation = regressor list uses 4 lags of RHS (reduced version from
*  yearly data) - l.dlrcon l.dltrate l.dstir l.dlrgdp l.dlcpi l.dlriy l.cay
local rhsstirF L(1/4).dlrgdp L(1/4).dstir L(1/4).dlcpi

cap drop dstir_hat
gen dstir_hat =.

* forecast stir
xtreg d.stir `rhsstirF' i.quarter if (iso=="DEU"|iso=="USA"), fe
cap drop temp
predict temp if (iso=="DEU"|iso=="USA")
replace dstir_hat = temp if (iso=="DEU"|iso=="USA")

* make the residualized change in stir that will be the basis for the IV
cap drop dstir_resid
gen dstir_resid = d.stir - dstir_hat

* copy into new series
cap drop dibaseF_usa dibaseF_gbr dibaseF_deu dibaseF_fra
gen dibaseF_usa = dstir_resid if iso=="USA"  // dibase for new IV
gen dibaseF_deu = dstir_resid if iso=="DEU"  // dibase for new IV


cap drop temp
bysort dateq: egen temp = mean(dibaseF_usa)
replace dibaseF_usa = temp
cap drop temp
bysort dateq: egen temp = mean(dibaseF_deu)
replace dibaseF_deu = temp
drop temp


* make the IV, same as standard trilemma IV (use composite GBR-USA-FRA for interwar)
xtset id dateq


* use base coding from JST dataset and replicate hybrid construction of OST
cap drop dibaseF
gen      dibaseF = .
replace  dibaseF = dibaseF_usa   if peg_base=="USA"
replace  dibaseF = dibaseF_deu   if peg_base=="DEU"


*****************
* impulse to short rate due to change in base when pegged in year T and T-1
cap drop dibpegF
gen      dibpegF = .
replace  dibpegF = dibaseF * peg * l.peg  
replace  dibpegF = dibpegF * (openquinn/100)  // scale by quinn capital openness
replace  dibpegF = . if peg==0 | l.peg==0

* replace original JST estimates by these new ones
gen JSTtrilemmaIV 	= dibpeg
gen JSTtrilemmaIV_R = dibpegF
label var JSTtrilemmaIV   "JST trilemma instrument (raw base rate changes)"
label var JSTtrilemmaIV_R  "JST trilemma instrument (residualized base rate changes)"


*****************
*  save trilemma IVs in their own file
preserve
keep      dateq iso JSTtrilemmaIV JSTtrilemmaIV_R peg peg_type peg_base
order     dateq iso JSTtrilemmaIV JSTtrilemmaIV_R peg peg_type peg_base
label var peg_type "Peg type: BASE, PEG, or FLOAT"
label var peg_base "Peg base: GBR, USA, or DEU"
sort iso dateq
save  ../Data/JSTtrilemmaIV2_Quarter.dta , replace
restore
}
