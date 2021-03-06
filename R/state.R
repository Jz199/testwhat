#' testwhat states.
#'
#' Root State has no parent state.
#' ChildState does have state.
#' Both inherit from the prototypical State class
#'
#' @name state

#' @rdname state
#' @importFrom R6 R6Class
#' @export
State <- R6::R6Class("State",
                     public = list(
                       set = function(...) {
                         els <- list(...)
                         for (i in seq_along(els)) {
                           tryCatch(assign(names(els)[i], els[[i]], envir = private),
                                    error = function(e) {
                                      stop(sprintf("Cannot set '%s'; the name is invalid.", names(els[i])))
                                    })
                         }
                       },
                       verify_root = function(fun = deparse(sys.call(-1)[[1]])) {
                         stop(sprintf("`%s()` should only be called from the root state, `ex()`.", fun))
                       },
                       assert_is = function(cls, parent, fun=deparse(sys.call(-1)[[1]])) {
                         if (!any(class(self) %in% cls)) {
                           stop(sprintf("`%s()` can only be called on `%s()`.", fun, parent))
                         }
                       },
                       assert_is_not = function(cls, parent, fun=deparse(sys.call(-1)[[1]])) {
                         if (any(class(self) %in% cls)) {
                           stop(sprintf("`%s()` should not be called on `%s()`.", fun, parent))
                         }
                       }
                     ),
                     private = list(
                       pec = NULL,
                       student_code = NULL,
                       student_pd = NULL,
                       student_env = NULL,
                       solution_code = NULL,
                       solution_pd = NULL,
                       solution_env = NULL,
                       output_list = NULL,
                       test_env = NULL,
                       force_diagnose = FALSE
                     )
)

#' @export
print.State <- function(x, ...) {
  cat(paste0("<", class(x)[1], ">\n"))
}

#' @rdname state
#' @export
RootState <- R6::R6Class("RootState", inherit = State,
                         public = list(
                           initialize = function(...) {
                             self$set(...)
                           },
                           get = function(name) {
                             return(private[[name]])
                           },
                           verify_root = function(...) {
                             return(TRUE)
                           }
                         )
)

#' @rdname state
#' @export
ChildState <- R6::R6Class("ChildState", inherit = State,
                          public = list(
                            initialize = function(state) {
                              private$parent = state
                              # copy details from parent
                              self$details = private$parent$details
                            },
                            get = function(name) {
                              el <- private[[name]]
                              if (is.null(el)) {
                                el <- private$parent$get(name)
                              }
                              return(el)
                            },
                            add_details = function(...) {
                              self$details <- c(self$details, list(list(...)))
                            },
                            set_details = function(...) {
                              det <- list(...)
                              n <- length(self$details)
                              self$details[[n]][names(det)] <- det
                            },
                            details = list()
                          ),
                          private = list(
                            parent = NULL
                          )
)


CallState <- R6::R6Class("CallState", inherit = ChildState, private = list(student_call = NULL, solution_call = NULL))
FunctionState <- R6::R6Class("FunctionState", inherit = CallState)
OperationState <- R6::R6Class("OperationState", inherit = CallState)

CallResultState <- R6::R6Class("CallResultState", inherit = CallState, private = list(student_call_result = NULL,
                                                                                      solution_call_result = NULL))
FunctionResultState <- R6::R6Class("FunctionResultState", inherit = CallResultState)
OperationResultState <- R6::R6Class("OperationResultState", inherit = CallResultState)

ArgumentState <- R6::R6Class("ArgumentState", inherit = ChildState, private = list(student_arg = NULL, solution_arg = NULL))

ObjectState <- R6::R6Class("ObjectState", inherit = ChildState, private = list(name = NULL, student_object = NULL, solution_object = NULL))
ObjectColumnState <- R6::R6Class("ObjectColumnState", inherit = ObjectState)
ObjectElementState <- R6::R6Class("ObjectElementState", inherit = ObjectState)

FunDefState <- R6::R6Class("FunDefState", inherit = ChildState, private = list(name = NULL, student_object = NULL, solution_object = NULL))
FunDefArgsState <- R6::R6Class("FunDefArgsState", inherit = FunDefState)
ExprState <- R6::R6Class("ExprState", inherit = ChildState, private = list(expr = NULL))

ExprEvalState <- R6::R6Class("ExprState", inherit = ChildState, private = list(student_object = NULL, solution_object = NULL))
ExprResultState <- R6::R6Class("ExprResultState", inherit = ExprEvalState)
ExprOutputState <- R6::R6Class("ExprOutputState", inherit = ExprEvalState)
ExprErrorState <- R6::R6Class("ExprErrorState", inherit = ExprEvalState)

ControlState <- R6::R6Class("ControlState", inherit = ChildState, private = list(student_struct = NULL, solution_struct = NULL))

