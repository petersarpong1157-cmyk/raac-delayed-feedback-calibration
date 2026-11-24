q43 <-
function(scores) {
  s <- sort(scores[is.finite(scores)])
  n <- length(s)
  
  if (n < 20L) {
    stop("Insufficient calibration residuals")
  }
  
  k <- ceiling((n + 1L) * (1 - alpha43))
  
  if (k > n) return(Inf)
  
  s[k]
}
make_expert_intervals43 <-
function(
    forecast_table,
    outcome_vault) {
  
  f <- copy(as.data.table(forecast_table))
  v <- copy(as.data.table(outcome_vault))
  
  stopifnot(
    !"actual" %in% names(f),
    !"release_date" %in% names(f),
    !"prediction" %in% names(v),
    uniqueN(f$row_id) == nrow(f),
    uniqueN(v$row_id) == nrow(v),
    setequal(f$row_id, v$row_id)
  )
  
  setorder(f, origin_date, row_id)
  
  cal <- f[partition == "calibration"]
  ev <- f[partition == "evaluation"]
  
  stopifnot(nrow(cal) > 0L, nrow(ev) > 0L)
  
  first_eval <- min(ev$origin_date)
  
  # Function accessible only within the release processor:
  # returns residuals from already available outcomes.
  get_history <- function(cutoff) {
    
    eligible_labels <- v[
      release_date < cutoff,
      .(row_id, release_date, actual)
    ]
    
    past_predictions <- f[
      partition %in% c("calibration", "evaluation") &
        origin_date < cutoff,
      .(
        row_id, origin_date, partition,
        regime, prediction
      )
    ]
    
    history <- merge(
      past_predictions,
      eligible_labels,
      by = "row_id",
      all = FALSE
    )
    
    stopifnot(
      all(history$origin_date < cutoff),
      all(history$release_date < cutoff),
      all(is.finite(history$actual))
    )
    
    history[
      ,
      residual := abs(actual - prediction)
    ]
    
    setorder(history, release_date, origin_date, row_id)
    
    history
  }
  
  # Fixed calibration is frozen at evaluation start.
  initial <- get_history(first_eval)
  initial <- initial[partition == "calibration"]
  
  stopifnot(nrow(initial) > 100L)
  
  fixed_global <- q43(initial$residual)
  
  fixed_cond <- vapply(0:1, function(g) {
    q43(initial[regime == g, residual])
  }, numeric(1))
  
  all_issued <- list()
  audits <- list()
  
  eval_origins <- sort(unique(ev$origin_date))
  
  for (i in seq_along(eval_origins)) {
    
    t <- eval_origins[i]
    current <- copy(ev[origin_date == t])
    
    # The same-day publication rule is strict.
    history <- get_history(t)
    
    rolling_global <- q43(
      tail(history$residual, global_window43)
    )
    
    rolling_cond <- vapply(0:1, function(g) {
      q43(tail(
        history[regime == g, residual],
        regime_window43
      ))
    }, numeric(1))
    
    stopifnot(
      all(is.finite(c(
        fixed_global, fixed_cond,
        rolling_global, rolling_cond
      )))
    )
    
    # Only predictor information and issued intervals
    # are placed in the forecast archive.
    current[
      ,
      q_Fixed_Global := fixed_global
    ]
    
    current[
      ,
      q_Fixed_Conditional :=
        fixed_cond[regime + 1L]
    ]
    
    current[
      ,
      q_Rolling_Global := rolling_global
    ]
    
    current[
      ,
      q_Rolling_Conditional :=
        rolling_cond[regime + 1L]
    ]
    
    qcols <- paste0("q_", expert_names43)
    
    for (m in expert_names43) {
      qcol <- paste0("q_", m)
      
      current[
        ,
        (paste0("lower_", m)) :=
          prediction - get(qcol)
      ]
      
      current[
        ,
        (paste0("upper_", m)) :=
          prediction + get(qcol)
      ]
    }
    
    stopifnot(
      all(is.finite(as.matrix(current[, ..qcols]))),
      all(as.matrix(current[, ..qcols]) > 0)
    )
    
    all_issued[[i]] <- current
    
    audits[[i]] <- data.table(
      forecast_origin = t,
      issued_forecasts = nrow(current),
      eligible_residuals = nrow(history),
      eligible_regime0 =
        sum(history$regime == 0L),
      eligible_regime1 =
        sum(history$regime == 1L),
      eligible_evaluation_residuals =
        sum(history$partition == "evaluation"),
      latest_available_release =
        max(history$release_date),
      same_day_residuals_used =
        sum(history$release_date >= t),
      fixed_global_radius = fixed_global,
      rolling_global_radius = rolling_global
    )
  }
  
  output <- rbindlist(all_issued)
  audit <- rbindlist(audits)
  
  stopifnot(
    nrow(output) == nrow(ev),
    all(audit$same_day_residuals_used == 0L),
    all(audit$latest_available_release <
          audit$forecast_origin),
    !"actual" %in% names(output),
    !"release_date" %in% names(output)
  )
  
  list(
    issued = output,
    audit = audit,
    initial_n = nrow(initial),
    initial_regime_counts = initial[
      , .N, by = regime
    ],
    fixed_global = fixed_global,
    fixed_conditional = fixed_cond
  )
}