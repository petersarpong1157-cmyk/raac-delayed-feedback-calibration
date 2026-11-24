# ============================================================
# STEP 75 -- RAAC PUBLICATION FIGURES (AJS vector PDF)
# Uses the archived simulation evidence, never invented results.
# Figures 1--3: schematic, paired 200-replication contrasts,
#                marginal versus high-volatility regime coverage.
# Figure 4: created ONLY if actual trajectory data are available.
# ============================================================

pkgs <- c('data.table', 'ggplot2', 'scales', 'patchwork')
missing_pkgs <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_pkgs)) {
  stop('Please install packages first: install.packages(c(',
       paste(sprintf('"%s"', missing_pkgs), collapse = ', '), '))')
}
library(data.table)
library(ggplot2)
library(patchwork)

root <- 'C:/Users/peter/Downloads/AI PREDICTION/RANF_AI_Research'
release <- file.path(root, 'results/step65_portable_release/RAAC_Research_Release')
out <- file.path(root, 'results/step75_publication_figures')
dir.create(out, recursive = TRUE, showWarnings = FALSE)

# Prefer the original archived 800-run results, fallback to portable CSVs.
locate <- function(rel) {
  candidates <- c(file.path(root, rel), file.path(release, rel))
  candidates <- candidates[file.exists(candidates)]
  if (!length(candidates)) stop('Missing archived evidence: ', rel)
  candidates[1]
}
metrics_path <- locate('results/step54_independent_benchmark/all_replication_metrics.csv')
subgroup_path <- locate('results/step54_independent_benchmark/all_replication_subgroups.csv')

# Match plausible names without assuming the CSV column order.
column <- function(dt, choices, purpose, required = TRUE) {
  nms <- names(dt)
  ix <- match(tolower(choices), tolower(nms))
  ix <- ix[!is.na(ix)]
  if (length(ix)) return(nms[ix[1]])
  if (required) stop('Cannot find ', purpose, '. Available columns: ', paste(nms, collapse = ', '))
  NULL
}

method_normalize <- function(x) {
  x <- trimws(as.character(x))
  k <- gsub('[^a-z0-9]', '', tolower(x))
  map <- c(fixedglobal='Fixed Global', fixedconditional='Fixed Conditional',
           rollingglobal='Rolling Global', rollingconditional='Rolling Conditional',
           equalweight='Equal Weight', raac='RAAC',
           cohortdelayedaci='Cohort-Delayed ACI')
  unname(ifelse(k %in% names(map), map[k], x))
}
scenario_normalize <- function(x) {
  k <- gsub('[^a-z0-9]', '', tolower(trimws(as.character(x))))
  map <- c(stable='Stable', gradualvolatilityincrease='Gradual increase',
           suddenvolatilityincrease='Sudden increase',
           volatilityreversal='Volatility reversal')
  unname(ifelse(k %in% names(map), map[k], as.character(x)))
}
sc_order <- c('Stable','Gradual increase','Sudden increase','Volatility reversal')
method_order <- c('Fixed Global','Fixed Conditional','Rolling Global',
                  'Rolling Conditional','Equal Weight','RAAC','Cohort-Delayed ACI')

raw <- fread(metrics_path)
message('METHOD METRICS COLUMNS: ', paste(names(raw), collapse = ', '))
m <- data.table(
  scenario = scenario_normalize(raw[[column(raw,c('scenario','scenario_name'),'scenario')]]),
  replication = as.integer(raw[[column(raw,c('replication','replication_id','rep','rep_id'),'replication')]]),
  method = method_normalize(raw[[column(raw,c('method','method_name'),'method')]]),
  score = as.numeric(raw[[column(raw,c('mean_score','mean_interval_score','interval_score_mean','score_mean'),'mean interval score')]]),
  coverage = as.numeric(raw[[column(raw,c('coverage','mean_coverage','empirical_coverage','overall_coverage'),'coverage')]])
)

if (max(m$coverage, na.rm=TRUE) > 1.01) m[, coverage := coverage / 100]
message('NORMALIZED METHODS: ', paste(sort(unique(m$method)), collapse=', '))
message('NORMALIZED SCENARIOS: ', paste(sort(unique(m$scenario)), collapse=', '))
stopifnot(all(is.finite(m$score)), all(m$coverage >= 0 & m$coverage <= 1),
          all(method_order %in% unique(m$method)),
          all(sc_order %in% unique(m$scenario)))
