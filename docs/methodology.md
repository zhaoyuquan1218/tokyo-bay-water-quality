# Analytical methods and scientific boundaries

## Time and spatial support

The controlling public release contains preprocessed regional series. Preserve its campaign-based model period; do not derive analysis quarters from actual dates. `Central` is normalized to `Center` to agree with the approved six-station doctoral map. Regional observations cannot be disaggregated into stations. Layer is assigned `surface` from the associated study's surface-series scope; the workbook does not encode a depth field. No bottom observations enter this public analysis.

Annual values are the unweighted arithmetic means of four eligible regional quarterly values. They are concentration summaries, not estimates of carbon inventories, annual fluxes or volume-weighted bay-wide conditions. Within-year standard deviations describe seasonal spread and are not standard errors of annual means. Incomplete years retain a missing annual mean.

## Seasonal linear summaries

Fit each of the 30 region-variable series independently using

`value = intercept + slope * elapsed_analysis_years + quarter_indicators + residual`.

The quarterly index covers 1-164. Elapsed analysis years equal `(quarterly_index - 1)/4`; therefore the slope is in the source concentration unit per year. This is algebraically equivalent to the inspected PhD model `value ~ time_index + factor(quarter)` with its coefficient multiplied by four. No breakpoints are selected in this project. The model is a full-period descriptive summary and can be inadequate for nonlinear changes or unusual extremes.

At least 80 eligible quarters and all four seasonal categories are required. This is an explicit workflow coverage rule, not a power calculation or literature-derived scientific threshold. It is recorded in `config/analysis.csv`. Model coefficients must be finite; deficient rank or invalid covariance fails explicitly rather than producing a misleading result.

## Residual dependence and uncertainty

The HAC covariance uses Bartlett weights `1-h/(L+1)` for actual quarter lag `h`, `L=4`, without prewhitening and with scaling `n/(n-k)`. Only pairs separated by `h` actual grid positions contribute. The implementation retains temporal gaps; it does not compress missing records into adjacent quarters. On complete data this is the usual Newey-West covariance for OLS. A direct intercept-only calculation with genuine gaps is an independent automated reference check.

Approximate two-sided normal 95% intervals and p-values are reported. A lag-8 sensitivity is exported alongside the primary lag-4 results. Lag-1 residual correlations use actual adjacent quarters. HAC inference remains asymptotic and depends on bandwidth and stationarity assumptions; it does not establish model adequacy. The 30 primary p-values are adjusted together with Benjamini-Hochberg. Confidence intervals remain pointwise rather than simultaneous.

## Regional comparisons

For each variable, form North-Center, North-South and Center-South differences on matched, eligible quarters. Export the number of pairs, mean difference and standard deviation of quarterly differences. No independent-sample test or causal claim is attached. Regional averages inherit the upstream station composition and processing, which cannot be revalidated from the public workbook.

## What has and has not changed

The public workflow adapts existing data-processing helpers and seasonal regression structure. It adds explicit source contracts, duplicate quarantine, review-only IQR flags, coverage rules and a gap-aware covariance implementation. These are documented project choices, not undocumented alterations to the original paper's VAR/FEVD specification.

No six-state M0 equations, carbon transfers, mass-balance calculations, parameters or calibration bounds were changed. No DOC/POC values were interpolated. No VAR, FEVD, LMG, DSEM or process-model calibration is claimed as reproduced. The raw station-layer extraction code was inspected but was not run against or copied with the restricted observations. No TAF execution or conformance check was performed.
