/* 
Appending subsamples of Procurement data

This version: 
	Appends "names_Proc_0.dta" and "names_Proc_1.dta", which are the subsamples 
	for "batches==0" and "batches==1" respectively.
	January, 2018

Damian Romero
UPF	
	
*/

clear
set more off

* Set global directory
global path "/Users/damianromero/Dropbox/Research_Assistant/UPF/Julian_diGiovanni"

* Change directory
cd "$path/python/stata_version"

* Load "batches==0" database
use names_Proc_0, clear

* Append using "batches==1" database
append using names_Proc_1_alt, gen(source)

* Change name_clean format
format %100s name_clean

*===============================================================================
*-------------------------------------------------------------------------------
* Extra cleaning (based on merging patterns)
/* 
	Based on patterns analyzed after merging with BoS database, try to fix as 
	may observations as possible "manually". Iterate until convergence.
*/	
*-------------------------------------------------------------------------------

replace name_clean = regexr(name_clean,"^& ","")
replace name_clean = regexr(name_clean,"^- [A-Z]","")
replace name_clean = regexr(name_clean,"^- ","")
replace name_clean = regexr(name_clean,"^-[A-Z]","")
replace name_clean = regexr(name_clean,"^-","")
replace name_clean = regexr(name_clean,"^\.$","")
replace name_clean = regexr(name_clean,"^\.;$","")
replace name_clean = regexr(name_clean,"^\. ;L$","")
replace name_clean = regexr(name_clean,"^\.,$","")
replace name_clean = regexr(name_clean,"^\.,- ","")
replace name_clean = regexr(name_clean,"^\.,","")
replace name_clean = regexr(name_clean,"^\.- ","")
replace name_clean = regexr(name_clean,"^\.-","")
replace name_clean = regexr(name_clean,"^\.\. ","")
replace name_clean = regexr(name_clean,"^\.\., ","")
replace name_clean = regexr(name_clean,"^\.\.[0-9]+\) ","")
replace name_clean = regexr(name_clean,"^\.\.B[0-9]+\) ","")
replace name_clean = regexr(name_clean,"^\./ ","")
replace name_clean = regexr(name_clean,"^\.//","")
replace name_clean = regexr(name_clean,"^\./0[0-9]: ","")
replace name_clean = regexr(name_clean,"^\./","")
replace name_clean = regexr(name_clean,"^\.1-[A-Z]\. ","")
replace name_clean = regexr(name_clean,"^\.[0-9]+\. ","")
replace name_clean = regexr(name_clean,"^\.: [0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? ","")
replace name_clean = regexr(name_clean,"^\.: [0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? ","")
replace name_clean = regexr(name_clean,"^\.: [0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? ","")
replace name_clean = regexr(name_clean,"^\.: [0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? ","")
replace name_clean = regexr(name_clean,"^\.: [0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? ","")
replace name_clean = regexr(name_clean,"^\.: [0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? ","")
replace name_clean = regexr(name_clean,"^\.: [0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? ","")
replace name_clean = regexr(name_clean,"^\.: [0-9]+(\.|,)?[0-9]+(\.|,)? ","")
replace name_clean = regexr(name_clean,"^\.;$","")
replace name_clean = regexr(name_clean,"^\.;-$","")
replace name_clean = regexr(name_clean,"^\.B\.[0-9]+\) ","")
replace name_clean = regexr(name_clean,"^\.CONCURSO NUMERO A-[0-9]+/[0-9]+: ","")
replace name_clean = regexr(name_clean,"^\.CONCURSO A-[0-9]+/[0-9]+\. ","")
replace name_clean = regexr(name_clean,"^\.CONTRATISTA [0-9]+: ","")
replace name_clean = regexr(name_clean,"^\.[A-Z]$","")
replace name_clean = regexr(name_clean,"^[A-Z]$","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\.$","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\. \(","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\. (,|-|\.|:|;|/|Y)+ ","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\. (,|-|\.|:|;|/|Y)+","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\. [0-9](\.|\)) ","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\. ","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\.(,|-|\.|:|;|/) ","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\.(,|-|\.|:|;|/)","")
replace name_clean = regexr(name_clean,"^\.[A-Z]\.PARTIDA N\. [0-9]+: ","")
replace name_clean = regexr(name_clean,"^UR[0-9]+: ","")
g aux_ = regexs(0) if regexm(name_clean,"> [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+$")
replace name_clean = regexr(aux_,"> ","") if aux_!=""
drop aux_
g aux_ = regexs(0) if regexm(name_clean,"> [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+$")
replace name_clean = regexr(aux_,"> ","") if aux_!=""
drop aux_
g aux_ = regexs(0) if regexm(name_clean,"> [A-Z]+ [A-Z]+ [A-Z]+$")
replace name_clean = regexr(aux_,"> ","") if aux_!=""
drop aux_
g aux_ = regexs(0) if regexm(name_clean,"> [A-Z]+ [A-Z]+$")
replace name_clean = regexr(aux_,"> ","") if aux_!=""
drop aux_
g aux_ = regexs(0) if regexm(name_clean,"> [A-Z]+$")
replace name_clean = regexr(aux_,"> ","") if aux_!=""
drop aux_
replace name_clean = regexr(name_clean,"^/ ","")
replace name_clean = regexr(name_clean,"^/","")
replace name_clean = regexr(name_clean,"^/[0-9]+: ","")
replace name_clean = regexr(name_clean,"^/[0-9]+-[A-Z]+: ","")
replace name_clean = regexr(name_clean,"^/[0-9]+-[A-Z]+:","")
replace name_clean = regexr(name_clean,"^[0-9]+(\.|,)?[0-9]+ DE PESETAS ","")
replace name_clean = regexr(name_clean,"^[0-9]+(\.|,)?[0-9]+ DE PESETAS[\)]?(\.|,)? ","")
replace name_clean = regexr(name_clean,"^[0-9]+(:|;|,) ","")
replace name_clean = regexr(name_clean,"^[0-9]+$","")
replace name_clean = regexr(name_clean,"^[0-9]+ (,|-|/|:|;) ","")
replace name_clean = regexr(name_clean,"^[0-9]+ Y [0-9]+(\.|,|;|:|\|-)+ ","")
replace name_clean = regexr(name_clean,"^[0-9]+\) ","")
replace name_clean = regexr(name_clean,"^[0-9]+\) Y ","")
replace name_clean = regexr(name_clean,"^[0-9]+\)(\.|,|:|;|/|-)+ ","")
replace name_clean = regexr(name_clean,"^[0-9]+\)(\.|,|:|;|/|-)+","")
replace name_clean = regexr(name_clean,"^[0-9]+(\.|,|:|;|/|-)+ ","")
replace name_clean = regexr(name_clean,"^[0-9]+(\.|,|:|;|/|-)+","")
/*replace name_clean = regexr(name_clean,"^\+ ","")
replace name_clean = regexr(name_clean,"^\.[0-9]+\. ","")*/
g aux1 = 1 if regexm(name_clean,"^\. \. ")
g aux2 = ""
replace aux2 = regexs(0) if regexm(name_clean,"[0-9] [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+$") & aux1==1
replace aux2 = regexs(0) if regexm(name_clean,"[0-9] [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+$") & aux1==1
replace aux2 = regexs(0) if regexm(name_clean,"[0-9] [A-Z]+ [A-Z]+ [A-Z]+ [A-Z]+$") & aux1==1
replace aux2 = regexs(0) if regexm(name_clean,"[0-9] [A-Z]+ [A-Z]+ [A-Z]+$") & aux1==1
replace aux2 = regexs(0) if regexm(name_clean,"[0-9] [A-Z]+ [A-Z]+$") & aux1==1
replace aux2 = regexs(0) if regexm(name_clean,"[0-9] [A-Z]+$") & aux1==1
/*replace aux2 = "0 BIO-RAD LABORATORIES" in 201163
replace aux2 = "0 G.E. MEDICAL SYSTEMS" in 201164
replace aux2 = "0 S.E. CARBUROS METALICOS" in 201169
replace aux2 = "0 W.M. BLOSS" in 201175
replace aux2 = "2 DATEX-OHMEDA" in 201177
replace aux2 = "0 JOHNSON & JOHNSON" in 203853
replace aux2 = "4 B.BRAUN MEDICAL" in 203857
replace aux2 = "2 ST. JUDE MEDICAL ESPANA" in 203875
replace aux2 = "0 JOHNSON & JOHNSON" in 203879
replace aux2 = "9 BIO-IMPLANTS MEDICAL" in 203882
replace aux2 = "0 B. BRAUN DEXON" in 203884
replace aux2 = "4 JOHNSON & JOHNSON" in 203887
replace aux2 = "8 W.L.GORE Y ASOCIADOS" in 203888
replace aux2 = "0 BIO-IMPLANTS MEDICAL" in 203896
replace aux2 = "0 3M ESPANA" in 203900
replace aux2 = "6 B.BRAUN MEDICAL" in 203908
replace aux2 = "5 GE MEDICAL S. INF, TECHNOLOGIES" in 203913
replace aux2 = "3 DIANOVA 3000" in 203936
replace aux2 = "8 G.E.MEDICAL SYSTEMS ESPANA" in 203938
replace aux2 = "0 B.BRAUN MEDICAL" in 203953
replace aux2 = "0 SUMINISTROS Y DISTRIB. SANITARIAS" in 212222
replace aux2 = "0 TEDEC-MEIJI FARMA" in 212224
replace aux2 = "0 INGEN. E INTEGRACION AVANZADAS" in 212226
replace aux2 = regexr(aux2,"[0-9] ","") if aux1==1
replace name_clean = aux2 if aux1==1
drop aux1 aux2*/
/*replace name_clean = regexr(name_clean,"^\.[0-9]+\) ","")
replace name_clean = regexr(name_clean,"^\.B[0-9]+\) ","")
replace name_clean = regexr(name_clean,"^\.B\) ","")
replace name_clean = regexr(name_clean,"^\.PARTIDA [0-9]+: ","")
replace name_clean = regexr(name_clean,"^\.PARTIDA N\. [0-9]+: ","")
replace name_clean = regexr(name_clean,"^\.U \([0-9]+\), ","")
replace name_clean = regexr(name_clean,"^\.U \(","")
replace name_clean = regexr(name_clean,"^\.U Y ","")
replace name_clean = regexr(name_clean,"^\.U, ","")
replace name_clean = regexr(name_clean,"^\.U, Y ","")
replace name_clean = regexr(name_clean,"^\.U-","")
replace name_clean = regexr(name_clean,"^[0-9]+\)(\.|/) ","")
replace name_clean = regexr(name_clean,"^[0-9]+\)(\.|/)","")
replace name_clean = regexr(name_clean,"^[0-9]+\. ","")
replace name_clean = regexr(name_clean,"^[0-9]+\.","")
replace name_clean = regexr(name_clean,"^[0-9]+-[A-Z]+(,|\.|:|;) ","")
replace name_clean = regexr(name_clean,"^Y ","")*/
replace name_clean = regexr(name_clean,"^UTE ","")
replace name_clean = regexr(name_clean,"^UTE-","")
replace name_clean = regexr(name_clean,"^UTE(\.|,|:|;|.|\)|\(|-|/|\\) ","")
/*replace name_clean = regexr(name_clean,"(\.|,|:|;|.|\)|\(|-|/|\\)$","")
replace name_clean = regexr(name_clean,"^UNION TEMPORAL DE EMPRESA ","")
replace name_clean = regexr(name_clean,"^UNION TEMPORAL DE EMPRESAS A CONSTITUIR POR ","")
replace name_clean = regexr(name_clean,"^UNION TEMPORAL DE EMPRESAS \(","")
replace name_clean = regexr(name_clean,"^UNION TEMPORAL DE EMPRESAS \(U\.T\.E\.[\)]?","")
replace name_clean = regexr(name_clean,"^UNION TEMPORAL DE EMPRESAS \(UTE[\)]? ","")
replace name_clean = regexr(name_clean,"^UNION TEMPORAL DE EMPRESA","")*/

