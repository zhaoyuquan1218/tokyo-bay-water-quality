testthat::test_that("seasonal OLS recovers a known linear signal", {
  set.seed(109)
  x <- data.frame(time_index = 1:164, quarter = rep(1:4, 41))
  x$year <- 1981L + (x$time_index - 1L) %/% 4L
  x$value <- 2 + .02 * (x$time_index - 1) / 4 + c(0, .1, -.2, .3)[x$quarter] + rnorm(164, 0, .02)
  x$region <- "North"; x$layer <- "surface"; x$variable <- "DOC"; x$unit <- "mg C/L"
  cfg <- list(analysis = c(trend_min_quarters = 80, hac_lag = 4))
  result <- fit_trends(x, cfg)
  testthat::expect_equal(result$trends$slope_per_year, .02, tolerance = .001)
  testthat::expect_true(all(is.finite(as.matrix(result$trends[c("se_hac", "ci_low", "ci_high")]))))
})

testthat::test_that("HAC covariance agrees with an independent intercept-only calculation", {
  y <- c(1, 2, 4, 2, 3, 1, 6, 4, 2, 7, 4, 5)
  t <- c(1:6, 9:14) # two genuinely missing quarters
  fit <- stats::lm(y ~ 1)
  e <- y - mean(y); n <- length(e)
  expected <- sum(e^2)
  for (h in 1:4) {
    total <- 0
    for (i in seq_along(t)) for (j in seq_along(t))
      if (t[i] - t[j] == h) total <- total + e[i] * e[j]
    expected <- expected + 2 * (1 - h / 5) * total
  }
  expected <- expected / (n * (n - 1))
  testthat::expect_equal(unname(hac_vcov(fit, t, 4)[1, 1]), expected, tolerance = 1e-12)
  testthat::expect_false(isTRUE(all.equal(hac_vcov(fit, t, 4), hac_vcov(fit, seq_along(t), 4))))
})

testthat::test_that("insufficient data produces a documented status, not a fabricated estimate", {
  x <- data.frame(region = "North", layer = "surface", variable = "DOC", unit = "mg C/L",
                  time_index = 1:8, value = NA_real_, quarter = rep(1:4, 2), year = rep(1981:1982, each = 4))
  r <- fit_trends(x, list(analysis = c(trend_min_quarters = 80, hac_lag = 4)))
  testthat::expect_equal(r$trends$status, "insufficient_coverage")
  testthat::expect_true(is.na(r$trends$slope_per_year))
})

testthat::test_that("paired regional contrasts do not mix unmatched quarters", {
  x <- data.frame(region = c("North", "North", "Center", "South"), variable = "DOC",
                  time_index = c(1, 2, 1, 1), value = c(4, 100, 2, 1), unit = "mg C/L")
  r <- regional_comparison(x)
  testthat::expect_equal(r$mean_difference_a_minus_b[1], 2)
  testthat::expect_equal(r$n_paired_quarters[1], 1L)
})
