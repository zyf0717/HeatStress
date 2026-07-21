#!/usr/bin/env Rscript

base_rows <- 87600L
worker_counts <- 1:6

make_weather_block <- function(n, lon = -5.66, lat = 40.96) {
  index <- seq_len(n)
  phase <- 2 * pi * ((index - 1) %% 24) / 24
  dates <- as.POSIXct("2020-01-01 00:00:00", tz = "UTC") + (index - 1) * 3600
  zenith <- HeatStressR:::degToRad(calZenith(dates, lon, lat, hour = TRUE))
  list(
    tas = 22 + 8 * sin(phase - pi / 2),
    dewp = 16 + 6 * sin(phase - pi / 2),
    wind = rep(c(0, 0.05, 0.2, 0.8, 1.5, 2.5), length.out = n),
    radiation = 850 * pmax(cos(zenith), 0),
    dates = dates
  )
}

measure_batch <- function(weather, workers) {
  gc()
  started <- proc.time()[["elapsed"]]
  result <- suppressWarnings(wbgt.Liljegren(
    weather$tas, weather$dewp, weather$wind, weather$radiation, weather$dates,
    lon = -5.66, lat = 40.96, hour = TRUE, engine = "batch", workers = workers,
    diagnostics = TRUE
  ))
  list(seconds = proc.time()[["elapsed"]] - started, result = result)
}

summarize_run <- function(run, worker_count, baseline_seconds) {
  result <- run$result
  diagnostics <- result$diagnostics
  total_rows <- base_rows * worker_count
  if (!identical(diagnostics$workers, as.integer(worker_count)))
    stop("Benchmark did not retain the requested worker count")
  if (!all(vapply(result[c("data", "Tg", "Tnwb")], length, integer(1)) == total_rows))
    stop("Benchmark returned inconsistent output lengths")
  residuals <- c(diagnostics$Tg$final_residual, diagnostics$Tnwb$final_residual)
  residuals <- residuals[is.finite(residuals)]
  estimated_serial_seconds <- baseline_seconds * worker_count
  data.frame(
    rows_per_worker = base_rows,
    total_rows = total_rows,
    requested_workers = worker_count,
    effective_workers = diagnostics$workers,
    single_core_block_seconds = baseline_seconds,
    estimated_single_core_seconds = estimated_serial_seconds,
    parallel_seconds = run$seconds,
    estimated_speedup = estimated_serial_seconds / run$seconds,
    rows_per_second = total_rows / run$seconds,
    fallback_count = sum(diagnostics$Tg$used_fallback, na.rm = TRUE) +
      sum(diagnostics$Tnwb$used_fallback, na.rm = TRUE),
    max_final_residual = if (length(residuals)) max(abs(residuals)) else NA_real_,
    r_version = paste(R.version$major, R.version$minor, sep = "."),
    platform = R.version$platform,
    row.names = NULL
  )
}

suppressPackageStartupMessages(library(HeatStressR))
maximum_workers <- HeatStressR:::max_liljegren_workers()
if (maximum_workers < max(worker_counts))
  stop("This benchmark requires at least ", max(worker_counts),
    " logical CPUs; detected ", maximum_workers)

block <- make_weather_block(base_rows)
baseline <- measure_batch(block, workers = 1L)
baseline_seconds <- baseline$seconds
rows <- list(summarize_run(baseline, 1L, baseline_seconds))
rm(baseline)
gc()
for (worker_count in worker_counts[-1L]) {
  weather <- lapply(block, rep, times = worker_count)
  run <- measure_batch(weather, worker_count)
  rows[[length(rows) + 1L]] <- summarize_run(run, worker_count, baseline_seconds)
  rm(weather, run)
}
result <- do.call(rbind, rows)
print(result, row.names = FALSE)
output <- Sys.getenv("BENCHMARK_OUTPUT", unset = "")
if (nzchar(output)) utils::write.csv(result, output, row.names = FALSE)
