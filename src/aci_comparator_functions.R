aci_quantile45 <-
function(scores, alpha_level) {
  
  s <- sort(scores[is.finite(scores)])
  n <- length(s)
  
  stopifnot(
    n >= 20L,
    alpha_level > 0,
    alpha_level < 1
  )
  
  k <- ceiling((n + 1L) * (1 - alpha_level))
  
  if (k > n) return(Inf)
  
  s[k]
}
run_aci45 <-
function(
    forecasts,
    outcome_vault,
    gamma = gamma45) {
  
  x <- copy(as.data.table(forecasts))
  y <- copy(as.data.table(outcome_vault))
  
  stopifnot(
    !"actual" %in% names(x),
    !"release_date" %in% names(x),
    !"prediction" %in% names(y),
    uniqueN(x$row_id) == nrow(x),
    uniqueN(y$row_id) == nrow(y),
    setequal(x$row_id, y$row_id),
    gamma >= 0
  )
  
  setorder(x, origin_date, row_id)
  
  calibration <- x[partition == "calibration"]
  evaluation <- x[partition == "evaluation"]
  
  first_eval <- min(evaluation$origin_date)
  
  # Initial calibration history from released labels
  eligible_initial <- y[release_date < first_eval]
  
  initial <- merge(
    calibration[origin_date < first_eval],
    eligible_initial,
    by = "row_id"
  )
  
  initial[, residual := abs(actual - prediction)]
  
  stopifnot(nrow(initial) >= window45)
  
  # ACI state, updated only by released cohorts
  alpha_state <- target_alpha45
  
  issued_list <- list()
  update_list <- list()
  state_list <- list()
  
  processed <- integer()
  
  origins <- sort(unique(evaluation$origin_date))
  
  for (j in seq_along(origins)) {
    
    t <- origins[j]
    
    # 1. Release processing:
    # score stored intervals from completed cohorts
    
    if (length(issued_list)) {
      
      archived <- rbindlist(issued_list)
      
      completed <- unique(
        archived$origin_index
      )
      
      completed <- setdiff(completed, processed)
      
      ready <- data.table(
        origin_index = integer(),
        last_release = as.IDate(character())
      )
      
      for (cid in completed) {
        
        original <- archived[origin_index == cid]
        
        labels <- y[row_id %in% original$row_id]
        
        if (
          nrow(labels) == nrow(original) &&
          all(labels$release_date < t)
        ) {
          
          ready <- rbind(
            ready,
            data.table(
              origin_index = cid,
              last_release = max(labels$release_date)
            )
          )
        }
      }
      
      if (nrow(ready)) {
        
        setorder(ready, last_release, origin_index)
        
        for (cid in ready$origin_index) {
          
          original <- archived[origin_index == cid]
          
          labels <- y[
            row_id %in% original$row_id,
            .(row_id, release_date, actual)
          ]
          
          scored <- merge(
            original,
            labels,
            by = "row_id"
          )
          
          stopifnot(
            all(scored$release_date < t)
          )
          
          # Score the interval originally issued.
          misses <- as.numeric(
            scored$actual < scored$aci_lower |
              scored$actual > scored$aci_upper
          )
          
          cohort_error <- mean(misses)
          
          alpha_before <- alpha_state
          
          alpha_state <- min(
            max(
              alpha_state +
                gamma * (
                  target_alpha45 - cohort_error
                ),
              min_alpha45
            ),
            max_alpha45
          )
          
          update_list[[length(update_list) + 1L]] <-
            data.table(
              update_at = t,
              scored_origin_id = cid,
              last_release = max(scored$release_date),
              n_scored = nrow(scored),
              alpha_before = alpha_before,
              alpha_after = alpha_state,
              cohort_miscoverage = cohort_error
            )
          
          processed <- c(processed, cid)
        }
      }
    }
    
    # 2. Obtain only historically released residuals
    
    past_x <- x[
      origin_date < t &
        partition %in% c("calibration", "evaluation")
    ]
    
    past_y <- y[
      release_date < t
    ]
    
    hist <- merge(
      past_x[
        , .(row_id, origin_date, prediction)
      ],
      past_y,
      by = "row_id"
    )
    
    stopifnot(
      all(hist$release_date < t),
      all(hist$origin_date < t)
    )
    
    hist[, residual := abs(actual - prediction)]
    
    setorder(
      hist,
      release_date,
      origin_date,
      row_id
    )
    
    scores <- tail(hist$residual, window45)
    
    radius <- aci_quantile45(
      scores,
      alpha_state
    )
    
    # 3. Issue new intervals without actual outcomes
    
    current <- copy(evaluation[origin_date == t])
    
    current[, aci_alpha := alpha_state]
    current[, aci_radius := radius]
    current[, aci_lower := prediction - radius]
    current[, aci_upper := prediction + radius]
    
    issued_list[[length(issued_list) + 1L]] <- current
    
    state_list[[length(state_list) + 1L]] <-
      data.table(
        forecast_origin = t,
        alpha_used = alpha_state,
        radius_used = radius,
        eligible_residuals = nrow(hist),
        completed_cohorts = length(processed),
        last_eligible_release = max(hist$release_date)
      )
  }
  
  list(
    issued = rbindlist(issued_list),
    updates = if (length(update_list)) {
      rbindlist(update_list)
    } else {
      data.table()
    },
    states = rbindlist(state_list),
    pending = setdiff(
      unique(evaluation$origin_index),
      processed
    )
  )
}