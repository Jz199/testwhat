% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check-control.R
\name{check_control}
\alias{check_control}
\alias{check_if_else}
\alias{check_while}
\alias{check_for}
\alias{check_cond}
\alias{check_body.ControlState}
\alias{check_if}
\alias{check_else}
\title{Check whether student coded a control statement correctly}
\usage{
check_if_else(state, index = 1, not_found_msg = NULL, append = TRUE)

check_while(state, index = 1, not_found_msg = NULL, append = TRUE)

check_for(state, index = 1, not_found_msg = NULL, append = TRUE)

check_cond(state)

\method{check_body}{ControlState}(state, ...)

check_if(state)

check_else(state, not_found_msg = NULL, append = TRUE)
}
\arguments{
\item{state}{state to start from (for \code{check_} functions)}

\item{index}{Number of that particular control statement to check}

\item{not_found_msg}{Custom message in case the control statement was not found}

\item{append}{Whether or not to append the feedback to feedback built in previous states}

\item{...}{S3 stuff}
}
\description{
Check whether student coded a control statement correctly
}
\examples{
\dontrun{
# Example 1: if else
vec <- c("a", "b", "c")
if("a" \%in\% vec) {
 print("a in here")
} else if(any("b" > vec)) {
 cat("b not smallest")
} else {
 str(vec)
}
                                           
# SCT
check_if_else(1) \%>\%  {
  check_cond(.) \%>\% {
    check_code(., "\%in\%")
    check_code(., "vec")
  }
  check_if(.) \%>\% check_function(., "print")
  check_else(.) \%>\% check_if_else() {
    check_cond(.) \%>\% check_code(">")
    check_if(.) \%>\% check_function("cat")
    check_else(.) \%>\% check_function("str")
  }
}

# Example 2: while loop
while(x < 18) {
 x <- x + 5
 print(x)
}

# SCT
check_while(1) \%>\% {
  check_cond(.) \%>\% check_code(c("< 18", "18 >"))
  check_body(.) \%>\% {
    check_code(., c("x + 5", "5 + x"))
    check_function(., "print") \%>\% test_arg("x")
  }
}

# Example 3: for loop
for(i in 1:5) {
 print("hurray!") 
}

# SCT
ex() \%>\% check_for() \%>\% {
  check_cond(.) \%>\% {
    check_code(., "in")
    check_code(., "1")
    check_code(., "5")
  }
  check_body(.) \%>\% check_function("print") \%>\% check_arg("x") \%>\% check_equal()
}
}
}
