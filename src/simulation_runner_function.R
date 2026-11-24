run_simulation50 <-
function(
    scenario_name,
    replication_id,
    engine,
    config,
    scenarios,
    seeds) {
  
  # Read the prespecified seed
  plan <- seeds[
    scenario == scenario_name &
      replication == replication_id
  ]
  
  stopifnot(nrow(plan) == 1L)
  
  # 1. Generate economic observations
  sim <- engine$generate_raac_panel(
    scenario_name,
    plan$seed,
    config,
    scenarios
  )
  
  x <- copy(sim$predictor_table)
  v <- copy(sim$outcome_vault)
  
  stopifnot(
    !"actual" %in% names(x),
    !"release_date" %in% names(x)
  )
  
  # 2. Estimate linear model using eligible training labels
  first_cal <- min(
    x[partition == "calibration", origin_date]
  )
  
  training <- engine$build_training(
    x, v, first_cal
  )
  
  model <- lm(
    actual ~ revenue_signal +
      supplier_signal + price_signal,
    data = training
  )
  
  # 3. Issue point predictions
  predictions <- engine$issue_predictions(
    x, model
  )
  
  predictions <- predictions[
    partition %in% c(
      "calibration", "evaluation"
    )
  ]
  
  v <- v[
    row_id %in% predictions$row_id
  ]
  
  stopifnot(
    setequal(predictions$row_id, v$row_id)
  )
  
  # 4. Issue the four expert intervals
  experts <- engine$make_expert_intervals43(
    predictions, v
  )
  
  qcols <- paste0(
    "q_",
    c(
      "Fixed_Global",
      "Fixed_Conditional",
      "Rolling_Global",
      "Rolling_Conditional"
    )
  )
  
  e <- copy(experts$issued)
  
  # 5. Prepare data for the frozen RAAC engine
  raac_x <- e[
    ,
    c(
      "row_id", "origin_index",
      "origin_date", "prediction", qcols
    ),
    with = FALSE
  ]
  
  setnames(
    raac_x,
    c("row_id", "origin_index", "origin_date"),
    c("id", "origin_id", "origin")
  )
  
  raac_y <- v[
    row_id %in% raac_x$id,
    .(
      id = row_id,
      release = release_date,
      actual
    )
  ]
  
  raac <- engine$run_raac_isolated(
    raac_x,
    raac_y,
    eta = config$raac_eta,
    loss_scale = config$raac_loss_scale,
    loss_cap = config$raac_loss_cap
  )
  
  # 6. Issue the delayed-feedback ACI intervals
  aci <- engine$run_aci45(
    predictions,
    v,
    gamma = 0.01
  )
  
  # 7. Assemble seven methods using common IDs
  base <- e[
    ,
    .(
      row_id,
      origin_index,
      origin_date,
      regime,
      prediction
    )
  ]
  
  make_method <- function(m, radius) {
    
    stopifnot(
      length(radius) == nrow(base),
      all(is.finite(radius)),
      all(radius > 0)
    )
    
    z <- copy(base)
    
    z[, method := m]
    z[, lower := prediction - radius]
    z[, upper := prediction + radius]
    
    z[, prediction := NULL]
    
    z
  }
  
  results <- list()
  
  for (m in expected_methods[1:4]) {
    
    results[[m]] <- make_method(
      m,
      e[[paste0("q_", m)]]
    )
  }
  
  # Equal-weight ensemble, without fitting or tuning
  equal_radius <- rowMeans(
    as.matrix(e[, ..qcols])
  )
  
  results[["Equal_Weight"]] <- make_method(
    "Equal_Weight",
    equal_radius
  )
  
  # Align RAAC output to the common evaluation IDs
  raac_order <- match(
    base$row_id,
    raac$issued$id
  )
  
  stopifnot(!anyNA(raac_order))
  
  results[["RAAC"]] <- make_method(
    "RAAC",
    raac$issued$raac_radius[raac_order]
  )
  
  # Align ACI output to the same evaluation IDs
  aci_order <- match(
    base$row_id,
    aci$issued$row_id
  )
  
  stopifnot(!anyNA(aci_order))
  
  results[["Cohort_Delayed_ACI"]] <- make_method(
    "Cohort_Delayed_ACI",
    aci$issued$aci_radius[aci_order]
  )
  
  intervals <- rbindlist(
    results,
    use.names = TRUE
  )
  
  intervals[, scenario := scenario_name]
  intervals[, replication := replication_id]
  
  setcolorder(
    intervals,
    c(
      "scenario", "replication", "method",
      "row_id", "origin_index", "origin_date",
      "regime", "lower", "upper"
    )
  )
  
  # No actual outcomes may enter the interval table
  stopifnot(
    !"actual" %in% names(intervals),
    !"release_date" %in% names(intervals)
  )
  
  # 8. Method-level observation parity
  parity <- intervals[
    ,
    .(
      n = .N,
      unique_ids = uniqueN(row_id),
      unique_origins = uniqueN(origin_index),
      minimum_width = min(upper - lower)
    ),
    by = method
  ]
  
  common_ids <- sort(
    unique(base$row_id)
  )
  
  id_parity <- all(vapply(
    expected_methods,
    function(m) {
      identical(
        sort(intervals[method == m, row_id]),
        common_ids
      )
    },
    logical(1)
  ))
  
  # Chronology for both adaptive algorithms
  chronology <- (
    nrow(raac$updates) > 0L &&
      nrow(aci$updates) > 0L &&
      all(
        raac$updates$last_cohort_release <
          raac$updates$update_at
      ) &&
      all(
        aci$updates$last_release <
          aci$updates$update_at
      )
  )
  
  list(
    intervals = intervals,
    parity = parity,
    id_parity = id_parity,
    chronology = chronology,
    training_n = nrow(training),
    experts = experts,
    raac = raac,
    aci = aci
  )
}