SubState <- R6::R6Class("SubState", inherit = ChildState)
ProxySubState <- R6::R6Class("ProxySubState", inherit = SubState,
                             public = list(
                               verify_root = function(fun = deparse(sys.call(-1)[[1]])) {
                                 private$parent$verify_root(fun)
                               },
                               assert_is = function(cls, parent, fun=deparse(sys.call(-1)[[1]])) {
                                 private$parent$assert_is(cls, parent, fun)
                               },
                               assert_is_not = function(cls, parent, fun=deparse(sys.call(-1)[[1]])) {
                                 private$parent$assert_is_not(cls, parent, fun)
                               }
                             ))

RegexState <- R6::R6Class("RegexState", inherit = ChildState)
FileState <- R6::R6Class("FileState", inherit = ChildState)
ErrorState <- R6::R6Class("ErrorState", inherit = ChildState)

MarkdownState <- R6::R6Class("MarkdownState", inherit = ChildState,
                             private = list(student_ds = NULL,
                                            solution_ds = NULL,
                                            student_ds_part = NULL,
                                            solution_ds_part = NULL,
                                            inline_number = NULL,
                                            chunk_number = NULL))

MarkdownHeaderState <- R6::R6Class("MarkdownHeaderState", inherit = ChildState,
                                   private = list(student_title = NULL,
                                                  solution_title = NULL))

MarkdownChunkState <- R6::R6Class("MarkdownChunkState", inherit = ChildState,
                                  private = list(student_options = NULL,
                                                 solution_options = NULL))

MarkdownYamlState <- R6::R6Class("MarkdownYamlState", inherit = ChildState,
                                 private = list(student_yaml = NULL,
                                                solution_yaml = NULL))

MarkdownOptionState <- R6::R6Class("MarkdownOptionState", inherit = ChildState,
                                   private = list(student_option = NULL,
                                                  solution_option = NULL))
MarkdownChunkOptionState <- R6::R6Class("MarkdownChunkOptionState", inherit = MarkdownOptionState)
MarkdownYamlOptionState <- R6::R6Class("MarkdownYamlOptionState", inherit = MarkdownOptionState)

#' Get the main state
#'
#' \code{ex()} should be the start of every SCT chain
#'
#' @export
ex <- function() {
  return(tw$get("state"))
}

decorate_state <- function(state, stud, sol, el = NULL) {
  if (is.null(el)) {
    state$set(student_pd = stud$pd,
              solution_pd = sol$pd,
              student_code = stud$code,
              solution_code = sol$code)
  } else {
    state$set(student_pd = stud[[el]]$pd,
              solution_pd = sol[[el]]$pd,
              student_code = stud[[el]]$code,
              solution_code = sol[[el]]$code)
  }
}

#' Functions to override solution code (and parse data) and variables in the solution environment.
#' 
#' Produces a new state with a custom solution code. Mostly useful inside
#' \code{check_or}, if you want to test for different cases.
#' 
#' @param state the state to create a substate from
#' @param code the solution code to put into the state
#' @param ... named environment variables to add to or override in the solution environment
#' 
#' @name override

#' @rdname override
#' @export
override_solution <- function(state, code = NULL, ...) {
  sub_state <- ProxySubState$new(state)
  if (!is.null(code)) {
    sub_state$set(solution_code = code, solution_pd = build_pd(code, silent=FALSE))
  }
  env = list(...)
  if (!is.null(env)) {
    sub_state$set(solution_env = new.env(parent = globalenv()))
    for (el in ls(envir = state$get("solution_env"))) {
      assign(el, get(el, envir = state$get("solution_env")), envir = sub_state$get("solution_env"))
    }
    for (i in seq_along(env)) {
      name <- names(env)[i]
      val <- env[[i]]
      assign(name, val, envir = sub_state$get("solution_env"))
    }
  }
  return(sub_state)
}

#' @rdname override
#' @export
override_solution_code <- function(state, code) {
  override_solution(state, code = code)
}

#' @rdname override
#' @export
override_solution_env <- function(state, ...) {
  override_solution(state, code = NULL, ...)
}

#' Disable highlighting for any future checks in the chain
#'
#' If the function is used right after \code{ex()}, highlighting is disabled for
#' the rest of the chain
#'
#' If the function used 'deep in a chain', the system will fall back on
#' highlights that were collected earlier in the state.
#'
#' @param state the state to create a substate from
#'
#' @export
disable_highlighting <- function(state) {
  sub_state <- ProxySubState$new(state)
  sub_state$add_details(highlighting_disabled = TRUE)
  return(sub_state)
}

assert_state <- function(x, fun = deparse(sys.call(-1)[[1]])) {
  if (!isTRUE(inherits(x, "State"))) {
    stop(sprintf("The first argument to `%s()` should be a state object. Maybe you forgot a dot?", fun))
  }
}
