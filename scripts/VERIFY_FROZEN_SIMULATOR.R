# Single-replication-per-scenario frozen simulator verification.
# Run: Rscript --vanilla scripts/VERIFY_FROZEN_SIMULATOR.R
# Compares 4 x 7 = 28 regenerated method summaries and 56 regime summaries
# with the archived benchmark using the final seed plan.
# NOT a rerun of all 800 replications.
suppressPackageStartupMessages(library(data.table))

args <- grep("^--file=", commandArgs(trailingOnly=FALSE),value=TRUE)
stopifnot(length(args)==1L)
script_path <- normalizePath(sub("^--file=","",args),mustWork=TRUE)
root <- dirname(dirname(script_path))
read_rel <- function(rel) {
  p <- file.path(root,rel)
  if(!file.exists(p)) stop("Missing source/data: ", rel)
  fread(p)
}
config_file <- file.path(root,"results/step40_evaluation_design/frozen_simulation_configuration.rds")
if(!file.exists(config_file)) stop("Missing frozen configuration")
config <- readRDS(config_file)
scenarios <- read_rel("results/step40_evaluation_design/prespecified_scenarios.csv")
seeds <- read_rel("results/step52_final_benchmark/independent_replication_seeds.csv")
ref_methods <- read_rel("results/step54_independent_benchmark/all_replication_metrics.csv")
ref_subgroups <- read_rel("results/step54_independent_benchmark/all_replication_subgroups.csv")

required_config <- c("nominal_coverage","global_window","regime_window",
                     "raac_eta","raac_loss_scale","raac_loss_cap")
if(!all(required_config %in% names(config))) {
  stop("Missing frozen config entries: ",
       paste(setdiff(required_config,names(config)),collapse=", "))
}
stopifnot(isTRUE(all.equal(as.numeric(config$nominal_coverage),0.90)))
stopifnot(all(c("scenario","replication","seed") %in% names(seeds)))
stopifnot(all(c("scenario","baseline_sigma0","baseline_sigma1","peak_sigma1")
              %in% names(scenarios)))
stopifnot(nrow(seeds)==800L,nrow(scenarios)==4L)
selected <- seeds[replication==1L]
stopifnot(nrow(selected)==4L,uniqueN(selected$scenario)==4L,
          setequal(selected$scenario,scenarios$scenario))

engine <- new.env(parent=globalenv())
engine$alpha43 <- 1-as.numeric(config$nominal_coverage)
engine$global_window43 <- as.integer(config$global_window)
engine$regime_window43 <- as.integer(config$regime_window)
engine$expert_names43 <- c("Fixed_Global","Fixed_Conditional",
  "Rolling_Global","Rolling_Conditional")
engine$target_alpha45 <- 0.10
engine$gamma45 <- 0.01
engine$min_alpha45 <- 0.02
engine$max_alpha45 <- 0.30
engine$window45 <- 100L
engine$expected_methods <- c(engine$expert_names43,"Equal_Weight",
                             "RAAC","Cohort_Delayed_ACI")

source_files <- c("frozen_generator_function.R",
 "point_forecast_functions.R","expert_calibration_functions.R",
 "RAAC_frozen_engine.R","aci_comparator_functions.R",
 "simulation_runner_function.R","frozen_scoring_functions.R",
 "benchmark_replication_function.R")
for (name in source_files) {
  path <- file.path(root,"src",name)
  if(!file.exists(path)) stop("Missing frozen source: ",path)
  parse(file=path)
  sys.source(path,envir=engine)
}
stopifnot(all(vapply(c("generate_raac_panel","build_training",
 "issue_predictions","make_expert_intervals43","run_raac_isolated",
 "run_aci45","run_simulation50","evaluate_intervals49","benchmark_rep52"),
 function(fn) is.function(engine[[fn]]),logical(1))))

# Run every scenario using the precommitted final replication-1 seed.
# Original simulator and scorer functions are called unchanged.
method_list <- vector("list",nrow(selected))
group_list <- vector("list",nrow(selected))
for (i in seq_len(nrow(selected))) {
  name <- selected$scenario[i]
  cat(sprintf("Regenerating scenario %s, replication 1, seed %d\n",
              name,selected$seed[i]))
  run <- engine$benchmark_rep52(
    scenario_name=name,replication_id=1L,engine=engine,
    config=config,scenarios=scenarios,seeds=seeds,
    scoring_function=engine$evaluate_intervals49)
  stopifnot(isTRUE(run$id_parity) || is.null(run$id_parity))
  method_list[[i]] <- run$summary
  group_list[[i]] <- run$subgroup
}
regen_methods <- rbindlist(method_list, use.names=TRUE)
regen_groups <- rbindlist(group_list,use.names=TRUE)
expect_methods <- ref_methods[replication==1L]
expect_groups <- ref_subgroups[replication==1L]
stopifnot(nrow(regen_methods)==28L,nrow(regen_groups)==56L,
          nrow(expect_methods)==28L,nrow(expect_groups)==56L)
keys <- c("scenario","replication","method")
method_fields <- c("n","mean_score","coverage","mean_width",
                   "minimum_regime_coverage","worst_regime_shortfall")
m <- merge(regen_methods,expect_methods,by=keys,suffixes=c("_new","_archive"))
stopifnot(nrow(m)==28L)
method_errors <- vapply(method_fields,function(k)
  max(abs(m[[paste0(k,"_new")]]-m[[paste0(k,"_archive")]])),numeric(1))
g <- merge(regen_groups,expect_groups,by=c(keys,"regime"),
           suffixes=c("_new","_archive"))
stopifnot(nrow(g)==56L)
group_fields <- c("regime_n","regime_coverage")
group_errors <- vapply(group_fields,function(k)
  max(abs(g[[paste0(k,"_new")]]-g[[paste0(k,"_archive")]])),numeric(1))
errors <- data.table(variable=c(paste0("method_",names(method_errors)),
                                  paste0("regime_",names(group_errors))),
                     max_absolute_difference=c(unname(method_errors),
                                               unname(group_errors)))
tolerance <- 1e-10
audit <- data.table(test=c(
  "Four final-seed scenarios regenerated",
  "Method-level rows and keys align",
  "Regime-level rows and keys align",
  "Method-level values match archived results",
  "Regime-level values match archived results"),
 passed=c(nrow(selected)==4L,nrow(m)==28L,nrow(g)==56L,
          all(method_errors<tolerance),all(group_errors<tolerance)))
out <- file.path(root,"reproduction_outputs")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
fwrite(errors,file.path(out,"frozen_simulator_max_errors.csv"))
fwrite(audit,file.path(out,"frozen_simulator_audit.csv"))
fwrite(regen_methods,file.path(out,"frozen_simulator_regenerated_metrics.csv"))
fwrite(regen_groups,file.path(out,"frozen_simulator_regenerated_subgroups.csv"))
capture.output(sessionInfo(),file=file.path(out,"frozen_simulator_session_info.txt"))
print(errors);print(audit)
if(!all(audit$passed))stop("Frozen simulator check FAILED")
cat("PASS: Four single-replication scenarios reproduced against archive.\n",
    "This does not reproduce all 800 replications.\n",sep="")
