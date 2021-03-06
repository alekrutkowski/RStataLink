% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/concurrent.R
\name{doInStataClusterLB}
\alias{doInStataClusterLB}
\title{Execute multiple pieces of Stata code (tasks/jobs) in a "cluster" of multiple Stata
instances -- a "load balancing" version}
\usage{
doInStataClusterLB(cl, X, isStataReadyTimeout = 1, ...)
}
\arguments{
\item{cl}{A "cluster" -- a list of objects of S3 class 'StataID', possibly
generated by \code{\link[RStataLink]{startStataCluster}}.}

\item{X}{A vector (list of atomic character vectors, or an atomic character vector) of
jobs/tasks (Stata code) to be executed across different Stata instances.}

\item{isStataReadyTimeout}{Passed to argument \code{timeout} of \code{\link[RStataLink]{isStataReady}}
that is used internally to allocate jobs/tasks only to non-busy Stata instances.
Default: 1. See the warning for argument \code{timeout} in \code{\link[RStataLink]{isStataReady}}
documentation.}

\item{...}{Further arguments passed to \code{\link[RStataLink]{doInStata}}.}
}
\value{
A list of objects returned by \code{\link[RStataLink]{doInStata}} in the order
corresponding to the order of jobs/tasks in \code{X}.
}
\description{
This is a \code{\link[parallel]{parLapplyLB}}-like wrapper around
\code{\link[RStataLink]{doInStata}} that allows executing
multiple pieces of Stata code in a parallel/concurrent manner.
}

