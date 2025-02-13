clear all

ssc install binscatter
ssc install rddensity
ssc install lpdensity
ssc install ivreg2
ssc install rdrobust
net install rdmulti, from("https://raw.githubusercontent.com/rdpackages/rdmulti/master/stata") replace
 ssc install rd
ssc install cmogram
ssc install boottest

*import spss using "C:\Users\calvi\Downloads\MARS Wave 1 Production_V2_Calvin", case(lower)
*import spss using "C:\Users\calvi\Downloads\MARS Wave 1 - 2018 Dataset_CalvinCheng.sav"
*import spss using "C:\Users\calvi\OneDrive\Documents\MARSjoin.sav", case(lower)
import spss using "C:\Users\calvi\OneDrive\Documents\MARS1-2018_2019 Data_V3_Calvin.sav", case(lower)


*create retirement variables
gen retired=0
replace retired = 1 if d101==5
**if listed retirement year and currently not working for pay

gen retired2=0
gen nosalary=0
replace nosalary = 1 if e102_1_s_1!=3 &  e102_1_s_2!=3 &  e102_1_s_3!=3
replace retired2 =1 if d101new==5 & nosalary==1
*if no drawn salary and retired

gen retired3=0
replace retired3=1 if d101==5 & d132_1a!=6
*if no drawn salary and retired

gen retired_notforced=0
replace retired_notforced =1 if d101==5 & d133!=2

gen retired_forced=.
replace retired_forced =1 if d133==2
replace retired_forced =0 if d133==1 | d133==3

gen retired_volun=.
replace retired_volun =1 if d133==1
replace retired_volun =0 if d133==2 | d133==3

gen retired_volun3=0
replace retired_volun3 =1 if d133==1 | d133==2

gen retired_forced2=0
replace retired_forced2 =1 if d133==3 | d133==2




egen money_rec_child = rowtotal(b104b_1_a_1 b104b_1_a_2 b104b_1_a_3 b104b_1_a_4 b104b_1_a_5 b104b_1_a_6 b104b_1_a_7 b104b_1_a_8 b104b_1_a_9 b104b_1_a_10)

egen money_rec_parent = rowtotal(b203b_1_a_1 b203b_1_a_2 b203b_1_a_3 b203b_1_a_4)

egen money_rec_sib = rowtotal(b304b_1_a_1 b304b_1_a_2 b304b_1_a_3 b304b_1_a_4 b304b_1_a_5 b304b_1_a_6 b304b_1_a_7 b304b_1_a_8 b304b_1_a_9 b304b_1_a_10)

gen retired_nosupport = 0f
replace retired_nosupport =1 if d101==5 & money_rec_child<1 & money_rec_parent<1 & money_rec_sib<1 | d101==5 & money_rec_child==. & money_rec_parent==. & money_rec_sib==. | d101==5 & money_rec_child<1 & money_rec_parent==. & money_rec_sib==. | d101==5 & money_rec_child==. & money_rec_parent<1 & money_rec_sib==. | d101==5 & money_rec_child==. & money_rec_parent==. & money_rec_sib<1 | d101==5 & money_rec_child<1 & money_rec_parent<1 & money_rec_sib==. | d101==5 & money_rec_child==. & money_rec_parent<1 & money_rec_sib<1 | d101==5 & money_rec_child<1 & money_rec_parent==. & money_rec_sib<1

gen nosupport = 0
replace retired_nosupport =1 if money_rec_child<1 & money_rec_parent<1 & money_rec_sib<1 | d101==5 & money_rec_child==. & money_rec_parent==. & money_rec_sib==. | d101==5 & money_rec_child<1 & money_rec_parent==. & money_rec_sib==. | d101==5 & money_rec_child==. & money_rec_parent<1 & money_rec_sib==. | d101==5 & money_rec_child==. & money_rec_parent==. & money_rec_sib<1 | d101==5 & money_rec_child<1 & money_rec_parent<1 & money_rec_sib==. | d101==5 & money_rec_child==. & money_rec_parent<1 & money_rec_sib<1 | d101==5 & money_rec_child<1 & money_rec_parent==. & money_rec_sib<1

gen retireage=.
replace retireage= hhlage-(2018-d101d_2)

gen hhlagesq=hhlage^2
gen hhlage3=hhlage^3
gen hhlage4=hhlage^4