replace name_clean = "ZURICH SEGUROS" if regexm(name_clean,"^ZURICH")
/*replace name_clean = "ZURICH SEGUROS" in 120468
replace name_clean = "ZURICH SEGUROS" in 132180
replace name_clean = "ZURICH SEGUROS" in 133017
replace name_clean = "ZURICH SEGUROS" in 143412
replace name_clean = "ZURICH SEGUROS" in 152996
replace name_clean = "ZURICH SEGUROS" in 154718
replace name_clean = "ZURICH SEGUROS" in 168442
replace name_clean = "ZURICH SEGUROS" in 168516
replace name_clean = "ZURICH SEGUROS" in 171591
replace name_clean = "ZURICH SEGUROS" in 188236
replace name_clean = "ZURICH SEGUROS" in 190007
replace name_clean = "ZURICH SEGUROS" in 190008
replace name_clean = "ZURICH SEGUROS" in 210231
replace name_clean = "ZURICH SEGUROS" in 227208
replace name_clean = "ZURICH SEGUROS" in 232540
replace name_clean = "ZURICH SEGUROS" in 233427
replace name_clean = "ZURICH SEGUROS" in 233432
replace name_clean = "ZURICH SEGUROS" in 236356
replace name_clean = "ZURICH SEGUROS" in 243662
replace name_clean = "ZURICH SEGUROS" in 243665
replace name_clean = "ZURICH SEGUROS" in 246158
replace name_clean = "ZURICH SEGUROS" in 246347
replace name_clean = "ZURICH SEGUROS" in 248145
replace name_clean = "ZURICH SEGUROS" in 248690*/

