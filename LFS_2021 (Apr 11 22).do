cd "D:\Desktop\ECON5600\PROC A\Data"

*Import LFS 2021 Datast into Stata
import excel "D:\Desktop\PROC A\Data\2021 LFS.xlsx", sheet("2021 LFS") firstrow

*Data cleaning/ manipulation
drop if REC_NUM ==.
drop if FTPTMAIN==.
drop if HRLYEARN==.

ssc install oaxaca, replace

generate hrlywage = HRLYEARN/100
generate hours = UTOTHRS/10
generate average_weekly_wage = hrlywage*hours
generate lnwage = log(average_weekly_wage)

generate city_size = 0 if CMA == 0
replace city_size=1 if (CMA==1 | CMA==2 | CMA==3 | CMA==4 | CMA==5 | CMA==6 | CMA==7 | CMA==8 | CMA==9)


********************************************
**********Generate dummy variables**********
********************************************

** Age **
gen age15to19=(AGE_12==1)
gen age20to24=(AGE_12==2)
gen age25to29=(AGE_12==3)
gen age30to34=(AGE_12==4)
gen age35to39=(AGE_12==5)
gen age40to44=(AGE_12==6)
gen age45to49=(AGE_12==7)
gen age50to54=(AGE_12==8)
gen age55to59=(AGE_12==9)
gen age60to64=(AGE_12==10)
gen age65to69=(AGE_12==11)
gen age70plus=(AGE_12==12)

** Gender **
gen male=(SEX==1)

** Marital Status **
gen married=(MARSTAT==1)
gen commonlaw=(MARSTAT==2)
gen widow=(MARSTAT==3)
gen separated=(MARSTAT==4)
gen divorced=(MARSTAT==5)
gen single=(MARSTAT==6)

** Education **
gen grade0to8=(EDUC==0)
gen somehighschool=(EDUC==1)
gen highschoolgrad=(EDUC==2)
gen somepostsecondary=(EDUC==3)
gen postsecondarygrad=(EDUC==4)
gen bachdegree=(EDUC==5)
gen abovebach=(EDUC==6)

** Immigrant Status **
gen immigrant_less10=(IMMIG==1)
gen immigrant_more10=(IMMIG==2)
gen nonimmigrant=(IMMIG==3)

** Full- and Part-Time **
gen fulltime=(FTPTMAIN==1)
gen parttime=(FTPTMAIN==2)

****************************************
******** add population weights ********
****************************************
svyset [pweight=FINALWT]


****************************************
********* What is r-squared TEST *******
****************************************
svy: reg lnwage i.age15to19 i.age20to24 i.age25to29 i.age30to34 i.age35to39 i.age40to44 i.age45to49 i.age50to54 i.age55to59 i.age60to64 i.age65to69 i.age70plus i.married i.commonlaw i.widow i.separated i.divorced i.single i.grade0to8 i.somehighschool i.highschoolgrad i.somepostsecondary i.postsecondarygrad i.bachdegree i.abovebach i.immigrant_less10 i.immigrant_more10 i.nonimmigrant i.fulltime i.parttime i.city_size i.male

*****************************************
******* MALES - OLS Regressions *********
*****************************************
preserve

keep if SEX == 1

svy: reg lnwage i.age15to19 i.age20to24 i.age25to29 i.age30to34 i.age35to39 i.age40to44 i.age45to49 i.age50to54 i.age55to59 i.age60to64 i.age65to69 i.age70plus i.married i.commonlaw i.widow i.separated i.divorced i.single i.grade0to8 i.somehighschool i.highschoolgrad i.somepostsecondary i.postsecondarygrad i.bachdegree i.abovebach i.immigrant_less10 i.immigrant_more10 i.nonimmigrant i.fulltime i.parttime i.city_size

restore 

*****************************************
****** FEMALES - OLS Regressions ********
*****************************************
preserve

keep if SEX == 2

svy: reg lnwage i.age15to19 i.age20to24 i.age25to29 i.age30to34 i.age35to39 i.age40to44 i.age45to49 i.age50to54 i.age55to59 i.age60to64 i.age65to69 i.age70plus i.married i.commonlaw i.widow i.separated i.divorced i.single i.grade0to8 i.somehighschool i.highschoolgrad i.somepostsecondary i.postsecondarygrad i.bachdegree i.abovebach i.immigrant_less10 i.immigrant_more10 i.nonimmigrant i.fulltime i.parttime i.city_size

restore 

*****************************************
********** Oaxaca Decomposition *********
*****************************************
**three-fold
oaxaca lnwage AGE_12 MARSTAT EDUC IMMIG FTPTMAIN city_size, by(SEX) threefold(reverse)

**two_fold
oaxaca lnwage AGE_12 MARSTAT EDUC IMMIG FTPTMAIN city_size, by(SEX) pooled svy