*create Educ years variable
gen educ=0
replace educ=1 if a205==2
replace educ=2 if a205==3
replace educ=6 if a205==4
replace educ=9 if a205==5
replace educ=11 if a205==6
replace educ=12 if a205==7 | a205==8
replace educ=15 if a205==9
replace educ=17 if a205==10

*create wellbeing indictor
gen c301all = c301d+c301g+c301o+c301p+c301q+c301r+c301s+c301t-c301a-c301b-c301c-c301e-c301h-c301i-c301j-c301k-c301l-c301n 

egen std301 = std(c301all)

gen c3015 = c301all -c305a -c305b -c305c-c305e +c305f +c305g +c305h +c305i +c305j +c305k +c305l +c305m+c305n+c305o

egen std3015 = std(c3015)

recode hhlgender (1=0) (5=1), generate(gender2)

*create other wellbeing and health indicators


recode c301c (1=5) (2=4) (3=3) (4=2) (5=1), generate(depressed)

recode c301e (1=5) (2=4) (3=3) (4=2) (5=1), generate(stress)

recode c301b (1=5) (2=4) (3=3) (4=2) (5=1), generate(troublecon)

recode c301l (1=5) (2=4) (3=3) (4=2) (5=1), generate(isolation)


gen mentalwb = stress + depressed
replace mentalwb = mentalwb/2

gen mentalwb2 = stress+depress+isolation+troublecon +c301d +c301g
replace mentalwb2 = mentalwb2/6

gen socialwb = c306b + c306d + c306h + c306n + c306r + c306q + c306m
replace socialwb = socialwb/7

gen socialwb2 = c306a + c306b + c306f + c306i + c306o + c306p 
replace socialwb2 = socialwb2/6

gen totalwb = stress + depressed + c306b + c306d + c306h + c306n + c306r + c306q + c306m
replace totalwb = totalwb/9

gen totalwb2 = troublecon + isolation + stress + depressed +c301d +c301g + c306b + c306d + c306h + c306n + c306r + c306q + c306m
replace totalwb2 = totalwb2/13

gen totalwb3 = troublecon + stress + depressed + isolation +c301d +c301g + c306a + c306b + c306f + c306i + c306o + c306p 
replace totalwb3 = totalwb3/12

gen totalwb4 = socialwb2 + mentalwb2 
replace totalwb4 = totalwb4/2

*gen illnessess
gen i1 = 0 
replace i1 =1 if c104a_1_s_1!=0
gen i2 = 0
replace i2 = 1 if c104a_1_s_2!=0 & c104a_1_s_2!=.
gen i3 = 0 
replace i3 = 1 if c104a_1_s_3!=0 & c104a_1_s_3!=.
gen i4 = 0 
replace i4 = 1 if c104a_1_s_4!=0 & c104a_1_s_4!=.
gen i5 = 0 
replace i5 = 1 if c104a_1_s_5!=0 & c104a_1_s_5!=.
gen i6 = 0 
replace i6 = 1 if c104a_1_s_6!=0 & c104a_1_s_6!=.
gen i7 = 0 
replace i7 = 1 if c104a_1_s_7!=0 & c104a_1_s_7!=.
gen i8 = 0 
replace i8 = 1 if c104a_1_s_8!=0 & c104a_1_s_8!=.
gen i9 = 0 
replace i9 = 1 if c104a_1_s_9!=0 & c104a_1_s_9!=.
egen illnesses = rowtotal(i1 i2 i3 i4 i5 i6 i7 i8 i9)


*generate assignment variables
gen past60=0
replace past60=1 if hhlage>=60

gen past55=0
replace past55=1 if hhlage>=55

gen past54=0
replace past54=1 if hhlage>=54

gen past56=0
replace past56=1 if hhlage>=56

*gen (x-55) CENTERING VARIABLES
gen stdage=hhlage-55
gen stdagesq=(stdage-55)^2
gen stdage3=(stdage-55)^3

gen stdpast55std=0
replace stdpast55=1 if stdage>=0
gen stdpast54std=0
replace stdpast54=1 if hhlage-54
gen stdpast56std=0
replace stdpast56=1 if hhlage-56
gen stdpast60std=0
replace stdpast60=1 if hhlage-60

gen int55age = past55 * hhlage
gen int55agesq = past55 * hhlagesq
gen int55age3 = past55 * hhlage3

