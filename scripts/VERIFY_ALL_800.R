# Full 800-run frozen RAAC simulator audit: RESUMABLE, one run at a time.
# Rscript --vanilla scripts/VERIFY_ALL_800.R --batch=20  (repeat until complete)
# Rscript --vanilla scripts/VERIFY_ALL_800.R --all       (run all remaining)
# Rscript --vanilla scripts/VERIFY_ALL_800.R --status    (report progress)
#
# Requires R + data.table; no retuning or changes to frozen algorithms.
# This script does NOT reconstruct the 800 original checkpoint .rds files.
suppressPackageStartupMessages(library(data.table))

arg_file <- grep("^--file=", commandArgs(trailingOnly=FALSE),value=TRUE)
stopifnot(length(arg_file)==1L)
here <- normalizePath(sub("^--file=","",arg_file),mustWork=TRUE)
root <- dirname(dirname(here))
flags <- commandArgs(trailingOnly=TRUE)
known <- flags %in% c("--all","--status") | grepl("^--batch=[0-9]+$",flags)
if(any(!known)) stop("Unrecognized arguments: ",paste(flags[!known],collapse=", "))
if("--all" %in% flags && any(grepl("^--batch=",flags))) stop("Choose --all or --batch=N, not both")
n_batch <- if("--all" %in% flags) Inf else 20L
for(flag in flags[grepl("^--batch=",flags)]) n_batch <- as.integer(sub("^--batch=","",flag))
if(!is.finite(n_batch) && !("--all" %in% flags)) stop("Bad batch size")
if(is.finite(n_batch) && (is.na(n_batch)||n_batch<1L)) stop("Batch must be positive")
read_rel <- function(p) {
  f <- file.path(root,p)
  if(!file.exists(f)) stop("Missing input: ",p)
  fread(f)
}
paths <- c(
 "results/step40_evaluation_design/frozen_simulation_configuration.rds",
 "results/step40_evaluation_design/prespecified_scenarios.csv",
 "results/step52_final_benchmark/independent_replication_seeds.csv",
 "results/step54_independent_benchmark/all_replication_metrics.csv",
 "results/step54_independent_benchmark/all_replication_subgroups.csv",
 file.path("src",c("frozen_generator_function.R","point_forecast_functions.R",
   "expert_calibration_functions.R","RAAC_frozen_engine.R",
   "aci_comparator_functions.R","simulation_runner_function.R",
   "frozen_scoring_functions.R","benchmark_replication_function.R"))
)
input_files <- file.path(root,paths)
stopifnot(all(file.exists(input_files)))
input_md5 <- unname(tools::md5sum(input_files))
stopifnot(!anyNA(input_md5))
names(input_md5) <- paths

out <- file.path(root,"reproduction_outputs","full_800_audit")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
lock_manifest <- file.path(out,"input_md5.csv")
md5_table <- data.table(relative_path=paths,md5=as.character(input_md5))
if(file.exists(lock_manifest)) {
  old <- fread(lock_manifest)
  if(!identical(old$relative_path,md5_table$relative_path) ||
     !identical(old$md5,md5_table$md5)) {
    stop("Research inputs changed since this audit began. Preserve the existing ",
         "audit output and run a NEW clean audit directory. Do not mix runs.")
  }
} else fwrite(md5_table,lock_manifest)

config <- readRDS(file.path(root,paths[1]))
scenarios <- read_rel(paths[2])
seeds <- read_rel(paths[3])
reference_metrics <- read_rel(paths[4])
reference_groups <- read_rel(paths[5])
stopifnot(nrow(scenarios)==4L,nrow(seeds)==800L,
  nrow(reference_metrics)==5600L,nrow(reference_groups)==11200L,
  uniqueN(seeds,by=c("scenario","replication"))==800L,
  uniqueN(reference_metrics,by=c("scenario","replication","method"))==5600L,
  uniqueN(reference_groups,by=c("scenario","replication","method","regime"))==11200L,
  all(c("nominal_coverage","global_window","regime_window","raac_eta",
        "raac_loss_scale","raac_loss_cap") %in% names(config)),
  isTRUE(all.equal(as.numeric(config$nominal_coverage),0.90)))
stopifnot(setequal(unique(seeds$scenario),scenarios$scenario))
setorder(seeds,scenario,replication)
stopifnot(all(seeds[, .N,by=scenario]$N==200L))

results_file <- file.path(out,"replication_checks.csv")
if(file.exists(results_file)) {
  progress <- fread(results_file)
  required <- c("scenario","replication","seed","passed",
                "max_method_error","max_regime_error","elapsed_seconds","error_message")
  if(!all(required %in% names(progress))) stop("Progress file schema mismatch")
  stopifnot(uniqueN(progress,by=c("scenario","replication"))==nrow(progress))
} else progress <- data.table(scenario=character(),replication=integer(),seed=integer(),
 passed=logical(),max_method_error=numeric(),max_regime_error=numeric(),
 elapsed_seconds=numeric(),error_message=character())

