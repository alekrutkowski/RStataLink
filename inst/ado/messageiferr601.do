program messageiferr601
	if _rc==601 {
		di as err "The server's directory or file is not found!"
		di in smcl `"{stata "search r(601)":r(601);}"'
		if "<<<exit_on_error601>>>"=="TRUE" exit, STATA clear
		exit
	}
end

