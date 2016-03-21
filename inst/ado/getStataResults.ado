prog getStataResults
	args time_stamp
	foreach class in e r {
		preserve
			clear
			gen type = ""
			gen name = ""
			gen double value = .
			gen txt_value = ""
			loc n 0
			
			foreach t in scalars macros {
				loc pfix
				if "`t'"=="macros" loc pfix = "txt_"
				foreach v in `: `class'(`t')' {
					loc ++n
					set obs `=_N + 1'
					replace type = "`t'" in `n'
					replace name = "`v'" in `n'
					replace `pfix'value = `class'(`v') in `n'
				}
			}
			if !mi("`: `class'(matrices)'") {
				gen rowname = ""
				gen colname = ""
			}
			foreach m in `: `class'(matrices)' {
				tempvar M
				matrix `M' = `class'(`m')
				foreach c in `: colfullnames `class'(`m')' {
					foreach r in `: rowfullnames `class'(`m')' {
						loc ++n
						set obs `=_N + 1'
						replace type = "matrices" in `n'
						replace name = "`m'" in `n'
						replace colname = "`c'" in `n'
						replace rowname = "`r'" in `n'
						replace value = el(`M', rownumb(`M',"`r'"), colnumb(`M',"`c'")) in `n'
					}
				}
				matrix drop `M'
			}
			if "`class'"=="e" {
				cap mat li e(b)
				if !_rc  {
					foreach v in `: colnames e(b)' {
						foreach t in _b _se {
							loc ++n
							set obs `=_N + 1'
							replace type = "`t'" in `n'
							replace name = "`v'" in `n'
							replace value = `t'[`v'] in `n'
						}
					}
				}	
			}
			outsheet using "<<<CD>>>/resultdf_`class'_`time_stamp'.tsv", replace
		restore
	}
end

