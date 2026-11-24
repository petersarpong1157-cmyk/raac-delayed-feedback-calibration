# Release-Aware Adaptive Calibration Under Delayed Feedback: Prediction-Interval Efficiency and Conditional Coverage Across Volatility Regimes

**Manuscript status:** Working draft for methodological review

## Abstract

Prediction-interval calibration becomes challenging when outcomes are published after forecasts are issued and predictive uncertainty changes across groups and time. This simulation study evaluates Release-Aware Adaptive Calibration (RAAC), an exponentially weighted combination of four calibration experts with delayed, cohort-level feedback. Four prespecified volatility scenarios were evaluated using 200 independently seeded replications each. Seven methods were compared at a nominal 90% coverage target, with mean interval score as the primary endpoint.

RAAC reduced mean interval score relative to Fixed Global calibration by 2.26% to 7.49% across scenarios, with all four paired 95% confidence intervals excluding zero. Its improvement over Equal Weight aggregation was below 0.07% in every scenario, while Fixed Conditional calibration achieved lower mean interval scores than RAAC in all four. Although overall RAAC coverage was approximately 90%, coverage in the sparse, higher-volatility regime ranged from 72.02% to 84.44%. These findings illustrate that global adaptive expert weighting can improve average interval-score efficiency without ensuring adequate conditional coverage.

**Keywords:** prediction intervals; delayed feedback;
online expert weighting; distribution shift; calibration;
conditional coverage; simulation.

## 1. Introduction

Forecast uncertainty is particularly difficult to manage when data arrive asynchronously, outcome labels become available with delays, and forecast errors vary across subpopulations. Calibration methods based on pooled residuals may provide acceptable marginal coverage while producing inadequate protection for sparse or volatile groups.

This study evaluates a release-aware implementation of adaptive calibration that combines four interval-radius experts using exponential weighting. The investigation focuses on operational timing, mean interval score, and subgroup reliability rather than asserting a new finite-sample coverage theorem.

The research questions are:

1. Does RAAC improve mean interval score relative to fixed global calibration?
2. Does adaptive weighting meaningfully improve upon equal-weight aggregation?
3. Can approximately nominal marginal coverage mask subgroup undercoverage?
4. How do conditional calibration methods compare under volatility shifts?

### 1.1 Prediction with expert advice

Prediction with expert advice provides an established framework for combining competing forecasters using their observed performance. Cesa-Bianchi and Lugosi (2006) provide a foundational treatment of this framework. Accordingly, the exponential weighting mechanism used by RAAC is not claimed as a novel algorithmic invention.

### 1.2 Delayed feedback in online learning

Joulani, György, and Szepesvári (2013) study online learning under delayed feedback. Their work establishes that delayed information is a recognized setting in online prediction. The present study evaluates a specific operational implementation in which forecast cohorts contribute to expert-weight updates only after their outcomes have been released.

### 1.3 Conformal and adaptive calibration

Romano, Patterson, and Candès (2019) study conformalized quantile regression, while Gibbs and Candès (2021) develop adaptive conformal inference under distribution shift. Gibbs and Candès (2024) subsequently examine online conformal inference under arbitrary distribution shifts using additional adaptation mechanisms. These contributions establish important prior approaches to changing predictive uncertainty.

The cohort-delayed ACI implementation in the present benchmark is a specified comparator, not an exhaustive representation of newer adaptive conformal methods.

### 1.4 Conditional coverage and heterogeneity

Barber, Candès, Ramdas, and Tibshirani (2021) investigate fundamental limitations of distribution-free conditional predictive inference. The current study therefore distinguishes empirical marginal coverage from regime-specific coverage and does not claim a distribution-free conditional coverage guarantee.

### 1.5 Positioning of the present study

The contribution evaluated here is the operational combination of release-aware, completed-cohort feedback with four interval-radius experts, together with a prespecified simulation comparison across volatility shifts and heterogeneous regimes. The benchmark quantifies both benefits relative to a fixed global baseline and limitations relative to conditional calibration and simple equal weighting.

The study does not establish a new expert-weighting theorem, universal method superiority, or finite-sample coverage validity. The cited foundational literature is not claimed to be an exhaustive systematic review.

## 2. Methods

### 2.1 Simulation design

The frozen experimental design comprised four scenarios: Stable, Sudden Volatility Increase, Gradual Volatility Increase, and Volatility Reversal. Each scenario used 200 simulation replications, resulting in 800 runs.

Each replication generated a panel with 60 sector-size groups and 60 forecast origins. The first 24 origins were designated for training, the next 12 for calibration, and the final 24 for evaluation. The generator included sparse observations, temporally dependent disturbances, shared shocks, heterogeneous error volatility, and delayed outcome releases.

