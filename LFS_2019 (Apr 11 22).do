**LFS 2019**
cd "D:\Desktop\PROC A\Data\2019"


forvalues i = 1 / 2 {
	clear
	import delimited `i'.csv
	save `i'.dta, replace
}

forvalues i = 1/2 {
	append using `i'.dta
}

drop if rec_num ==.
drop if hrlyearn ==.
drop if ftptmain ==.

ssc install oaxaca, replace

generate hrlywage = hrlyearn/100
generate hours = utothrs/10
generate average_weekly_wage = hrlywage*hours
generate lnwage = log(average_weekly_wage)

generate city_size = 0 if cma == 0
replace city_size=1 if (cma==1 | cma==2 | cma==3 | cma==4)



********************************************
**********Generate dummy variables**********
********************************************

** Age **

gen age15to19=(age_12==1)
gen age20to24=(age_12==2)
gen age25to29=(age_12==3)
gen age30to34=(age_12==4)
gen age35to39=(age_12==5)
gen age40to44=(age_12==6)
gen age45to49=(age_12==7)
gen age50to54=(age_12==8)
gen age55to59=(age_12==9)
gen age60to64=(age_12==10)
gen age65to69=(age_12==11)
gen age70plus=(age_12==12)

** Gender **
gen male=(sex==1)

** Marital Status **
gen married=(marstat==1)
gen commonlaw=(marstat==2)
gen widow=(marstat==3)
gen separated=(marstat==4)
gen divorced=(marstat==5)
gen single=(marstat==6)

** Education **
gen grade0to8=(educ==0)
gen somehighschool=(educ==1)
gen highschoolgrad=(educ==2)
gen somepostsecondary=(educ==3)
gen postsecondarygrad=(educ==4)
gen bachdegree=(educ==5)
gen abovebach=(educ==6)

** Immigrant Status **
gen immigrant_less10=(immig==1)
gen immigrant_more10=(immig==2)
gen nonimmigrant=(immig==3)

** Full- and Part-Time **
gen fulltime=(ftptmain==1)
gen parttime=(ftptmain==2)



****************************************
******** add population weights ********

svyset [pweight=finalwt]


*****************************************
********* What is r-squared TEST ********
*****************************************

svy: reg lnwage i.age15to19 i.age20to24 i.age25to29 i.age30to34 i.age35to39 i.age40to44 i.age45to49 i.age50to54 i.age55to59 i.age60to64 i.age65to69 i.age70plus i.married i.commonlaw i.widow i.separated i.divorced i.single i.grade0to8 i.somehighschool i.highschoolgrad i.somepostsecondary i.postsecondarygrad i.bachdegree i.abovebach i.immigrant_less10 i.immigrant_more10 i.nonimmigrant i.fulltime i.parttime i.city_size i.male



*****************************************
******* MALES - OLS Regressions *********
*****************************************

preserve

keep if sex == 1

svy: reg lnwage i.age15to19 i.age20to24 i.age25to29 i.age30to34 i.age35to39 i.age40to44 i.age45to49 i.age50to54 i.age55to59 i.age60to64 i.age65to69 i.age70plus i.married i.commonlaw i.widow i.separated i.divorced i.single i.grade0to8 i.somehighschool i.highschoolgrad i.somepostsecondary i.postsecondarygrad i.bachdegree i.abovebach i.immigrant_less10 i.immigrant_more10 i.nonimmigrant i.fulltime i.parttime i.city_size

restore 


*****************************************
****** FEMALES - OLS Regressions ********
*****************************************

preserve

keep if sex == 2

svy: reg lnwage i.age15to19 i.age20to24 i.age25to29 i.age30to34 i.age35to39 i.age40to44 i.age45to49 i.age50to54 i.age55to59 i.age60to64 i.age65to69 i.age70plus i.married i.commonlaw i.widow i.separated i.divorced i.single i.grade0to8 i.somehighschool i.highschoolgrad i.somepostsecondary i.postsecondarygrad i.bachdegree i.abovebach i.immigrant_less10 i.immigrant_more10 i.nonimmigrant i.fulltime i.parttime i.city_size

restore 


*****************************************
********** Oaxaca Decomposition *********
*****************************************


oaxaca lnwage age_12 marstat educ immig ftptmain city_size, by(sex) pooled svy

oaxaca lnwage age_12 marstat educ immig ftptmain city_size, by(sex) noisily