gen stdint55age = stdage*(stdage>=0)
gen stdint55agesq = stdagesq*(stdage>=0)
gen stdint55age3 = stdage3*(stdage>=0)


gen int56age = past56 * hhlage
gen int56agesq = past56 * hhlagesq
gen int56age3 = past56 * hhlage3



*generate pension variable
gen pen=0
replace pen=1 if e102_1_s_1==1|e102_1_s_2==1|e102_1_s_3==1|e102_1_s_4==1|e102_1_s_5==1|e102_1_s_6==1|e102_1_s_7==1|e102_1_s_8==1|e102_1_s_9==1|e102_1_s_10==1|e102_1_s_11==1

gen pen1=0
replace pen1=1 if e102_1_s_1==1|e102_1_s_2==1|e102_1_s_3==1|e102_1_s_4==1|e102_1_s_5==1|e102_1_s_6==1|e102_1_s_7==1|e102_1_s_8==1|e102_1_s_9==1|e102_1_s_10==1|e102_1_s_11==1|e103_a_1!=.
*includes people who have said no to receiving pension but reported pension income

*generate income, assets, wealth variable
egen annincome = rowtotal(e103_a_1 e103_a_2 e103_a_3 e103_a_4 e103_a_5 e103_a_6 e103_a_7 e103_a_8 e103_a_9 e103_a_10 e103_a_11)

egen assets = rowtotal(f105b_a_1 f105b_a_2 f105b_a_3 f105b_a_4 f105b_a_5 f105b_a_6)

egen savings = rowtotal(f104b_a_1 f104b_a_2 f104b_a_3 f104b_a_4 f104b_a_5 f104b_a_6 f104b_a_7 f104b_a_8 f104b_a_9)

gen wealth = assets + savings

*married
gen married = 0
replace married = 1 if a204_1==2

gen socialasst=0
replace socialasst =1 if e102_1_s_1 == 5 | e102_1_s_1 == 6 | e102_1_s_1 == 7| e102_1_s_1 ==9| e102_1_s_1 ==10 | e102_1_s_2 == 5 | e102_1_s_2 == 6 | e102_1_s_2 == 7| e102_1_s_2 ==9| e102_1_s_2 ==10 | e102_1_s_3 == 5 | e102_1_s_3 == 6 | e102_1_s_3 == 7| e102_1_s_3 ==9| e102_1_s_3 ==10 | e102_1_s_4 == 5 | e102_1_s_4 == 6 | e102_1_s_4 == 7| e102_1_s_4 ==9| e102_1_s_4 ==10



***==============================================================
***FIRST STAGE AND OTHERS
***==============================================================

*first stage (hhlage and retired)
binscatter retired hhlage if hhlage<=85, discrete linetype(qfit) rd(55) ytitle("Retirement") xtitle("Age") reportreg
binscatter retired hhlage if hhlage<=85 & married==1, discrete linetype(qfit) rd(54) ytitle("Retirement") xtitle("Age") 

rdplot retired2 hhlage if hhlage<=85 , c(55) h() kernel(uni) p(2) graph_options(title(First stage: Retirement on age at discontinuity 55)) 

rdplot retired hhlage if hhlage<=85, c(56) h() kernel(uni) p(2) genvars(rdplot_mean_x)

reg retired3 hhlage hhlagesq int55age int55agesq past55
reg retired3 hhlage int55age past55

reg retired hhlage hhlagesq int55age int55agesq past56

*structural outcomes/reduced (c301 hhlage)



binscatter socialwb hhlage if hhlage<=85, linetype(qfit) rd(54) discrete

binscatter socialwb2 hhlage if hhlage<=85, linetype(qfit) rd(54) discrete ytitle("Social wellbeing") xtitle("Age")

binscatter mentalwb2 hhlage if hhlage<=85, linetype(lfit) rd(54) discrete ytitle("Mental wellbeing") xtitle("Age")

binscatter totalwb3 hhlage if hhlage<=85, linetype(qfit) rd(54) discrete ytitle("Total wellbeing") xtitle("Age")

*=======================
*REGRESSIONS


*try splines 
mkspline splinevar = hhlage, cubic nknots(4) knots(50 55 60 65)
ivregress 2sls totalwb splinevar1 splinevar2 splinevar3 (retired=past55), vce(cluster hhid)

mkspline splinebelow 55 splineabove 60 splineage = hhlage
ivregress 2sls totalwb splinebelow splineabove splineage (retired=past55), vce(cluster hhid)


