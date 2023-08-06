/*
Historical Periods
 
Here, I construct the historical peridos used in the Descriptives section.
This classification is based on Table B.1. in the Appendix of the paper.
*/

quietly{

cap gen period=""

							** Historical Periods **
							
*1. Gold Standard
cap gen p1=0

replace p1=1 if iso=="AUS" & year<=1915 & year>=1870
replace p1=1 if iso=="BEL" & year<=1914 & year>=1878
replace p1=1 if iso=="CAN" & year<=1914 & year>=1870
replace p1=1 if iso=="DNK" & year<=1917 & year>=1876
replace p1=1 if iso=="FIN" & year<=1914 & year>=1877
replace p1=1 if iso=="FRA" & year<=1914 & year>=1878
replace p1=1 if iso=="DEU" & year<=1914 & year>=1871
replace p1=1 if iso=="IRL" & year<=1914 & year>=1880
replace p1=1 if iso=="ITA" & year<=1917 & year>=1884
replace p1=1 if iso=="JPN" & year<=1917 & year>=1897
replace p1=1 if iso=="NLD" & year<=1914 & year>=1875
replace p1=1 if iso=="NOR" & year<=1914 & year>=1875
replace p1=1 if iso=="PRT" & year<=1891 & year>=1870
*replace p1=0 if iso=="ESP"
replace p1=1 if iso=="SWE" & year<=1914 & year>=1873
replace p1=1 if iso=="CHE" & year<=1914 & year>=1878
replace p1=1 if iso=="GBR" & year<=1914 & year>=1870
replace p1=1 if iso=="USA" & year<=1917 & year>=1880

replace period="1. Gold Standard" if p1==1


*World War Periods
cap gen pwar=0
replace pwar=1 if war == 1
replace period="War Period" if pwar==1


*2. Interwar Period
cap gen p2=0
replace p2=1 if year<=1938 & year>=1919
replace period="2. Interwar Period" if p2==1


*3. Bretton Woods
cap gen p3=0
replace p3=1 if iso=="AUS" & year<=1971 & year>=1949
replace p3=1 if iso=="BEL" & year<=1971 & year>=1946
replace p3=1 if iso=="CAN" & ((year<=1950 & year>=1946) | (year<=1971 & year>=1962))
replace p3=1 if iso=="DNK" & year<=1971 & year>=1946
replace p3=1 if iso=="FIN" & year<=1971 & year>=1948
replace p3=1 if iso=="FRA" & year<=1971 & year>=1946
replace p3=1 if iso=="DEU" & year<=1971 & year>=1952
replace p3=1 if iso=="IRL" & year<=1971 & year>=1957
replace p3=1 if iso=="ITA" & year<=1971 & year>=1947
replace p3=1 if iso=="JPN" & year<=1971 & year>=1952
replace p3=1 if iso=="NLD" & year<=1971 & year>=1946 
replace p3=1 if iso=="NOR" & year<=1971 & year>=1946
replace p3=1 if iso=="PRT" & year<=1971 & year>=1961
replace p3=1 if iso=="ESP" & year<=1971 & year>=1958
replace p3=1 if iso=="SWE" & year<=1971 & year>=1951
replace p3=1 if iso=="CHE" & year<=1971 & year>=1946
replace p3=1 if iso=="GBR" & year<=1971 & year>=1946
replace p3=1 if iso=="USA" & year<=1971 & year>=1946
replace period="3. Bretton Woods" if p3==1




*5. Inflation Targeting (Implicit)
cap gen p5=0
replace p5=1 if iso=="AUS" & year>=1993
replace p5=1 if iso=="BEL" & year>=1990
replace p5=1 if iso=="CAN" & year>=1991
replace p5=1 if iso=="DNK" & year>=1986
replace p5=1 if iso=="FIN" & year>=1995
replace p5=1 if iso=="FRA" & year>=1986
replace p5=1 if iso=="DEU" & year>=1986
replace p5=1 if iso=="IRL" & year>=1986
replace p5=1 if iso=="ITA" & year>=1986
replace p5=1 if iso=="JPN" & year>=1987
replace p5=1 if iso=="NLD" & year>=1986
replace p5=1 if iso=="NOR" & year>=1990
replace p5=1 if iso=="PRT" & year>=1992
replace p5=1 if iso=="ESP" & year>=1990
replace p5=1 if iso=="SWE" & year>=1991
replace p5=1 if iso=="CHE" & year>=1986
replace p5=1 if iso=="GBR" & year>=1991
replace p5=1 if iso=="USA" & year>=1988
replace period="5. Inflation Targeting" if p5==1


*5. Inflation Targeting (Explicit)
*cap gen p5=0
*replace p5=1 if iso=="AUS" & year>=1993
*replace p5=1 if iso=="CAN" & year>=1991
*replace p5=1 if iso=="JPN" & year>=2012
*replace p5=1 if iso=="NOR" & year>=2001
*replace p5=1 if iso=="SWE" & year>=1993
*replace p5=1 if iso=="GBR" & year>=1992
*replace p5=1 if iso=="USA" & year>=2012
*replace period="5. Inflation Targeting" if p5==1


*Period 4: Managed Float
cap gen p4=0
replace p4=1 if p1==0 & p2==0 & p3==0 & p5==0 & pwar==0
replace period="4. Managed Float" if p4==1

*In between period (between Gold Standard and Inflation Targeting excluding War Periods)
cap gen p6=0
replace p6=1 if p4==1 | p3==1


							** Labelling **
							
label var period "Historical Period"
label var p1 "Gold Standard" 
label var p2 "Interwar Period"
label var p3 "Bretton Woods"
label var p4 "Managed Float"
label var p5 "Inflation Targeting"
label var p6 "In Between Period"
label var pwar "War Period"

}