if (m[, anyDuplicated(.SD), .SDcols=c('scenario','replication','method')] > 0L)
  stop('Duplicate scenario-replication-method rows. Inspect archived metrics.')
stopifnot(m[, uniqueN(replication), by=scenario][, all(V1 == 200L)])

# AJS-friendly typography. Figures are vector PDFs, not raster images.
theme_set(theme_bw(base_size=11) +
  theme(panel.grid.minor=element_blank(),
        plot.title=element_text(face='bold',size=12),
        strip.text=element_text(face='bold'),
        legend.position='bottom'))

# ------------------------------------------------------------
# Figure 1: architecture only (clearly marked illustrative).
# Horizons below are examples of 1--3-cycle outcome delays,
# NOT sampled observations or results from a replication.
# ------------------------------------------------------------
architecture <- data.table(
  cohort=c('Cohort A','Cohort B','Cohort C'),
  issued=c(0,1,2),
  latest_release=c(2,4,3),
  first_update=c(3,5,4)
)
architecture[, cohort := factor(cohort, levels=rev(cohort))]
fig1 <- ggplot(architecture, aes(y=cohort)) +
  geom_segment(aes(x=issued, xend=latest_release, yend=cohort),
               linewidth=1.6, colour='#457B9D') +
  geom_segment(aes(x=latest_release, xend=first_update,yend=cohort),
               linewidth=0.8, linetype='dashed',colour='#D55E00') +
  geom_point(aes(x=issued),size=3.4,shape=16,colour='#1D3557') +
  geom_point(aes(x=latest_release),size=3.3,shape=17,colour='#457B9D') +
  geom_point(aes(x=first_update),size=3.3,shape=15,colour='#D55E00') +
  scale_x_continuous(breaks=0:5,labels=paste0('t+',0:5),expand=expansion(mult=c(.04,.07))) +
  labs(title='Figure 1. Completed-cohort feedback and release-aware updates',
       subtitle='Illustrative timing; cohort updates occur only at origins strictly after all labels release',
       x='Forecast / release origin (14-day cycles)',y=NULL,
       caption='Circle = issue; triangle = last outcome release; square = first eligible weight update.\nThe four expert radii are combined at issue; frozen feedback updates are applied only after complete release.') +
  theme(plot.caption=element_text(hjust=0,size=8))
ggsave(file.path(out,'Figure_1_Release_Aware_Timeline.pdf'),fig1,width=9,height=4.8,device="pdf")

# ------------------------------------------------------------
# Figure 2: all paired contrasts calculated from the same
# replication seeds; Student-t 95% CI, NOT unpaired SEM.
# ------------------------------------------------------------
comparators <- c('Fixed Global','Equal Weight','Fixed Conditional')
wide <- dcast(m[method %in% c('RAAC',comparators)],
              scenario + replication ~ method,value.var='score')
forest <- rbindlist(lapply(comparators,function(base) {
  d <- wide[,.(scenario,replication,
                difference=get('RAAC')-get(base))]
  if (anyNA(d$difference)) stop('Missing paired score for comparator ',base)
  d[, .(n=.N,estimate=mean(difference),sd=sd(difference)),by=scenario][,
    `:=`(comparison=paste('RAAC minus',base),
         se=sd/sqrt(n))][,
    `:=`(lower=estimate-qt(.975,df=n-1)*se,
         upper=estimate+qt(.975,df=n-1)*se)]
}), fill=TRUE)
stopifnot(nrow(forest)==12L,all(forest$n==200L))
forest[, scenario:=factor(scenario,levels=rev(sc_order))]
forest[, comparison:=factor(comparison,levels=paste('RAAC minus',comparators))]
fig2 <- ggplot(forest,aes(x=estimate,y=scenario)) +
  geom_vline(xintercept=0,linetype='dashed',colour='grey45') +
  geom_segment(aes(x=lower,xend=upper,yend=scenario),linewidth=.8,colour='#264653') +
  geom_point(size=2.8,colour='#D55E00') +
  facet_wrap(~comparison,scales='free_x',ncol=1) +
  labs(title='Figure 2. Paired differences in mean interval score',
       subtitle='Negative values favor RAAC; 95% Student-t confidence intervals over 200 paired replications',
       x='RAAC minus comparator: mean interval score',y=NULL,
       caption='Horizontal axes are panel-specific; inspect scale before comparing effect magnitude.') +
  theme(strip.placement='outside',plot.caption=element_text(hjust=0,size=8))