passed_key <- progress[passed==TRUE,.(scenario,replication,seed)]
if(nrow(passed_key)) {
 matched <- merge(passed_key,seeds,by=c("scenario","replication"),
                  suffixes=c("_done","_current"))
 if(nrow(matched)!=nrow(passed_key)||
    any(matched$seed_done!=matched$seed_current))
  stop("Previously saved passed replicates do not align with locked seeds")
}
summarize <- function() {
  pass <- sum(progress$passed)
  fail <- sum(!progress$passed)
  pending <- nrow(seeds)-pass
  cat(sprintf("Progress: %d / 800 passed; %d unsuccessful attempts; %d not passed\n",
              pass,fail,pending))
  if(pass==800L && fail==0L) {
    cat("PASS: All 800 frozen simulator runs matched the archived tables.\n")
  } else {
    cat("NOT YET VERIFIED: full 800-run simulator reproduction incomplete.\n")
  }
}
if("--status" %in% flags) {
  summarize()
  quit(save="no",status=0L)
}

# Frozen source execution environment and the original runtime constants
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
engine$expected_methods <- c(engine$expert_names43,
                              "Equal_Weight","RAAC","Cohort_Delayed_ACI")
for(p in paths[6:length(paths)]) {
  parse(file=file.path(root,p))
  sys.source(file.path(root,p),envir=engine)
}
stopifnot(all(vapply(c("generate_raac_panel","build_training",
 "issue_predictions","make_expert_intervals43","run_raac_isolated",
 "run_aci45","run_simulation50","evaluate_intervals49","benchmark_rep52"),
 function(f) is.function(engine[[f]]),logical(1))))

todo <- seeds[!progress[passed==TRUE],on=.(scenario,replication)]
if(is.finite(n_batch)) todo <- head(todo,n_batch)
if(!nrow(todo)) {
  summarize()
  quit(save="no",status=if(sum(!progress$passed)>0) 1L else 0L)
}

check_one <- function(scenario,replication,seed) {
  run <- engine$benchmark_rep52(scenario_name=scenario,
    replication_id=replication,engine=engine,config=config,
    scenarios=scenarios,seeds=seeds,
    scoring_function=engine$evaluate_intervals49)
  obs <- run$summary
  groups <- run$subgroup
  ref_m <- reference_metrics[scenario==..scenario & replication==..replication]
  ref_g <- reference_groups[scenario==..scenario & replication==..replication]
  key <- c("scenario","replication","method")
  if(nrow(obs)!=7L || nrow(groups)!=14L || nrow(ref_m)!=7L || nrow(ref_g)!=14L)
    stop("Expected seven method rows and fourteen regime rows")
  m <- merge(obs,ref_m,by=key,suffixes=c("_new","_archive"))
  g <- merge(groups,ref_g,by=c(key,"regime"),suffixes=c("_new","_archive"))
  if(nrow(m)!=7L || nrow(g)!=14L)stop("Key mismatch with archived benchmark")
  compare_columns <- function(z,names) {
    vapply(names,function(field) {
      lhs <- z[[paste0(field,"_new")]]
      rhs <- z[[paste0(field,"_archive")]]
      if(length(lhs)!=nrow(z)||length(rhs)!=nrow(z)||
         any(!is.finite(lhs))||any(!is.finite(rhs)))
        stop("Missing/nonfinite comparator: ",field)
      max(abs(lhs-rhs))
    },numeric(1))
  }
  e_m <- compare_columns(m,c("n","mean_score","coverage",
    "mean_width","minimum_regime_coverage","worst_regime_shortfall"))
  e_g <- compare_columns(g,c("regime_n","regime_coverage"))
  tolerance <- 1e-10
  if(max(e_m)>=tolerance||max(e_g)>=tolerance)
    stop(sprintf("Numerical discrepancy: method %.10g, subgroup %.10g",
                 max(e_m),max(e_g)))
  list(method=max(e_m),regime=max(e_g))
}

save_progress <- function() {
  tmp <- tempfile(pattern="raac_audit_",tmpdir=out,fileext=".csv")
  fwrite(progress,tmp)
  if(!file.copy(tmp,results_file,overwrite=TRUE))
    stop("Could not persist audit progress")
  unlink(tmp)
}

for(i in seq_len(nrow(todo))) {
  x <- todo[i]
  start <- proc.time()[["elapsed"]]
  cat(sprintf("[%d/%d] %s replication %d seed %d ... ",
              i,nrow(todo),x$scenario,x$replication,x$seed))
  trial <- tryCatch(check_one(x$scenario,x$replication,x$seed),
                    error=function(e)e)
  elapsed <- proc.time()[["elapsed"]]-start
  passed <- !inherits(trial,"error")
  msg <- if(passed) "" else conditionMessage(trial)
  record <- data.table(scenario=x$scenario,replication=x$replication,
     seed=x$seed,passed=passed,
     max_method_error=if(passed) trial$method else NA_real_,
     max_regime_error=if(passed) trial$regime else NA_real_,
     elapsed_seconds=elapsed,error_message=msg)
  progress <- progress[!(scenario==x$scenario & replication==x$replication)]
  progress <- rbind(progress,record,use.names=TRUE)
  setorder(progress,scenario,replication)
  save_progress()
  cat(if(passed) "PASS\n" else paste0("FAIL: ",msg,"\n"))
}
capture.output(sessionInfo(),file=file.path(out,"session_info.txt"))
summarize()
if(any(!progress$passed)) quit(save="no",status=1L)
