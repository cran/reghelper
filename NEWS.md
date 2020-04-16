<!-- NEWS.md is generated from NEWS.Rmd. Please edit that file -->

# reghelper 0.3.6

This release deprecates the `beta()` method for nlme and lme4 models.
See the README for more details:
<https://github.com/jeff-hughes/reghelper>

# reghelper 0.3.5

This is a patch release to fix a bug in the beta() function, to allow
use of lmerTest models.

# reghelper 0.3.4

This is a patch release to cover changes made to the ggplot2 package.

BUG FIXES

  - Fixed simple\_slopes() to cover cases of contrasts that have no
    column names.

# reghelper 0.3.3

This is a patch release covering changes necessary to prepare for
submission to CRAN. Most changes will not affect current code; however,
be aware of the following changes:

  - Many of the functions have had the dots parameter (…) added, to
    ensure consistency with the S3 generic function. However, any extra
    parameters will simply be ignored. Thus, this does not impact any
    user code.

  - Package functions which implement the following generic methods have
    had their first parameter renamed, again for consistency with the S3
    generic: summary, print, coef, residuals, fitted. In most cases,
    this will not impact user code, unless you have used named
    parameters, e.g., `summary(model=results)` should now be
    `summary(object=results)`.

BUG FIXES

  - Fixed bug when using `build_model` but only providing a single model
    to be run.

  - Created special print method for `simple_slopes` so that “lme4”
    models print correctly.

  - Fixed bug (correctly this time) with `simple_slopes` using incorrect
    contrasts for factor variables.

# reghelper 0.3.2

BUG FIXES

  - Fixed bug with `simple_slopes` using incorrect contrasts for factor
    variables. Resolves Issue \#2.

# reghelper 0.3.1

  - `build_model` now drops missing data based on the variables included
    in the final model, so that all models are tested on the same data.

  - The `titles` parameter of `graph_model` has been changed to
    `labels`, and now takes a named list rather than relying on the
    index of a character vector.

  - `graph_model` function extended to include `lme` and `merMod`
    models.

# reghelper 0.3.0

NEW FEATURES

  - `beta` function extended to include `lme` and `merMod` models.

  - `build_model` function extended to include `aov` and `glm` models.

  - `cell_means` function extended to include `glm` models.

  - `graph_model` function extended to include `aov` and `glm` models.

  - `sig_regions` function extended to include `glm` models.

# reghelper 0.2.0

MAJOR CHANGES

  - Changed `block_lm` function name to `build_model`.

NEW FEATURES

  - Added examples to documentation for all functions.

  - `beta` function extended to include `glm` models.

  - `cell_means` function extended to include `aov` models.

  - `ICC` function extended to include `merMod` models (from “lme4”
    package).

  - `simple_slopes` function extended to include `aov`, `glm`, `lme`,
    and `merMod` models.

  - `simple_slopes` now includes `print` function to include
    significance stars.

BUG FIXES

  - Fixed bug with passing variables names to `build_model`,
    `cell_means`, and `graph_model`. Resolves Issue \#1.

# reghelper 0.1.0

NEW FEATURES

  - `beta` function calculates standardized beta coefficients.

  - `block_lm` function allows variables to be added to a series of
    regression models sequentially (similar to SPSS).

  - `ICC` function calculates the intra-class correlation for a
    multi-level model (lme only at this point).

  - `cell_means` function calculates the estimated means for a fitted
    model.

  - `graph_model` function graphs interactions at +/- 1 SD (uses ggplot2
    package).

  - `simple_slopes` function calculates the simple effects of an
    interaction.

  - `sig_regions` function calculate the Johnson-Neyman regions of
    significance for an interaction.
