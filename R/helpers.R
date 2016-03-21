#' @import magrittr
NULL


# Helper functions needed for constants -----------------------------------

'%++%' <- function(x,y) paste0(x,y)

readFile <- function(filename)
	readLines(filename) %>%
	paste(collapse="\n")


# Constants ---------------------------------------------------------------

package_path <- system.file(package='RStataLink')

ado_path <- package_path %++% '/ado/'

do_path <- package_path %++% '/do/'

stataServerCode <- readFile(do_path %++% 'stata_server_code.do')

adoFilesCode <- list.files(ado_path, full.names=TRUE) %>%
	sapply(readFile) %>%
	paste(collapse='\n')


# Other helper functions --------------------------------------------------

removeFiles <- function(path, time_stamp)
	list.files(path,
			   glob2rx('*' %++% time_stamp %++% '*'),
			   full.names=TRUE) %>%
	unlink(force=TRUE)

listOfPairs <- function(li) {
	stopifnot(length(li) %% 2 == 0)
	li %>%
		split(length(li) %>%
			  	divide_by(2) %>%
			  	seq.int %>%
			  	rep.int(2) %>%
			  	sort)
}

multiGsub <- function(stri, li)
	Reduce(function(x,y)
		gsub(y[[1]], y[[2]],
			 x, fixed=TRUE),
		listOfPairs(li),
		init=stri)

timeStamp <- function() {
	op <- options(digits.secs=6)
	time_stamp <- Sys.time() %>%
		make.names %>%
		substr(2, nchar(.)) %>%
		gsub('.', '', ., fixed=TRUE) %++%
		(sample(LETTERS, 3) %>%
		 	paste0(collapse=""))
	options(op)
	time_stamp
}

withNames <- function(vec, Names)
	vec %>% set_names(Names)

dfResultsToList <- function(df) {
	# --- scalars and macros ---
	types <- c('scalars','macros')
	L <- lapply(types,
				function(x)
					df[df$type==x, ] %>%
					as.list %>%
					{withNames(.[[switch(x,
										 'scalars'='value',
										 'macros'='txt_value')]],
							   .[['name']])} %>%
					as.list %>%
					{if (length(.)!=0) .}) %>%
		set_names(types) %>%
		{if (length(.)!=0) .}
	# --- matrices ---
	Mdf <- df[df$type=='matrices', ]
	mnames <- Mdf$name %>%
		unique
	M <- lapply(mnames,
				function(x)
					Mdf[Mdf$name==x, ] %>%
					{matrix(.$value,
							byrow=FALSE,
							ncol=length(unique(.$colname)),
							nrow=length(unique(.$rowname)),
							dimnames=list(unique(.$rowname),
										  unique(.$colname)))} %>%
					`class<-`(c(class(.),'StataMatrix'))) %>%
		set_names(mnames) %>%
		{if (length(.)!=0) .}
	# --- coefficients and standard errors ---
	modeldf <- df[df$type %in% c('_b','_se'), ] %>%
	{data.frame(coef=.[.$type=='_b','value'],
				stderr=.[.$type=='_se','value'],
				stringsAsFactors=FALSE,
				row.names=unique(.[['name']]),
				check.names=FALSE)} %>%
		`class<-`(c(class(.),'Stata_b_se')) %>% 
		{if (nrow(.)!=0) .}
	# --- return ---
	c(L,
	  matrices=list(M),
	  modeldf=list(modeldf)) %>%
		Filter(function(x) !is.null(x),
			   .) %>%
		`class<-`('StataResults')
}


onlyThoseReady <- function(cl, ...) {
	ifready <- sapply(cl, isStataReady, ...)
	ifready %>%
		Filter(isTRUE,.) %>%
		length %>%
		{`if`(. < length(cl),
			  `if`(. > 0, {
			  	warning('Using only ',.,' of ',length(cl),
			  			' Stata instances, those that are available/ready!')
			  	cl[ifready]},
			  	stop('No Stata instance is available/ready!')),
			  cl)}
}

