# Recovered frozen-function definitions (source-extract provenance).
# Requires original benchmark configuration; not a standalone executable.
# Compare against workstation originals before external reproduction.

softmax37 <- function(z) {
    e <- exp(z - max(z))
    e/sum(e)
}


interval_score37 <- function(y, pred, q) {
    lo <- pred - q
    hi <- pred + q
    2 * q + 20 * pmax(lo - y, 0) + 20 * pmax(y - hi, 0)
}


run_raac_isolated <- function(forecast_table, outcome_vault, eta = 0.1, loss_scale = 20, loss_cap = 5) {
    f <- copy(as.data.table(forecast_table))
    vault <- copy(as.data.table(outcome_vault))
    stopifnot(all(c("id", "origin_id", "origin", "prediction", qcols37) %in% names(f)), all(c("id", "release", "actual") %in% 
        names(vault)), !"actual" %in% names(f), !"release" %in% names(f), !"prediction" %in% names(vault), uniqueN(f$id) == 
        nrow(f), uniqueN(vault$id) == nrow(vault), setequal(f$id, vault$id), all(is.finite(vault$actual)), all(is.finite(as.matrix(f[, 
        ..qcols37]))), all(as.matrix(f[, ..qcols37]) > 0))
    setorder(f, origin, id)
    timing <- merge(f[, .(id, origin)], vault[, .(id, release)], by = "id")
    stopifnot(all(timing$release > timing$origin))
    archive <- list()
    updates <- list()
    weights_log <- list()
    processed <- integer()
    log_w <- setNames(rep(0, 4), experts37)
    a <- 1L
    u <- 1L
    w <- 1L
    for (origin_t in sort(unique(f$origin))) {
        historical <- if (length(archive)) {
            rbindlist(archive)
        }
        else {
            f[0]
        }
        ready_ids <- integer()
        if (nrow(historical)) {
            h <- merge(historical, vault, by = "id", all.x = TRUE)
            ready <- h[, .(complete = all(!is.na(release)) && all(release < origin_t), last_release = max(release)), by = origin_id]
            ready_ids <- ready[complete == TRUE & !origin_id %in% processed, origin_id]
            if (length(ready_ids)) {
                ready <- ready[origin_id %in% ready_ids]
                setorder(ready, last_release, origin_id)
                ready_ids <- ready$origin_id
            }
        }
        for (cid in ready_ids) {
            cohort <- h[origin_id == cid]
            stopifnot(all(cohort$release < origin_t), all(cohort$origin < origin_t))
            losses <- vapply(experts37, function(m) {
                q <- cohort[[paste0("q_", m)]]
                raw_score <- interval_score37(cohort$actual, cohort$prediction, q)
                mean(pmin(raw_score/loss_scale, loss_cap))
            }, numeric(1))
            log_w <- log_w - eta * losses
            processed <- c(processed, cid)
            updates[[u]] <- data.table(update_at = origin_t, scored_origin_id = cid, expert = experts37, scaled_loss = as.numeric(losses), 
                last_cohort_release = max(cohort$release))
            u <- u + 1L
        }
        weights <- softmax37(log_w)
        names(weights) <- experts37
        current <- copy(f[origin == origin_t])
        qmat <- as.matrix(current[, ..qcols37])
        current[, `:=`(raac_radius, as.numeric(qmat %*% weights))]
        current[, `:=`(raac_lower = prediction - raac_radius, raac_upper = prediction + raac_radius)]
        stopifnot(all(current$raac_radius > 0), all(is.finite(current$raac_radius)))
        archive[[a]] <- current
        a <- a + 1L
        weights_log[[w]] <- data.table(forecast_origin = origin_t, expert = experts37, weight = as.numeric(weights), completed_cohorts = length(processed))
        w <- w + 1L
    }
    issued <- rbindlist(archive)
    update_table <- if (length(updates)) {
        rbindlist(updates)
    }
    else {
        data.table()
    }
    list(issued = issued, updates = update_table, weights = rbindlist(weights_log), pending_cohorts = setdiff(unique(issued$origin_id), 
        processed))
}