Point predictions were generated from a linear model estimated using only training outcomes published before the calibration period. The fitted prediction model was then held fixed.

### 2.2 Calibration methods

Seven methods were evaluated: Fixed Global, Fixed Conditional, Rolling Global, Rolling Conditional, Equal Weight, RAAC, and Cohort-Delayed Adaptive Conformal Inference (ACI). The first four methods served as calibration-radius experts.

RAAC used exponential expert weighting with a prespecified learning rate of 0.10, loss scale of 20, and loss cap of 5. Expert weights were updated only after the relevant issued forecast cohort had fully released its outcomes. The ACI comparator used a prespecified adaptation step of 0.01.

RAAC is an application of established expert-weighting principles to delayed calibration feedback. No formal conditional-coverage guarantee is claimed.


### 2.2.1 Data-generation mechanism

The simulation comprises 60 groups observed at 60 origins separated by 14 days. Groups 1–50 belong to regime 0; groups 51–60 belong to regime 1. Regime 0 has volatility scale 5, while regime 1 has baseline scale 8. Each group receives a random group effect drawn from a normal distribution with standard deviation 2.

The shared economic state follows a stationary autoregressive recursion with coefficient 0.55 and innovation scaling chosen to maintain marginal standard deviation 2.

The outcome is generated using coefficients 15, 0.45, 0.08, and 0.12 for the intercept, revenue signal, supplier signal, and price signal, respectively, plus the group effect, economic state, and serially dependent group-specific error.

The group-specific error follows an AR(1) recursion with coefficient 0.35 and regime-dependent innovation scale. The observation probability is 0.95 for regime 0 and 0.60 for regime 1.

Outcomes are released after one, two, or three 14-day cycles with probabilities 0.70, 0.20, and 0.10, respectively. All forecasting and updating rules exclude outcomes released on or after the current forecast-origin date.

The evaluation-origin volatility schedule is scenario-specific: stable volatility remains at 8; sudden increase changes the regime-1 scale to 12 at the first evaluation origin; gradual increase follows a linear progression from baseline toward 12; and reversal rises toward 12 before returning toward the baseline.

### 2.2.2 Frozen point forecasting

The point predictor is an ordinary least-squares regression of the observed outcome on revenue, supplier, and price signals. It is fitted using training observations whose outcome-release dates precede the first calibration origin. Its coefficients remain fixed during calibration and evaluation. All interval methods share the same point forecasts.

### 2.2.3 Calibration residuals and quantiles

For eligible historical observation i, define

$$s_i = |y_i - \hat{y}_i|.$$

The empirical radius for miscoverage alpha is

$$q_\alpha = s_{(\lceil(n+1)(1-\alpha)\rceil)}.$$

Here the residuals are sorted in ascending order. The frozen implementation requires at least 20 eligible residuals and returns an infinite quantile if the requested rank exceeds n.

Fixed Global uses one pooled calibration quantile calculated before evaluation. Fixed Conditional calculates separate initial quantiles by regime. Rolling Global uses the latest 100 eligible residuals ordered by release date, then forecast origin and row identifier. Rolling Conditional uses the latest 40 eligible residuals for the observation's regime. Available evaluation outcomes may enter rolling histories only after their release.

### 2.2.4 RAAC aggregation

Let m index the four calibration-radius experts.

$$w_{t,m} = \frac{\exp(z_{t,m})}{\sum_{j=1}^{4}\exp(z_{t,j})}.$$

The initial log-weights are all zero, giving an initial weight of 0.25 to each expert.

$$q_{i,t}^{RAAC} = \sum_{m=1}^{4} w_{t,m}q_{i,t,m}.$$

$$C_{i,t}^{RAAC} = [\hat y_{i,t}-q_{i,t}^{RAAC},\; \hat y_{i,t}+q_{i,t}^{RAAC}].$$

RAAC maintains one shared weight vector across regimes. Individual expert radii may nevertheless depend on the observation's regime.

### 2.2.5 Release-aware weight updates

A previously issued cohort c becomes eligible for weight updating at forecast origin t only when every outcome in that cohort has been released strictly before t:

$$\max_{i \in c} r_i < t.$$

The 90% interval score is

$$IS_{0.10}(y,[l,u])=(u-l)+20(l-y)_++20(y-u)_+.$$

Each expert's capped, scaled cohort loss is

$$L_{c,m}=\frac{1}{n_c}\sum_{i\in c}\min\left(\frac{IS_{0.10}(y_i,C_{i,m})}{20},5\right).$$

The log-weight update is

$$z_m \leftarrow z_m - 0.10L_{c,m}.$$

Newly eligible cohorts are processed once, in order of final release date and cohort identifier, before the next forecast cohort is issued. Capping applies to the learning loss, not the reported evaluation score.

