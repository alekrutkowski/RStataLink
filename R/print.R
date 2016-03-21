#' @export
print.StataLog <- function(log) {
	cat(log, sep='\n')
	invisible(log)
}

#' @export
print.StataResults <- function(res) {
	str(res)
	invisible(res)
}

#' @export
str.Stata_b_se <- function(res, ...) {
	print(res)
	cat('\n')
}

#' @export
str.StataMatrix <- function(res, ...) {
	cat('\n')
	print(res)
	cat('\n')
}

#' @export
print.StataID <- function(id) {
	cat('StataID object:\n')
	cat('\n Stata "server" id:\n', names(id), '\n (you can see it in the top of the Stata window)\n')
	cat('\n Full path to the Stata "server" <--> R\n data exchange directory (folder):\n', unclass(id), '\n')
	cat('\n Should Stata close if this directory disappears:\n',
		ifelse(attr(id, 'exit_on_error601'), 'yes', 'no'), '\n\n')
	invisible(id)
}

