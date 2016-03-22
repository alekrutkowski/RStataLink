qui { 
	set more off
	glo ID "<<<ID>>>"
	window manage maintitle `"Stata "server" run by R (id: <<<ID>>>) - don't close it!"'
	set linesize 250
	cls
	noi di as txt "Waiting for remote task requests..."
	while 1 {
		cap loc F : dir "<<<CD>>>" files "*.do", respectcase
		messageiferr601
		loc F : list sort F
		loc nF : list sizeof F
		loc n 1
		loc message 0
		foreach f of loc F {
			noi di as txt as smcl "{hline}"
			noi di as res "$S_DATE $S_TIME - Now processing:" _n as txt "`f'"
			loc message 1
			cap noi do "<<<CD>>>/`f'"
			cap erase "<<<CD>>>/`f'"
			if `n'==`nF' & `message'==1 {
				noi di as txt as smcl "{hline}"
				noi di as txt "Waiting for remote task requests in"
				noi di as txt "<<<CD>>>"
			}
			loc ++n
		}
		sleep 10
	}
}