### 2.2.6 Equal Weight and cohort-delayed ACI

Equal Weight uses

$$q_{i,t}^{EW}=\frac{1}{4}\sum_{m=1}^{4}q_{i,t,m}.$$

The ACI comparator uses the latest 100 eligible pooled absolute residuals with a time-varying target miscoverage state. After a complete evaluation cohort is released, its average miscoverage updates that state:

$$\alpha_{new}=\operatorname{clip}(\alpha_{old}+0.01(0.10-\bar e_c),\;\alpha_{min},\;\alpha_{max}).$$

The source implementation bounds this state using configured minimum and maximum alpha values. The resulting alpha level determines the empirical residual quantile used for the next issued interval. This comparator is not claimed to represent every ACI variant.

### 2.2.7 Evaluation and statistical inference

The reported mean interval score is computed without learning-loss scaling or clipping. Coverage is the fraction of realized outcomes inside their issued intervals, including endpoints. Each scenario comprises 200 independently seeded replications; methods within the same replication are paired.

For the primary contrast, each replication contributes its RAAC mean score minus its Fixed Global mean score. The scenario-specific 95% confidence interval is the sample mean difference plus or minus the Student-t critical value times its standard error. These intervals quantify Monte Carlo variation under the specified generator; they do not establish real-world coverage guarantees.

### 2.3 Evaluation protocol

All methods were evaluated on identical observations within each replication. Outcomes were joined to issued intervals only at the scoring stage. The primary endpoint was mean 90% interval score. The prespecified primary comparison was RAAC minus Fixed Global. Paired Student-t 95% confidence intervals were computed across the 200 replication-level differences within each scenario.

Secondary analyses examined the remaining methods, empirical coverage, interval width, and coverage within the two simulated regimes. Secondary confidence intervals were not adjusted for multiple comparisons.

## 3. Results

### 3.1 Primary comparison

| Scenario | RAAC minus Fixed Global | 95% CI | Relative score reduction |
|---|---:|---|---:|
| Stable | -0.550 | [-0.583, -0.516] | 2.26% |
| Gradual increase | -1.307 | [-1.359, -1.254] | 4.92% |
| Sudden increase | -2.165 | [-2.239, -2.090] | 7.49% |
| Volatility reversal | -1.316 | [-1.371, -1.261] | 4.97% |

RAAC achieved a lower mean interval score than Fixed Global in every scenario. All four scenario-specific paired confidence intervals excluded zero in favor of RAAC.

### 3.2 All seven calibration methods

| Scenario | Method | Mean interval score | Coverage | Mean width |
|---|---|---:|---:|---:|
| Stable | Fixed Global | 24.323 | 89.86% | 18.806 |
| Stable | Fixed Conditional | 23.638 | 90.03% | 18.907 |
| Stable | Rolling Global | 24.550 | 90.18% | 19.190 |
| Stable | Rolling Conditional | 24.173 | 90.17% | 19.407 |
| Stable | Equal Weight | 23.776 | 90.51% | 19.077 |
| Stable | RAAC | 23.774 | 90.50% | 19.075 |
| Stable | Cohort-Delayed ACI | 24.559 | 90.27% | 19.248 |
| Gradual increase | Fixed Global | 26.566 | 88.69% | 18.806 |
| Gradual increase | Fixed Conditional | 24.880 | 89.09% | 18.907 |
| Gradual increase | Rolling Global | 26.754 | 89.99% | 19.838 |
| Gradual increase | Rolling Conditional | 25.145 | 89.88% | 19.885 |
| Gradual increase | Equal Weight | 25.265 | 89.91% | 19.359 |
| Gradual increase | RAAC | 25.259 | 89.90% | 19.352 |
| Gradual increase | Cohort-Delayed ACI | 26.769 | 90.13% | 19.942 |
| Sudden increase | Fixed Global | 28.916 | 87.78% | 18.806 |
| Sudden increase | Fixed Conditional | 26.358 | 88.22% | 18.907 |
| Sudden increase | Rolling Global | 29.077 | 90.01% | 20.571 |
| Sudden increase | Rolling Conditional | 26.174 | 89.83% | 20.591 |
| Sudden increase | Equal Weight | 26.768 | 89.58% | 19.719 |
| Sudden increase | RAAC | 26.751 | 89.55% | 19.705 |
| Sudden increase | Cohort-Delayed ACI | 29.102 | 90.19% | 20.719 |
| Volatility reversal | Fixed Global | 26.489 | 88.74% | 18.806 |
| Volatility reversal | Fixed Conditional | 24.831 | 89.13% | 18.907 |
| Volatility reversal | Rolling Global | 26.698 | 90.20% | 19.966 |
| Volatility reversal | Rolling Conditional | 25.200 | 90.05% | 20.088 |
| Volatility reversal | Equal Weight | 25.180 | 90.06% | 19.442 |
| Volatility reversal | RAAC | 25.173 | 90.04% | 19.434 |
| Volatility reversal | Cohort-Delayed ACI | 26.718 | 90.33% | 20.075 |

