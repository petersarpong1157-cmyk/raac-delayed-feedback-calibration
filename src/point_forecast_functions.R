build_training <-
function(x, vault, cutoff) {
  
  historical_x <- x[
    partition == "train" &
      origin_date < cutoff
  ]
  
  eligible_y <- vault[
    release_date < cutoff
  ]
  
  training <- merge(
    historical_x,
    eligible_y,
    by = "row_id",
    all = FALSE
  )
  
  stopifnot(
    nrow(training) > 100L,
    all(training$release_date < cutoff),
    all(training$origin_date < cutoff),
    all(is.finite(training$actual))
  )
  
  training
}
issue_predictions <-
function(
    predictor_table, fitted_model) {
  
  d <- copy(predictor_table)
  
  stopifnot(
    !"actual" %in% names(d),
    !"release_date" %in% names(d)
  )
  
  d[, prediction := as.numeric(
    predict(fitted_model, newdata = d)
  )]
  
  stopifnot(all(is.finite(d$prediction)))
  
  d
}