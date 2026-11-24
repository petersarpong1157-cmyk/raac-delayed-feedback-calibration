benchmark_rep52 <-
function(
    scenario_name,
    replication_id,
    engine,
    config,
    scenarios,
    seeds,
    scoring_function) {
  
  # Issue all seven methods' intervals.
  # Frozen methods are not modified.
  run <- engine$run_simulation50(
    scenario_name,
    replication_id,
    engine,
    config,
    scenarios,
    seeds
  )
  
  d <- copy(run$intervals)
  
  stopifnot(
    !"actual" %in% names(d),
    !"y" %in% names(d),
    uniqueN(d$method) == 7L
  )
  
  # Independently regenerate the identical
  # synthetic data from the locked replication seed.
  # Only the evaluation component can see actuals.
  plan <- seeds[
    scenario == scenario_name &
      replication == replication_id
  ]
  
  stopifnot(nrow(plan) == 1L)
  
  sim <- engine$generate_raac_panel(
    scenario_name,
    plan$seed,
    config,
    scenarios
  )
  
  evaluation_ids <- sim$predictor_table[
    partition == "evaluation",
    row_id
  ]
  
  outcomes <- sim$outcome_vault[
    row_id %in% evaluation_ids,
    .(row_id, y = actual)
  ]
  
  # Every issued evaluation ID must have
  # exactly one matching outcome.
  stopifnot(
    uniqueN(outcomes$row_id) ==
      nrow(outcomes),
    setequal(
      unique(d$row_id),
      outcomes$row_id
    ),
    nrow(d) == 7L * nrow(outcomes)
  )
  
  # Attach outcomes ONLY after intervals
  # from all methods have been issued.
  scored_input <- merge(
    d,
    outcomes,
    by = "row_id",
    all.x = TRUE,
    sort = FALSE
  )
  
  stopifnot(
    nrow(scored_input) == nrow(d),
    !anyNA(scored_input$y),
    uniqueN(
      scored_input,
      by = c("method", "row_id")
    ) == nrow(scored_input)
  )
  
  # Evaluate every method on the SAME rows.
  scored <- scoring_function(
    scored_input
  )
  
  stopifnot(
    nrow(scored$summary) == 7L,
    all(scored$summary$n ==
          nrow(outcomes))
  )
  
  list(
    summary = scored$summary,
    subgroup = scored$subgroup,
    evaluation_n = nrow(outcomes),
    training_n = run$training_n
  )
}