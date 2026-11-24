# Recovered frozen-function definitions (source-extract provenance).
# Requires original benchmark configuration; not a standalone executable.
# Compare against workstation originals before external reproduction.

generate_raac_panel <- function(scenario_name, seed, config, scenario_table) {
    set.seed(seed)
    scenario <- scenario_table[scenario == scenario_name]
    stopifnot(nrow(scenario) == 1L)
    T <- config$total_origins
    G <- config$sector_size_groups
    groups <- data.table(group_id = seq_len(G), regime = as.integer(seq_len(G) > 50L), group_effect = rnorm(G, 0, 2))
    stopifnot(G == 60L)
    rho <- config$temporal_ar1
    shock_sd <- config$shared_shock_sd
    economic_state <- numeric(T)
    economic_state[1] <- rnorm(1, 0, shock_sd)
    for (t in 2:T) {
        economic_state[t] <- rho * economic_state[t - 1L] + sqrt(1 - rho^2) * rnorm(1, 0, shock_sd)
    }
    sigma1 <- rep(scenario$baseline_sigma1, T)
    eval_index <- seq.int(config$training_origins + config$calibration_origins + 1L, T)
    n_eval <- length(eval_index)
    progress <- seq_len(n_eval)/n_eval
    if (scenario_name == "Sudden_Volatility_Increase") {
        sigma1[eval_index] <- scenario$peak_sigma1
    }
    else if (scenario_name == "Gradual_Volatility_Increase") {
        sigma1[eval_index] <- scenario$baseline_sigma1 + (scenario$peak_sigma1 - scenario$baseline_sigma1) * progress
    }
    else if (scenario_name == "Volatility_Reversal") {
        trajectory <- 1 - abs(2 * progress - 1)
        sigma1[eval_index] <- scenario$baseline_sigma1 + (scenario$peak_sigma1 - scenario$baseline_sigma1) * trajectory
    }
    group_error <- numeric(G)
    pieces <- vector("list", T)
    for (t in seq_len(T)) {
        d <- copy(groups)
        d[, `:=`(origin_index, t)]
        d[, `:=`(origin_date, as.IDate("2030-01-01") + 14L * (t - 1L))]
        d[, `:=`(revenue_signal, 30 + 1.5 * economic_state[t] + 0.7 * group_effect + rnorm(.N, 0, 3))]
        d[, `:=`(supplier_signal, 8 + 0.8 * economic_state[t] + rnorm(.N, 0, 2))]
        d[, `:=`(price_signal, 36 + 0.9 * economic_state[t] + rnorm(.N, 0, 3))]
        innovation_sd <- ifelse(d$regime == 1L, sigma1[t], scenario$baseline_sigma0)
        group_error <- (0.35 * group_error + sqrt(1 - 0.35^2) * rnorm(G, 0, innovation_sd))
        d[, `:=`(actual, 15 + 0.45 * revenue_signal + 0.08 * supplier_signal + 0.12 * price_signal + group_effect + economic_state[t] + 
            group_error)]
        d[, `:=`(observed, runif(.N) < ifelse(regime == 1L, 0.6, 0.95))]
        d[, `:=`(delay_cycles, sample(c(1L, 2L, 3L), size = .N, replace = TRUE, prob = c(0.7, 0.2, 0.1)))]
        d[, `:=`(release_date, origin_date + 14L * delay_cycles)]
        d[, `:=`(partition, fifelse(t <= config$training_origins, "train", fifelse(t <= config$training_origins + config$calibration_origins, 
            "calibration", "evaluation")))]
        pieces[[t]] <- d
    }
    panel <- rbindlist(pieces)
    panel[, `:=`(row_id, .I)]
    stopifnot(nrow(panel) == T * G, all(panel$release_date > panel$origin_date), all(is.finite(panel$actual)), all(is.finite(panel$revenue_signal)))
    eligible <- copy(panel[observed == TRUE])
    predictor_table <- eligible[, .(row_id, group_id, regime, origin_index, origin_date, partition, revenue_signal, supplier_signal, 
        price_signal)]
    outcome_vault <- eligible[, .(row_id, release_date, actual)]
    list(predictor_table = predictor_table, outcome_vault = outcome_vault, design_audit = panel[, .(expected_rows = .N, observed_rows = sum(observed), 
        missing_rows = sum(!observed)), by = .(partition, regime)], volatility_schedule = data.table(origin_index = seq_len(T), 
        regime1_sigma = sigma1))
}
