# OLS with seasonal indicators follows the inspected PhD trend code.
# This covariance implementation additionally preserves distances across missing quarters.
hac_vcov <- function(fit, time_index, lag = 4L) {
  X <- stats::model.matrix(fit)
  e <- stats::residuals(fit)
  n <- nrow(X); k <- ncol(X)
  assert(n == length(time_index) && !anyDuplicated(time_index), "HAC time indices must be unique and aligned.")
  assert(all(is.finite(time_index)) && all(time_index == floor(time_index)), "HAC requires integer quarter indices.")
  assert(n > k && fit$rank == k, "Rank-deficient or saturated regression.")
  assert(length(lag) == 1L && is.finite(lag) && lag >= 0 && lag == floor(lag), "Invalid HAC lag.")
  score <- X * as.numeric(e)
  meat <- crossprod(score)
  if (lag > 0L) for (h in seq_len(lag)) {
    previous <- match(time_index - h, time_index)
    current <- which(!is.na(previous))
    if (length(current)) {
      gamma <- crossprod(score[current, , drop = FALSE], score[previous[current], , drop = FALSE])
      meat <- meat + (1 - h / (lag + 1)) * (gamma + t(gamma))
    }
  }
  bread <- solve(crossprod(X))
  result <- (n / (n - k)) * bread %*% meat %*% bread
  assert(all(is.finite(result)) && all(diag(result) >= -1e-10), "Invalid HAC covariance.")
  result
}

annual_summary <- function(grid, min_quarters = 4L) {
  groups <- split(seq_len(nrow(grid)), interaction(grid$region, grid$layer, grid$variable, grid$year, drop = TRUE))
  out <- do.call(rbind, lapply(groups, function(i) {
    z <- grid[i, ]; n <- sum(is.finite(z$value))
    data.frame(region = z$region[1], layer = z$layer[1], variable = z$variable[1], unit = z$unit[1],
               year = z$year[1], n_quarters = n,
               annual_mean = if (n >= min_quarters) safe_mean_monitoring(z$value) else NA_real_,
               annual_sd = if (n >= 2L) stats::sd(z$value, na.rm = TRUE) else NA_real_,
               status = if (n >= min_quarters) "complete" else "incomplete_seasons")
  }))
  out[order(out$variable, out$region, out$year), ]
}

fit_trends <- function(grid, config) {
  groups <- split(seq_len(nrow(grid)), interaction(grid$region, grid$variable, drop = TRUE))
  results <- list(); residual_tables <- list()
  for (g in names(groups)) {
    z <- grid[groups[[g]], ]; z <- z[order(z$time_index), ]
    z <- z[is.finite(z$value), ]
    row <- grid[groups[[g]][1], c("region", "layer", "variable", "unit")]
    row$n_quarters <- nrow(z)
    row$slope_per_year <- row$se_hac <- row$ci_low <- row$ci_high <- row$p_value <- NA_real_
    row$se_hac_lag8 <- row$p_value_lag8 <- row$residual_acf1 <- row$r_squared <- NA_real_
    row$status <- "insufficient_coverage"
    if (nrow(z) >= config$analysis["trend_min_quarters"] && length(unique(z$quarter)) == 4L) {
      z$elapsed_year <- (z$time_index - 1) / 4
      fit <- stats::lm(value ~ elapsed_year + factor(quarter), data = z, na.action = stats::na.fail)
      assert(all(is.finite(stats::coef(fit))), "Non-finite model coefficients.")
      row$slope_per_year <- unname(stats::coef(fit)["elapsed_year"])
      v <- hac_vcov(fit, z$time_index, as.integer(config$analysis["hac_lag"]))
      row$se_hac <- sqrt(v["elapsed_year", "elapsed_year"])
      v8 <- hac_vcov(fit, z$time_index, 8L)
      row$se_hac_lag8 <- sqrt(v8["elapsed_year", "elapsed_year"])
      row$ci_low <- row$slope_per_year - stats::qnorm(.975) * row$se_hac
      row$ci_high <- row$slope_per_year + stats::qnorm(.975) * row$se_hac
      row$p_value <- if (row$se_hac > 0) 2 * stats::pnorm(-abs(row$slope_per_year / row$se_hac)) else NA_real_
      row$p_value_lag8 <- if (row$se_hac_lag8 > 0) 2 * stats::pnorm(-abs(row$slope_per_year / row$se_hac_lag8)) else NA_real_
      e <- stats::residuals(fit)
      previous <- match(z$time_index - 1L, z$time_index)
      ok <- which(!is.na(previous))
      row$residual_acf1 <- if (length(ok) >= 3 && stats::sd(e[ok]) > 0 && stats::sd(e[previous[ok]]) > 0)
        stats::cor(e[ok], e[previous[ok]]) else NA_real_
      row$r_squared <- summary(fit)$r.squared
      row$status <- "estimated_descriptive"
      residual_tables[[g]] <- data.frame(region = z$region, variable = z$variable,
        time_index = z$time_index, year = z$year, quarter = z$quarter,
        observed = z$value, fitted = stats::fitted(fit), residual = e)
    }
    results[[g]] <- row
  }
  out <- do.call(rbind, results)
  out$p_bh <- stats::p.adjust(out$p_value, method = "BH")
  rownames(out) <- NULL
  list(trends = out, residuals = do.call(rbind, residual_tables))
}

regional_comparison <- function(grid) {
  pairs <- utils::combn(c("North", "Center", "South"), 2, simplify = FALSE)
  do.call(rbind, lapply(unique(grid$variable), function(v) {
    do.call(rbind, lapply(pairs, function(pair) {
      a <- grid[grid$variable == v & grid$region == pair[1], c("time_index", "value")]
      b <- grid[grid$variable == v & grid$region == pair[2], c("time_index", "value")]
      z <- merge(a, b, by = "time_index", suffixes = c("_a", "_b"))
      ok <- is.finite(z$value_a) & is.finite(z$value_b)
      delta <- z$value_a[ok] - z$value_b[ok]
      data.frame(variable = v, region_a = pair[1], region_b = pair[2],
                 n_paired_quarters = sum(ok), mean_difference_a_minus_b = safe_mean_monitoring(delta),
                 sd_paired_difference = if (length(delta) >= 2) stats::sd(delta) else NA_real_,
                 unit = grid$unit[match(v, grid$variable)], interpretation = "descriptive_paired_contrast")
    }))
  }))
}
