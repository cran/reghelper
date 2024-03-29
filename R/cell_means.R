#' Estimated values of a linear model.
#' 
#' \code{cell_means} calculates the predicted values at specific points, given
#' a fitted regression model (linear, generalized, or ANOVA).
#' 
#' By default, this function will provide means at -1 SD, the mean, and +1 SD
#' for continuous variables, and at each level of categorical variables. This
#' can be overridden with the \code{levels} parameter.
#' 
#' If there are additional covariates in the model other than what are selected
#' in the function call, these variables will be set to their respective means.
#' In the case of a categorical covariate, the results will be averaged across
#' all its levels.
#' 
#' @param model A fitted linear model of type 'lm', 'aov', or 'glm'.
#' @param ... Pass through variable names to add them to the table.
#' @param levels A list with element names corresponding to some or all of the
#'   variables in the model. Each list element should be a vector with the names
#'   of factor levels (for categorical variables) or numeric points (for
#'   continuous variables) at which to test that variable.
#' @param type The type of prediction required. The default 'link' is on the
#'   scale of the linear predictors; the alternative 'response' is on the scale
#'   of the response variable. For more information, see
#'   \code{\link{predict.glm}}.
#' @return A data frame with a row for each predicted value. The first few
#'   columns identify the level at which each variable in your model was set.
#'   After columns for each variable, the data frame has columns for the
#'   predicted value, the standard error of the predicted mean, and the 95\%
#'   confidence interval.
#' @examples
#' # iris data
#' model <- lm(Sepal.Length ~ Petal.Length + Petal.Width, iris)
#' summary(model)
#' cell_means(model, Petal.Length)
#' @export
cell_means <- function(model, ...) UseMethod('cell_means')


#' Estimated values of a linear model.
#' 
#' \code{cell_means_q} calculates the predicted values at specific points,
#' given a fitted regression model (linear, generalized, or ANOVA).
#' 
#' By default, this function will provide means at -1 SD, the mean, and +1 SD
#' for continuous variables, and at each level of categorical variables. This
#' can be overridden with the \code{levels} parameter.
#' 
#' If there are additional covariates in the model other than what are selected
#' in the function call, these variables will be set to their respective means.
#' In the case of a categorical covariate, the results will be averaged across
#' all its levels.
#' 
#' Note that in most cases it is easier to use \code{\link{cell_means}} and
#' pass variable names in directly instead of strings of variable names.
#' \code{cell_means_q} uses standard evaluation in cases where such evaluation
#' is easier.
#' 
#' @param model A fitted linear model of type 'lm', 'aov', or 'glm'.
#' @param vars A vector or list with variable names to be added to the table.
#' @param levels A list with element names corresponding to some or all of the
#'   variables in the model. Each list element should be a vector with the names
#'   of factor levels (for categorical variables) or numeric points (for
#'   continuous variables) at which to test that variable.
#' @param type The type of prediction required. The default 'link' is on the
#'   scale of the linear predictors; the alternative 'response' is on the scale
#'   of the response variable. For more information, see
#'   \code{\link{predict.glm}}.
#' @param ... Not currently implemented; used to ensure consistency with S3 generic.
#' @return A data frame with a row for each predicted value. The first few
#'   columns identify the level at which each variable in your model was set.
#'   After columns for each variable, the data frame has columns for the
#'   predicted value, the standard error of the predicted mean, and the 95\%
#'   confidence interval.
#' @seealso \code{\link{cell_means}}
#' @examples
#' # iris data
#' model <- lm(Sepal.Length ~ Petal.Length + Petal.Width, iris)
#' summary(model)
#' cell_means_q(model, 'Petal.Length')
#' @export
cell_means_q <- function(model, ...) UseMethod('cell_means_q')


#' @describeIn cell_means Estimated values for a linear model.
#' @export
cell_means.lm <- function(model, ..., levels=NULL) {
    # grab variable names
    call_list <- as.list(match.call())[-1]
    call_list[which(names(call_list) %in% c('model', 'levels'))] <- NULL
    
    var_names <- NULL
    if (length(call_list) > 0) {
        # turn variable names into strings
        var_names <- sapply(call_list, .expr_to_str)
    }    
    return(cell_means_q.lm(model, var_names, levels))
}


#' @describeIn cell_means_q Estimated values for a linear model.
#' @export
cell_means_q.lm <- function(model, vars=NULL, levels=NULL, ...) {
    factors <- .set_factors(model$model, vars, levels, sstest=FALSE)
    final_grid <- with(model$model, expand.grid(factors))
    
    # deal with covariates
    all_vars <- as.list(attr(terms(model), 'variables'))[-c(1:2)]
    duplicate <- character(0)
    for (i in 1:length(all_vars)) {
        term <- as.character(all_vars[[i]])
        if (!(term %in% vars)) {
            if (is.factor(model$model[[term]])) {
                # if we have categorical covariates, we must repeat the
                # predictions for each level, then average across them
                duplicate[length(duplicate)+1] <- term
                factors[[term]] <- levels(model$model[[term]])
            } else if (is.character(model$model[[term]])) {
                # do the same thing as the factor, but convert first
                duplicate[length(duplicate)+1] <- term
                factors[[term]] <- levels(factor(model$model[[term]]))
            } else {
                factors[[term]] <- mean(model$model[[term]])
            }
        }
    }
    
    grid <- with(model$model, expand.grid(factors))
    predicted <- predict(model, newdata=grid, se=TRUE)
    
    if (length(duplicate) > 0) {
        # deal with categorical covariates here
        final_grid <- .aggregate_grid(grid, predicted, duplicate)
        names(final_grid)[names(final_grid) == 'fit'] <- 'value'
        names(final_grid)[names(final_grid) == 'se.fit'] <- 'se'
    } else {
        final_grid$value <- predicted$fit
        final_grid$se <- predicted$se.fit
    }
    
    final_grid$ci.lower <- final_grid$value - 1.96 * final_grid$se
    final_grid$ci.upper <- final_grid$value + 1.96 * final_grid$se
    return(final_grid)
}


