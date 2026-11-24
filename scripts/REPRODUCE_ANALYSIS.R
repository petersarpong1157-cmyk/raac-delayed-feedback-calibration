suppressPackageStartupMessages(library(data.table))

run_step66 <- function () 
{
    suppressPackageStartupMessages(library(data.table))
    script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
    stopifnot(length(script_arg) == 1L)
    script_path <- sub("^--file=", "", script_arg)
    pkg <- dirname(normalizePath(script_path, mustWork = TRUE))
    out <- file.path(pkg, "step66_analysis_reproduction")
    dir.create(out, recursive = TRUE, showWarnings = FALSE)
    read_rel <- function(rel) {
        p <- file.path(pkg, rel)
        stopifnot(file.exists(p))
        fread(file = p)
    }
    file_manifest <- read_rel("RELEASE_FILE_MANIFEST.csv")
    release_paths <- file.path(pkg, file_manifest$relative_path)
    stopifnot(nrow(file_manifest) == 30L, all(file.exists(release_paths)), uniqueN(file_manifest$relative_path) == 30L)
    actual_md5 <- unname(tools::md5sum(release_paths))
    manifest_ok <- all(!is.na(actual_md5) & actual_md5 == file_manifest$copied_md5)
    stopifnot(manifest_ok)
    metrics <- read_rel("results/step54_independent_benchmark/all_replication_metrics.csv")
    subgroups <- read_rel("results/step54_independent_benchmark/all_replication_subgroups.csv")
    original_methods <- read_rel("results/step55_statistical_analysis/seven_method_summary.csv")
    original_primary <- read_rel("results/step55_statistical_analysis/primary_raac_vs_fixed_global.csv")
    original_secondary <- read_rel("results/step55_statistical_analysis/secondary_raac_comparisons.csv")
    original_regimes <- read_rel("results/step56_regime_reliability/regime_method_summary.csv")
    seeds <- read_rel("results/step52_final_benchmark/independent_replication_seeds.csv")
    stopifnot(nrow(metrics) == 5600L, nrow(subgroups) == 11200L, nrow(seeds) == 800L, uniqueN(metrics, by = c("scenario", 
        "replication", "method")) == 5600L, uniqueN(subgroups, by = c("scenario", "replication", "method", "regime")) == 
        11200L)
    reproduced_methods <- metrics[, list(replications = .N, mean_interval_score = mean(mean_score), sd_interval_score = sd(mean_score), 
        mean_coverage = mean(coverage), mean_width = mean(mean_width), mean_minimum_regime_coverage = mean(minimum_regime_coverage), 
        mean_worst_regime_shortfall = mean(worst_regime_shortfall)), by = list(scenario, method)]
    method_columns <- c("mean_interval_score", "sd_interval_score", "mean_coverage", "mean_width", "mean_minimum_regime_coverage", 
        "mean_worst_regime_shortfall")
    method_comparison <- merge(reproduced_methods, original_methods, by = c("scenario", "method"), suffixes = c("_new", "_old"))
    stopifnot(nrow(method_comparison) == 28L, all(method_comparison$replications_new == method_comparison$replications_old))
    method_error <- max(vapply(method_columns, function(x) {
        max(abs(method_comparison[[paste0(x, "_new")]] - method_comparison[[paste0(x, "_old")]]))
    }, numeric(1)))
    raac <- metrics[method == "RAAC", list(scenario, replication, raac_score = mean_score)]
    comparators <- setdiff(unique(metrics$method), "RAAC")
    paired_ci <- function(x) {
        stopifnot(length(x) == 200L, all(is.finite(x)))
        estimate <- mean(x)
        se <- sd(x)/sqrt(length(x))
        h <- qt(0.975, df = 199L) * se
        list(n = length(x), difference = estimate, standard_error = se, ci_lower = estimate - h, ci_upper = estimate + h, fraction_raac_better = mean(x < 
            0))
    }
    reproduced_secondary <- rbindlist(lapply(comparators, function(comp) {
        other <- metrics[method == comp, list(scenario, replication, other_score = mean_score)]
        paired <- merge(raac, other, by = c("scenario", "replication"))
        stopifnot(nrow(paired) == 800L)
        paired[, `:=`(difference, raac_score - other_score)]
        ans <- paired[, paired_ci(difference), by = scenario]
        ans[, `:=`(comparator, comp)]
        ans
    }))
    reproduced_primary <- reproduced_secondary[comparator == "Fixed_Global"]
    compare_pairs <- function(new, old, keys, cols) {
        z <- merge(new, old, by = keys, suffixes = c("_new", "_old"))
        stopifnot(nrow(z) == nrow(new), nrow(z) == nrow(old))
        max(vapply(cols, function(x) max(abs(z[[paste0(x, "_new")]] - z[[paste0(x, "_old")]])), numeric(1)))
    }
    pair_columns <- c("difference", "standard_error", "ci_lower", "ci_upper", "fraction_raac_better")
    primary_error <- compare_pairs(reproduced_primary, original_primary, "scenario", pair_columns)
    secondary_error <- compare_pairs(reproduced_secondary, original_secondary, c("scenario", "comparator"), pair_columns)
    reproduced_regimes <- subgroups[, list(replications = .N, mean_coverage = mean(regime_coverage), pooled_coverage = weighted.mean(regime_coverage, 
        regime_n), sd_coverage = sd(regime_coverage), average_regime_n = mean(regime_n), fraction_replications_below_90 = mean(regime_coverage < 
        0.9), minimum_observed_coverage = min(regime_coverage)), by = list(scenario, method, regime)]
    reproduced_regimes[, `:=`(gap_from_target, mean_coverage - 0.9)]
    regime_error <- compare_pairs(reproduced_regimes, original_regimes, c("scenario", "method", "regime"), c("mean_coverage", 
        "pooled_coverage", "sd_coverage", "average_regime_n", "fraction_replications_below_90", "minimum_observed_coverage", 
        "gap_from_target"))
    recon <- subgroups[, list(n_from_regimes = sum(regime_n), coverage_from_regimes = weighted.mean(regime_coverage, regime_n)), 
        by = list(scenario, replication, method)]
    matched <- merge(recon, metrics[, list(scenario, replication, method, n, coverage)], by = c("scenario", "replication", "method"))
    coverage_error <- max(abs(matched$coverage_from_regimes - matched$coverage))
    count_ok <- (nrow(matched) == 5600L && all(matched$n_from_regimes == matched$n))
    tolerance <- 1e-10
    audit <- data.table(test = c("All 30 release files match manifest MD5", "Benchmark summary dimensions correct", "Seven-method table reproduced", 
        "Primary paired contrasts reproduced", "Secondary paired contrasts reproduced", "Regime coverage summary reproduced", 
        "Subgroup counts reconcile", "Subgroup coverage reconciles"), passed = c(manifest_ok, nrow(reproduced_methods) == 
        28L && nrow(reproduced_primary) == 4L && nrow(reproduced_secondary) == 24L && nrow(reproduced_regimes) == 56L, method_error < 
        tolerance, primary_error < tolerance, secondary_error < tolerance, regime_error < tolerance, count_ok, coverage_error < 
        tolerance))
    errors <- data.table(comparison = c("method_summary", "primary_contrasts", "secondary_contrasts", "regime_summary", "coverage_reconstruction"), 
        maximum_absolute_error = c(method_error, primary_error, secondary_error, regime_error, coverage_error))
    fwrite(audit, file.path(out, "clean_session_audit.csv"))
    fwrite(errors, file.path(out, "numerical_reproduction_errors.csv"))
    fwrite(reproduced_methods, file.path(out, "reproduced_method_summary.csv"))
    fwrite(reproduced_primary, file.path(out, "reproduced_primary_contrasts.csv"))
    fwrite(reproduced_regimes, file.path(out, "reproduced_regime_summary.csv"))
    capture.output(sessionInfo(), file = file.path(out, "clean_session_info.txt"))
    cat("\n====================================\n")
    cat("RANF STEP 66 — CLEAN SESSION AUDIT\n")
    cat("====================================\n")
    cat("\nPACKAGE DIRECTORY:\n")
    print(pkg)
    cat("\nNUMERICAL REPRODUCTION ERRORS:\n")
    print(errors)
    cat("\nCLEAN-SESSION AUDIT:\n")
    print(audit)
    if (!all(audit$passed)) {
        stop("Step 66: One or more checks failed.")
    }
    cat("\nPASS: Archived statistical tables reproduced.\n")
    cat("No simulations or model fitting performed.\n")
    invisible(audit)
}

run_step66()