ggsave(file.path(out,'Figure_2_Paired_Score_Forest.pdf'),fig2,width=9,height=8,device="pdf")
fwrite(forest,file.path(out,'Figure_2_Paired_Estimates.csv'))

# ------------------------------------------------------------
# Figure 3: marginal coverage AND regime-1 coverage for all
# seven methods, each estimated over the same 200 replications.
# ------------------------------------------------------------
sraw <- fread(subgroup_path)
message('SUBGROUP METRICS COLUMNS: ', paste(names(sraw),collapse=', '))
reg_col <- column(sraw,c('regime','regime_id','group_regime'),'regime identifier')
reg_values <- trimws(tolower(as.character(sraw[[reg_col]])))
reg_is_1 <- reg_values %in% c('1','regime1','regime_1','high','high_volatility','high volatility')
if (!any(reg_is_1)) stop('Cannot identify high-volatility Regime 1. Observed: ',
                         paste(unique(reg_values),collapse=', '))
s <- data.table(
  scenario=scenario_normalize(sraw[[column(sraw,c('scenario','scenario_name'),'scenario')]]),
  replication=as.integer(sraw[[column(sraw,c('replication','replication_id','rep','rep_id'),'replication')]]),
  method=method_normalize(sraw[[column(sraw,c('method','method_name'),'method')]]),
  regime_1=reg_is_1,
  coverage=as.numeric(sraw[[column(sraw,c('regime_coverage','coverage','empirical_coverage','mean_coverage'),'regime coverage')]])
)
if (max(s$coverage,na.rm=TRUE)>1.01) s[,coverage:=coverage/100]
if (!all(is.finite(s$coverage))) stop('Nonfinite subgroup coverage')
if (s[regime_1==TRUE,anyDuplicated(.SD),.SDcols=c('scenario','replication','method')]>0L)
  stop('Duplicate regime-1 rows. Inspect subgroup results.')

marginal <- m[,.(coverage=mean(coverage),n_rep=.N),by=.(scenario,method)][,
  panel:='A. Marginal coverage']
conditional <- s[regime_1==TRUE,
  .(coverage=mean(coverage),n_rep=.N),by=.(scenario,method)][,
  panel:='B. Regime 1 coverage']
plotcov <- rbindlist(list(marginal,conditional))
stopifnot(all(plotcov$n_rep==200L),nrow(plotcov)==56L)
stopifnot(all(is.finite(plotcov$coverage)), all(plotcov$coverage >= 0), all(plotcov$coverage <= 1))
plotcov[,method:=factor(method,levels=method_order)]
plotcov[,scenario:=factor(scenario,levels=sc_order)]
# Show ALL coverage values: a hard-coded 60% lower axis limit
# previously suppressed three below-range observations.
coverage_floor <- max(0, 5 * floor(min(100 * plotcov$coverage, na.rm=TRUE) / 5) - 5)
message('FIGURE 3: minimum plotted coverage (%) = ',
        sprintf('%.3f', 100 * min(plotcov$coverage)))
message('FIGURE 3: shared y-axis range = ', coverage_floor, ' to 100%')
if (any(100 * plotcov$coverage < 60)) {
  message('FIGURE 3: previously clipped observations (now included):')
  print(plotcov[100 * coverage < 60,
                .(panel, scenario, method, coverage_percent = round(100 * coverage, 3))])
}
fig3 <- ggplot(plotcov,aes(x=method,y=100*coverage,colour=scenario,group=scenario)) +
  geom_hline(yintercept=90,linetype='dashed',colour='black',linewidth=.75) +
  geom_point(position=position_dodge(width=.7),size=2.3) +
  facet_wrap(~panel,nrow=1) +
  scale_y_continuous(limits=c(coverage_floor,100),
                     breaks=seq(coverage_floor,100,5)) +
  labs(title='Figure 3. Near-nominal marginal coverage masks regime-1 undercoverage',
       subtitle='Seven methods; 200-replication scenario means; dashed line = nominal 90% coverage',
       x=NULL,y='Empirical coverage (%)',colour='Volatility scenario') +
  theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1),
        legend.position='bottom')
ggsave(file.path(out,'Figure_3_Marginal_vs_Regime1_Coverage.pdf'),fig3,
       width=13.5,height=6.2,device="pdf")
fwrite(plotcov,file.path(out,'Figure_3_Coverage_Plot_Data.csv'))