*===============================================================================
*===SECOND TRY==================================================================
*===============================================================================

*New 6
*1. poly (1), no covs
*2. poly (2), covs
*3. poly (1,2) covs
*4. poly (2,2) covs
*5. non-parametric
*6. non-parametric h(5 15)

**poly= (1), covs = no, split = no
est clear
eststo: ivregress 2sls totalwb2 stdage (retired=past55) if hhlage<=80, vce(cluster hhlage) 
eststo: ivregress 2sls mentalwb2 stdage (retired=past55) if hhlage<=80, vce(cluster hhlage)
eststo: ivregress 2sls socialwb stdage (retired=past55) if hhlage<=80, vce(cluster hhlage)

**poly= (2), covs = yes, split = no

eststo: ivregress 2sls totalwb2 stdage stdagesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage) 
eststo: ivregress 2sls mentalwb2 hhlage  hhlagesq educ hhlgender illnesses a200b  (retired=past55) if hhlage<=80, vce(cluster hhlage)
eststo: ivregress 2sls socialwb hhlage hhlagesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage)
esttab, se star(* 0.10 ** 0.05 *** 0.01)


**poly= (1 2), covs = yes, split = yes
est clear

eststo: ivregress 2sls totalwb2 stdage stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage) 
eststo: ivregress 2sls mentalwb2 stdage stdint55age stdint55agesq educ hhlgender illnesses a200b  (retired=past55) if hhlage<=80, vce(cluster hhlage)
eststo: ivregress 2sls socialwb stdage stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage)

**poly = (2 2), covs = yes, split = yes

eststo: ivregress 2sls totalwb2 stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage) 
eststo: ivregress 2sls mentalwb2 stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b  (retired=past55) if hhlage<=80, vce(cluster hhlage)
eststo: ivregress 2sls socialwb stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage)

esttab, se star(* 0.10 ** 0.05 *** 0.01)

*non-parametric

cmogram socialwb2 hhlage, cut(55) scatter line(55) qfit

est clear

eststo: rdrobust totalwb2 stdage, c(0) fuzzy(retired) p(1) covs(educ hhlgender illnesses married a200b) 

eststo: rdrobust mentalwb2 stdage, c(0) fuzzy(retired) p(1) covs(educ hhlgender illnesses married a200b) 

eststo: rdrobust socialwb hhlage, c(55) fuzzy(retired) p(1) covs(educ hhlgender illnesses married a200b) 

*full sample

eststo: ivregress 2sls totalwb2 stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55), vce(cluster hhlage) 
eststo: ivregress 2sls mentalwb2 stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b  (retired=past55), vce(cluster hhlage)
eststo: ivregress 2sls socialwb stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55), vce(cluster hhlage)


esttab, se star(* 0.10 ** 0.05 *** 0.01)

****======BOOTSTRAP SEs=========================
*Try bootstrap standard errors


*model 1 

ivregress 2sls totalwb2 stdage (retired=past55) if hhlage<=80, vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph
ivregress 2sls mentalwb2 stdage (retired=past55)  if hhlage<=80, vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph
ivregress 2sls socialwb stdage (retired=past55) if hhlage<=80, vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph

*model 2
ivregress 2sls totalwb2 stdage stdagesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph
ivregress 2sls mentalwb2 hhlage  hhlagesq educ hhlgender illnesses a200b  (retired=past55) if hhlage<=80, vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph
ivregress 2sls socialwb hhlage hhlagesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph



*model 3
ivregress 2sls totalwb2 stdage stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls mentalwb2 stdage stdint55age stdint55agesq educ hhlgender illnesses a200b  (retired=past55) if hhlage<=80, vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls socialwb stdage stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph



*model 4

ivregress 2sls totalwb2 stdage stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls totalwb2 stdage stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls totalwb2 stdage stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55) if hhlage<=80, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

*model 5

rdrobust totalwb2 stdage, c(0) fuzzy(retired) p(1) covs(educ hhlgender illnesses married a200b) 


rdrobust mentalwb2 stdage, c(0) fuzzy(retired) p(1) covs(educ hhlgender illnesses married a200b) 


rdrobust socialwb hhlage, c(55) fuzzy(retired) p(1) covs(educ hhlgender illnesses married a200b) 


