interval_score49 <-
function(y, lower, upper,
                             alpha = 0.10) {
  
  stopifnot(
    length(y) == length(lower),
    length(y) == length(upper),
    all(is.finite(y)),
    all(is.finite(lower)),
    all(is.finite(upper)),
    all(lower <= upper),
    alpha > 0,
    alpha < 1
  )
  
  (upper - lower) +
    (2 / alpha) * pmax(lower - y, 0) +
    (2 / alpha) * pmax(y - upper, 0)
}
evaluate_intervals49 <-
function(d) {
  
  d <- copy(as.data.table(d))
  
  required <- c(
    "scenario", "replication", "method",
    "row_id", "regime", "y", "lower", "upper"
  )
  
  stopifnot(
    all(required %in% names(d)),
    !anyNA(d[, ..required]),
    uniqueN(
      d,
      by = c(
        "scenario", "replication",
        "method", "row_id"
      )
    ) == nrow(d)
  )
  
  d[, interval_score := interval_score49(
    y, lower, upper
  )]
  
  d[, covered := as.integer(
    y >= lower & y <= upper
  )]
  
  d[, width := upper - lower]
  
  keys <- c("scenario", "replication", "method")
  
  summary <- d[
    ,
    .(
      n = .N,
      mean_score = mean(interval_score),
      coverage = mean(covered),
      mean_width = mean(width)
    ),
    by = keys
  ]
  
  subgroup <- d[
    ,
    .(
      regime_n = .N,
      regime_coverage = mean(covered)
    ),
    by = c(keys, "regime")
  ]
  
  worst <- subgroup[
    ,
    .(
      minimum_regime_coverage =
        min(regime_coverage),
      worst_regime_shortfall =
        max(
          0,
          0.90 - min(regime_coverage)
        )
    ),
    by = keys
  ]
  
  summary <- merge(
    summary, worst,
    by = keys,
    sort = FALSE
  )
  
  list(
    summary = summary,
    subgroup = subgroup
  )
}
paired_ci49 <-
function(differences) {
  
  x <- as.numeric(differences)
  
  stopifnot(
    length(x) >= 2L,
    all(is.finite(x))
  )
  
  n <- length(x)
  estimate <- mean(x)
  se <- sd(x) / sqrt(n)
  
  critical <- qt(0.975, df = n - 1L)
  
  data.table(
    replications = n,
    mean_difference = estimate,
    standard_error = se,
    ci_lower = estimate - critical * se,
    ci_upper = estimate + critical * se
  )
}
paired_methods49 <-
function(summary,
                             comparator = "Fixed_Global",
                             target = "RAAC") {
  
  d <- copy(as.data.table(summary))
  
  base <- d[
    method == comparator,
    .(
      scenario, replication,
      base_score = mean_score
    )
  ]
  
  candidate <- d[
    method == target,
    .(
      scenario, replication,
      candidate_score = mean_score
    )
  ]
  
  paired <- merge(
    candidate,
    base,
    by = c("scenario", "replication")
  )
  
  stopifnot(
    nrow(paired) == nrow(candidate),
    nrow(paired) == nrow(base)
  )
  
  paired[, difference :=
           candidate_score - base_score]
  
  paired[
    ,
    paired_ci49(difference),
    by = scenario
  ]
}