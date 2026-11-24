# RAAC GitHub statistical reproduction; 800 archived replications.
# Run from any directory: Rscript --vanilla scripts/REPRODUCE_GITHUB_ANALYSIS.R
# This reprocesses archived CSVs; it DOES NOT regenerate simulated outcomes.
suppressPackageStartupMessages(library(data.table))

script_args <- grep("^--file=", commandArgs(trailingOnly=FALSE), value=TRUE)
if (length(script_args) != 1L) stop("Run with Rscript --vanilla (not source()).")
this_file <- normalizePath(sub("^--file=", "", script_args), mustWork=TRUE)
repo <- dirname(dirname(this_file))
out <- file.path(repo, "reproduction_outputs")
dir.create(out, showWarnings=FALSE, recursive=TRUE)

read_rel <- function(path) {
  f <- file.path(repo,path)
  if (!file.exists(f)) stop("Missing repository input: ", path)
  fread(f)
}
metrics <- read_rel("results/step54_independent_benchmark/all_replication_metrics.csv")
subgroups <- read_rel("results/step54_independent_benchmark/all_replication_subgroups.csv")
original_methods <- read_rel("results/step55_statistical_analysis/seven_method_summary.csv")
original_primary <- read_rel("results/step55_statistical_analysis/primary_raac_vs_fixed_global.csv")
original_secondary <- read_rel("results/step55_statistical_analysis/secondary_raac_comparisons.csv")
original_regimes <- read_rel("results/step56_regime_reliability/regime_method_summary.csv")
seeds <- read_rel("results/step52_final_benchmark/independent_replication_seeds.csv")

shape_ok <- nrow(metrics) == 5600L && nrow(subgroups) == 11200L &&
  nrow(seeds) == 800L &&
  uniqueN(metrics,by=c("scenario","replication","method"))==5600L &&
  uniqueN(subgroups,by=c("scenario","replication","method","regime"))==11200L &&
  uniqueN(seeds,by=c("scenario","replication"))==800L
stopifnot(shape_ok)

method_summary <- metrics[,list(
  replications=.N,mean_interval_score=mean(mean_score),
  sd_interval_score=sd(mean_score),mean_coverage=mean(coverage),
  mean_width=mean(mean_width),
  mean_minimum_regime_coverage=mean(minimum_regime_coverage),
  mean_worst_regime_shortfall=mean(worst_regime_shortfall)),
  by=list(scenario,method)]
metrics_cols <- c("mean_interval_score","sd_interval_score","mean_coverage",
"mean_width","mean_minimum_regime_coverage","mean_worst_regime_shortfall")
compare_pairs <- function(new,old,keys,cols) {
  joined <- merge(new,old,by=keys,suffixes=c("_new","_old"))
  stopifnot(nrow(joined)==nrow(new),nrow(joined)==nrow(old))
  max(vapply(cols, function(col) {
    max(abs(joined[[paste0(col,"_new")]]-joined[[paste0(col,"_old")]]))
  },numeric(1)))
}
method_error <- compare_pairs(method_summary, original_methods,
c("scenario","method"), metrics_cols)
stopifnot(all(method_summary$replications==200L))
raac <- metrics[method=="RAAC",list(scenario,replication,raac_score=mean_score)]
paired_ci <- function(x) {
  stopifnot(length(x)==200L,all(is.finite(x)))
  est <- mean(x); se <- sd(x)/sqrt(length(x))
  delta <- qt(.975,df=length(x)-1L)*se
  list(n=length(x),difference=est,standard_error=se,
       ci_lower=est-delta,ci_upper=est+delta,
       fraction_raac_better=mean(x<0))
}
comparators <- setdiff(unique(metrics$method),"RAAC")
secondary <- rbindlist(lapply(comparators,function(comp) {
  base <- metrics[method==comp,list(scenario,replication,other_score=mean_score)]
  paired <- merge(raac,base,by=c("scenario","replication"))
  stopifnot(nrow(paired)==800L)
  paired[,difference:=raac_score-other_score]
  ret <- paired[,paired_ci(difference),by=scenario]
  ret[,comparator:=comp]
  ret
}))
primary <- secondary[comparator=="Fixed_Global"]
pair_cols <- c("difference","standard_error","ci_lower",
               "ci_upper","fraction_raac_better")
primary_error <- compare_pairs(primary,original_primary,"scenario",pair_cols)
secondary_error <- compare_pairs(secondary,original_secondary,
                               c("scenario","comparator"),pair_cols)

regimes <- subgroups[,list(
  replications=.N,mean_coverage=mean(regime_coverage),
  pooled_coverage=weighted.mean(regime_coverage,regime_n),
  sd_coverage=sd(regime_coverage),
  average_regime_n=mean(regime_n),
  fraction_replications_below_90=mean(regime_coverage<.90),
  minimum_observed_coverage=min(regime_coverage)),
  by=list(scenario,method,regime)]
regimes[,gap_from_target:=mean_coverage-.9]
regime_cols <- c("mean_coverage","pooled_coverage","sd_coverage",
                "average_regime_n","fraction_replications_below_90",
                "minimum_observed_coverage","gap_from_target")
regime_error <- compare_pairs(regimes,original_regimes,
                              c("scenario","method","regime"),regime_cols)
recon <- subgroups[,list(n_from_regimes=sum(regime_n),
                         coverage_from_regimes=weighted.mean(regime_coverage,regime_n)),
                   by=list(scenario,replication,method)]
joined <- merge(recon,metrics[,list(scenario,replication,method,n,coverage)],
                by=c("scenario","replication","method"))
count_ok <- nrow(joined)==5600L && all(joined$n_from_regimes==joined$n)
coverage_error <- max(abs(joined$coverage_from_regimes-joined$coverage))
errors <- data.table(comparison=c("method_summary","primary_contrasts",
 "secondary_contrasts","regime_summary","coverage_reconstruction"),
 maximum_absolute_error=c(method_error,primary_error,secondary_error,
                          regime_error,coverage_error))
tol <- 1e-10
audit <- data.table(
 test=c("Input dimensions and keys","Seven method summary",
        "Primary paired contrasts","Secondary paired contrasts",
        "Regime coverage table","Subgroup observation counts",
        "Marginal/subgroup coverage reconciliation"),
 passed=c(shape_ok,nrow(method_summary)==28L && method_error<tol,
          nrow(primary)==4L && primary_error<tol,
          nrow(secondary)==24L && secondary_error<tol,
          nrow(regimes)==56L && regime_error<tol,
          count_ok,coverage_error<tol))
fwrite(errors,file.path(out,"github_numerical_errors.csv"))
fwrite(audit,file.path(out,"github_analysis_audit.csv"))
fwrite(method_summary,file.path(out,"github_method_summary.csv"))
fwrite(primary,file.path(out,"github_primary_contrasts.csv"))
fwrite(regimes,file.path(out,"github_regime_summary.csv"))
capture.output(sessionInfo(),file=file.path(out,"github_session_info.txt"))
print(errors)
print(audit)
if(!all(audit$passed))stop("Statistical reprocessing did not match archived reference tables.")
cat("PASS: GitHub archived tables statistically reproduced. No simulations regenerated.\n")