# ------------------------------------------------------------
# Figure 4: trajectory must come from an actual replication.
# No random or fabricated weights will be plotted.
# Export a real trajectory as CSV to the path below.
# Required: origin; the 4 expert weights; regime1_sigma;
#           and released_cohorts (counts completed BEFORE origin).
# Optional: scenario, replication (used to filter).
# Expert weight column names can be either w_Fixed_Global etc.
# ------------------------------------------------------------
trajectory_path <- file.path(out,'verified_replication_trajectory.csv')
if (!file.exists(trajectory_path)) {
  message('\nFIGURE 4 NOT GENERATED: no verified origin-level trajectory at:\n',trajectory_path)
  message('To complete Figure 4, export origin-level RAAC weight history, actual\n',
          'regime-1 sigma, and strictly-prior completed-cohort release counts from\n',
          'one frozen replication to this CSV. Do NOT invent these values.')
  writeLines(c(
    'Figure 4 awaiting source-verified origin-level data.',
    'Expected file: verified_replication_trajectory.csv',
    'Required fields: origin, regime1_sigma, released_cohorts,',
    'w_Fixed_Global, w_Fixed_Conditional, w_Rolling_Global, w_Rolling_Conditional.',
    'If multiple scenarios/replications are present, also provide scenario and replication.',
    'Do not synthesize or interpolate weight trajectories.'
  ),file.path(out,'Figure_4_Data_Requirement.txt'))
} else {
  tr <- fread(trajectory_path)
  origin_col <- column(tr,c('origin','forecast_origin','origin_index','t'),'forecast origin')
  sigma_col <- column(tr,c('regime1_sigma','sigma_regime1','sigma1','high_regime_sigma'),'actual regime-1 volatility')
  release_col <- column(tr,c('released_cohorts','cohorts_released','completed_cohorts','newly_completed_cohorts'),'completed-cohort releases')
  w_names <- c('w_Fixed_Global','w_Fixed_Conditional','w_Rolling_Global','w_Rolling_Conditional')
  actual_w <- vapply(w_names,function(nm) column(tr,c(nm,sub('w_','weight_',nm)),nm),character(1))
  use <- data.table(origin=as.numeric(tr[[origin_col]]),
                    sigma=as.numeric(tr[[sigma_col]]),
                    released=as.numeric(tr[[release_col]]))
  for (j in seq_along(w_names)) use[,(w_names[j]):=as.numeric(tr[[actual_w[j]]])]
  stopifnot(!anyNA(use),all(use$released>=0),all(use$sigma>0),
            all(as.matrix(use[,..w_names])>=0),
            all(abs(rowSums(as.matrix(use[,..w_names]))-1)<1e-6))
  if (anyDuplicated(use$origin)) stop('Figure 4 CSV contains multiple trajectories. Select ONE original replication.')
  setorder(use,origin)
  long <- melt(use,id.vars='origin',measure.vars=w_names,
               variable.name='expert',value.name='weight')
  long[,expert:=factor(sub('w_','',expert),levels=sub('w_','',w_names))]
  ptop <- ggplot(use,aes(x=origin,y=sigma)) +
    geom_step(linewidth=.9,colour='#264653') +
    geom_point(data=use[released>0],aes(size=released),colour='#D55E00',alpha=.85) +
    labs(y='Regime-1 SD',x=NULL,
         subtitle='Orange markers indicate origins with newly completed, eligible cohorts',
         size='Released cohorts')
  pbottom <- ggplot(long,aes(x=origin,y=weight,colour=expert)) +
    geom_line(linewidth=.8) +
    scale_y_continuous(limits=c(0,1)) +
    labs(x='Forecast origin',y='Expert weight',colour='Calibration expert')
  fig4 <- (ptop / pbottom) + plot_annotation(
    title='Figure 4. Verified volatility and RAAC expert-weight trajectories',
    subtitle='Single archived or reproduced replication; weights may update only after full cohort release')
  ggsave(file.path(out,'Figure_4_Release_and_Weight_Trajectory.pdf'),
         fig4,width=11,height=8,device="pdf")
}

cat('\nSTEP 75 COMPLETE\n')
cat('Figure directory:',out,'\n')
cat('Existing PDF figures:\n')
print(basename(list.files(out,pattern='^Figure_[1-4].*\\.pdf$',full.names=TRUE)))
cat('Figure 2 paired contrasts and Figure 3 coverage source tables also exported.\n')