replace name_clean = "JOHNSON & JOHNSON" if regexm(name_clean,"^JOHNSON")

replace name_clean = "XEROX ESPANA" if regexm(name_clean,"^XEROX ESPAN$")
replace name_clean = "XEROX ESPANA" if regexm(name_clean,"^XEROX[,]? ESPANA[,|\.]? (THE|DE) (DOCUMENT|DOMUMENT) COMPAN$")
replace name_clean = "XEROX ESPANA" if regexm(name_clean,"^XEROX ESPANA[,|\.]? (DOCUMENT|DOMUMENT) COM$")
replace name_clean = "XEROX ESPANA" if regexm(name_clean,"^XEROX-ESPANA THE DOCUMENT COMPAN$")
replace name_clean = "XEROX ESPANA" if regexm(name_clean,"^XEROX ESPANA THE DOCUMENTO COMPAN$")
/*replace name_clean = "XEROX ESPANA" in 145255
replace name_clean = "XEROX ESPANA" in 148292
replace name_clean = "XEROX ESPANA" in 201329
replace name_clean = "XEROX ESPANA" in 203518
replace name_clean = "XEROX ESPANA" in 205396
replace name_clean = "XEROX ESPANA" in 208825
replace name_clean = "XEROX ESPANA" in 216256
replace name_clean = "XEROX ESPANA" in 218471*/

replace name_clean = "XEROX OFFICE SUPPLIES" if regexm(name_clean,"^(XEROX OFFICE SUPPLIE|XEROX OFICCE SUPPLIE)$")
/*replace name_clean = "XEROX OFFICE SUPPLIES" in 150526
replace name_clean = "XEROX OFFICE SUPPLIES" in 206948
replace name_clean = "XEROX OFFICE SUPPLIES" in 222122
replace name_clean = "XEROX OFFICE SUPPLIES" in 220305*/

replace name_clean = "XEROX RENTING" if regexm(name_clean,"^XEROX RENTIN$")


replace name_clean = regexr(name_clean,"^\.[A-Z]","")

*===============================================================================

* Drop empty observations
drop if name_clean==""

* Save dataset
save names_Proc_alt, replace