*model 6
ivregress 2sls totalwb2 stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55), vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls mentalwb2 stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b  (retired=past55), vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls socialwb stdage stdagesq stdint55age stdint55agesq educ hhlgender illnesses a200b (retired=past55), vce(cluster hhlage)
boottest retired, bootcluster(hhlage) boot(wild) nograph

*=============================================================================
*============ROBUSTNESS======================
*no jumps on baseline (smooth)
binscatter educ hhlage, discrete rd(55) xtitle("Age") line(qfit) ytitle("Education")
binscatter c101 hhlage, discrete rd(55) xtitle("Age") line(qfit) ytitle("Health status (1-5)") 
binscatter b101 hhlage, discrete rd(55) xtitle("Age") line(qfit) ytitle("Number of children") 
binscatter illnesses hhlage, discrete rd(55) xtitle("Age") line(qfit) ytitle("Reported illnesses") 
binscatter hhlgender hhlage, discrete rd(55) xtitle("Age") line(qfit) ytitle("Reported gender") 
binscatter savings hhlage if wealth<5000000, discrete rd(55) line(qfit) xtitle("Age") ytitle("Savings") 


*FOR APPENDIX A
est clear
reg educ hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph

reg b101 hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph

reg illnesses hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph

reg hhlgender hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph

reg savings hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph

reg assets hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph

reg married hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph

reg a203_new hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph

reg a202_1 hhlage hhlagesq int55age int55agesq past55 if hhlage<=75, vce(cluster hhlage)
boottest past55, bootcluster(hhlage) boot(wild) nograph


esttab using apend1.tex, se star(* 0.10 ** 0.05 *** 0.01) keep(past55)
*religion a203_new
*married 
*ethnicity
*savings, assets, income


*Mccrary
kdensity hhlage

rddensity hhlage, c(55) plot plot_range(40 85) nohist 

*Placebos 

*placebo treatment
est clear

ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past54), vce(cluster hhid) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past56), vce(cluster hhid) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past60), vce(cluster hhid) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

esttab, se star(* 0.10 ** 0.05 *** 0.01)




***========DESCRIPTIVE STATS 

*table
est clear
eststo tot: quietly estpost summarize hhlage gender2 educ married a202_1 illnesses c101 b101 a200b savings totalwb2 socialwb mentalwb2
eststo reti: quietly estpost summarize hhlage gender2 educ married a202_1 illnesses c101 b101 a200b savings totalwb2 socialwb mentalwb2 if retired == 1
eststo notret: quietly estpost summarize hhlage gender2 educ married a202_1 illnesses c101 b101 a200b savings totalwb2 socialwb mentalwb2 if retired == 0
eststo diff: quietly estpost ttest hhlage gender2 educ married a202_1 illnesses c101 b101 a200b savings totalwb2 socialwb mentalwb2, by(retired) unequal
esttab tot reti notret diff, cells("mean(pattern(1 1 1 0) fmt(3)) sd(pattern(1 1 1 0)) b(star pattern(0 0 0 1) fmt(3))") label

*kernel dens

twoway kdensity hhlage, xline(55) || kdensity hhlage if retired ==1 || kdensity hhlage if retired ==0, xtitle("Age") ytitle("Kernel density")

kdensity hhlage, addplot(kdensity hhlage if retired ==1) addplot(kdensity hhlage if retired ==0)
kdensity hhlage if retired==0, addplot(kdensity hhlage if retired ==1)
kdensity totalwb2 if retired==0, addplot(kdensity totalwb if retired==1) 

twoway kdensity totalwb2|| kdensity mentalwb2|| kdensity socialwb, xtitle("Wellbeing (1-5)") ytitle("Kernel density")


*=======HET ANALYSIS

Life cycle


*Health
ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past55) if illnesses>1, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past55) if illnesses<1, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

*Financial security (assets)
ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past55) if assets>=100000, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph
ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past55) if assets<100000, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph

*Education
ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past55) if educ>=9, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph
ivregress 2sls totalwb2 hhlage hhlagesq int55age int55agesq educ hhlgender illnesses a200b (retired=past55) if educ<9, vce(cluster hhlage) 
boottest retired, bootcluster(hhlage) boot(wild) nograph


esttab using het2.tex, se star(* 0.10 ** 0.05 *** 0.01) keep(retired retired_volun retired_forced)

*Questions for Rui

Things to do:
1. change first stage and outcome graphs to centered