#' @describeIn cell_means Estimated means for ANOVA.
#' @export
cell_means.aov <- function(model, ..., levels=NULL) {
    # grab variable names
    call_list <- as.list(match.call())[-1]
    call_list[which(names(call_list) %in% c('model', 'levels'))] <- NULL
    
    var_names <- NULL
    if (length(call_list) > 0) {
        # turn variable names into strings
        var_names <- sapply(call_list, .expr_to_str)
    }    
    return(cell_means_q.aov(model, var_names, levels))
}


#' @describeIn cell_means_q Estimated means for ANOVA.
#' @export
cell_means_q.aov <- function(model, vars=NULL, levels=NULL, ...) {
    cell_means_q.lm(model, vars, levels)
}


#' @describeIn cell_means Estimated values for a generalized linear model.
#' @export
cell_means.glm <- function(model, ..., levels=NULL,
    type=c('link', 'response')) {
    
    # grab variable names
    call_list <- as.list(match.call())[-1]
    call_list[which(names(call_list) %in% c('model', 'levels', 'type'))] <- NULL
    
    var_names <- NULL
    if (length(call_list) > 0) {
        # turn variable names into strings
        var_names <- sapply(call_list, .expr_to_str)
    }    
    return(cell_means_q.glm(model, var_names, levels, type))
}


#' @describeIn cell_means_q Estimated values for a generalized linear model.
#' @export
cell_means_q.glm <- function(model, vars=NULL, levels=NULL,
    type=c('link', 'response'), ...) {
    
    type <- match.arg(type)
    
    factors <- .set_factors(model$model, vars, levels, sstest=FALSE)
    final_grid <- with(model$model, expand.grid(factors))
    
    # deal with covariates
    all_vars <- as.list(attr(terms(model), 'variables'))[-c(1:2)]
    duplicate <- character(0)
    for (i in 1:length(all_vars)) {
        term <- as.character(all_vars[[i]])
        if (!(term %in% vars)) {
            if (is.factor(model$model[[term]])) {
                # if we have categorical covariates, we must repeat the
                # predictions for each level, then average across them
                duplicate[length(duplicate)+1] <- term
                factors[[term]] <- levels(model$model[[term]])
            } else if (is.character(model$model[[term]])) {
                # do the same thing as the factor, but convert first
                duplicate[length(duplicate)+1] <- term
                factors[[term]] <- levels(factor(model$model[[term]]))
            } else {
                factors[[term]] <- mean(model$model[[term]])
            }
        }
    }
    
    grid <- with(model$model, expand.grid(factors))
    predicted <- predict(model, newdata=grid, type=type, se=TRUE)
    
    if (length(duplicate) > 0) {
        # deal with categorical covariates here
        final_grid <- .aggregate_grid(grid, predicted, duplicate)
        names(final_grid)[names(final_grid) == 'fit'] <- 'value'
        names(final_grid)[names(final_grid) == 'se.fit'] <- 'se'
    } else {
        final_grid$value <- predicted$fit
        final_grid$se <- predicted$se.fit
    }
    
    final_grid$ci.lower <- final_grid$value - 1.96 * final_grid$se
    final_grid$ci.upper <- final_grid$value + 1.96 * final_grid$se
    return(final_grid)
}


#' Aggregate grid over specific variables.
#' 
#' Helper function takes a grid and predicted values, and aggregates (averages)
#' the values across a categorical variable(s).
#' 
#' @param grid Data frame with all points at which variables were tested.
#' @param predicted Data frame with predicted values, a result of each test in
#'   \code{grid}.
#' @param agg_vars A character vector with the names of variables to be
#'   aggregated over.
#' @return A data frame combining the grid and predicted values, aggregated over
#'   all variables in \code{agg_vars}.
#' @noRd
.aggregate_grid <- function(grid, predicted, agg_vars) {
    vars <- names(grid)
    non_agg_vars <- vars[-match(agg_vars, vars)]
    grid_predicted <- cbind(grid, predicted)
    vars_list <- paste(non_agg_vars, collapse=' + ')
    formula <- paste('cbind(fit, se.fit, df) ~', vars_list)
    new_grid <- aggregate(as.formula(formula), grid_predicted,
        mean, na.rm=TRUE)
    return(new_grid)
}