Fixed Conditional calibration achieved the lowest mean interval score in three scenarios, while Rolling Conditional achieved the lowest score following a sudden volatility increase. RAAC was not the best-performing method in any scenario.

### 3.3 Incremental effect of adaptive weighting

RAAC achieved lower mean interval scores than Equal Weight aggregation in all four scenarios. However, relative reductions ranged from approximately 0.008% to 0.063%, indicating a very small practical gain from adaptive weight updating within this simulation design.

### 3.4 Regime-specific reliability

| Scenario | Regime 0 coverage | Regime 1 coverage | Difference |
|---|---:|---:|---:|
| Stable | 91.28% | 84.44% | 6.83 pp |
| Gradual increase | 91.52% | 77.15% | 14.37 pp |
| Sudden increase | 91.78% | 72.02% | 19.76 pp |
| Volatility reversal | 91.56% | 78.09% | 13.47 pp |

RAAC maintained approximately nominal overall coverage but substantially undercovered the sparse, higher-volatility regime. Conditional calibration methods generally provided better Regime 1 coverage than RAAC, particularly during changing volatility.

## 4. Discussion

The primary finding is that a release-aware globally weighted calibration mixture can improve mean interval score relative to a fixed global baseline under synthetic volatility shifts. The size of this improvement was largest following a sudden volatility increase.

However, stronger conditional comparators limited the interpretation of RAAC's performance. Fixed Conditional consistently outperformed RAAC on interval score, and the incremental advantage over Equal Weight was negligible in practical terms.

The coverage results further demonstrate that acceptable marginal coverage can obscure serious subgroup undercoverage. RAAC's global expert weighting did not adequately compensate for the uncertainty of the sparse, volatile regime.

## 5. Limitations

The findings arise from four specified synthetic data-generating scenarios. They should not be generalized to all real business surveys. The benchmark does not independently establish algorithmic novelty, causal effects, finite-sample coverage validity, or conditional coverage guarantees.

The comparisons depend on the selected simulation mechanisms, group structure, delay distribution, calibration windows, expert definitions, and prespecified algorithm settings. The historical BTOS investigations conducted during method development are exploratory and are not represented as a newly untouched external validation dataset.

## 6. Conclusion

Release-aware adaptive expert weighting reduced mean interval score relative to fixed global calibration in four synthetic volatility scenarios. However, its incremental benefit over simple equal weighting was very small, and stronger conditional methods remained competitive or superior. Substantial coverage shortfalls in the sparse, volatile regime illustrate the limitations of global aggregation when uncertainty is heterogeneous.

## Declarations — to be verified before submission

**Funding:** Author confirmation required.

**Competing interests:** Author confirmation required.

**Data availability:** Synthetic data and executable code can be supplied through the accompanying reproducibility package, subject to final repository preparation.

**Code availability:** Frozen source files, simulation checkpoints, seed schedules, scoring functions, and integrity manifests are maintained in the research project.

## References

Barber, R. F., Candès, E. J., Ramdas, A., & Tibshirani, R. J. (2021). The limits of distribution-free conditional predictive inference. *Information and Inference: A Journal of the IMA, 10*(2), 455–482. https://doi.org/10.1093/imaiai/iaaa017

Cesa-Bianchi, N., & Lugosi, G. (2006). *Prediction, Learning, and Games*. Cambridge University Press. https://doi.org/10.1017/CBO9780511546921

Gibbs, I., & Candès, E. (2021). Adaptive conformal inference under distribution shift. *Advances in Neural Information Processing Systems, 34*. https://proceedings.neurips.cc/paper_files/paper/2021/hash/0d441de75945e5acbc865406fc9a2559-Abstract.html

Gibbs, I., & Candès, E. J. (2024). Conformal inference for online prediction with arbitrary distribution shifts. *Journal of Machine Learning Research, 25*(162), 1–36. https://jmlr.org/beta/papers/v25/22-1218.html

Joulani, P., György, A., & Szepesvári, C. (2013). Online learning under delayed feedback. *Proceedings of the 30th International Conference on Machine Learning*, 1453–1461. https://proceedings.mlr.press/v28/joulani13.html

Romano, Y., Patterson, E., & Candès, E. J. (2019). Conformalized quantile regression. *Advances in Neural Information Processing Systems, 32*. https://proceedings.neurips.cc/paper/2019/hash/5103c3584b063c431bd1268e9b5e76fb-Abstract.html

