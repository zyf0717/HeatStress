test_that("legacy public argument lists remain leading signature prefixes", {
  legacy_formals <- list(
    apparentTemp = c("tas", "hurs", "wind"),
    calZenith = c("dates", "lon", "lat", "hour"),
    dewp2hurs = c("tas", "dewp"),
    discomInd = c("tas", "hurs"),
    effectiveTemp = c("tas", "hurs", "wind"),
    fTg = c("tas", "relh", "Pair", "wind", "min.speed", "radiation",
      "propDirect", "zenith", "SurfAlbedo", "tolerance"),
    fTnwb = c("tas", "dewp", "relh", "Pair", "wind", "min.speed",
      "radiation", "propDirect", "zenith", "irad", "SurfAlbedo", "tolerance"),
    hi = c("tas", "hurs"),
    humidex = c("tas", "hurs"),
    indexShow = NULL,
    swbgt = c("tas", "hurs"),
    tashurs2vap.pres = c("tas", "hurs"),
    wbgt.Bernard = c("tas", "dewp", "tolerance", "noNAs", "swap"),
    wbgt.Liljegren = c("tas", "dewp", "wind", "radiation", "dates", "lon",
      "lat", "tolerance", "noNAs", "swap", "hour"),
    wbt.Stull = c("tas", "hurs")
  )

  for (name in names(legacy_formals)) {
    expected <- legacy_formals[[name]]
    actual <- names(formals(getExportedValue("HeatStressR", name)))
    expect_identical(head(actual, length(expected)), expected, info = name)
  }
})

test_that("legacy positional Liljegren and solver calls remain accepted", {
  expect_length(calZenith("1981-06-15", -5.66, 40.96, FALSE), 1L)
  expect_length(fTg(30, 50, 1010, 1, 0.13, 700, 0.8, 0.5, 0.4, 1e-4), 1L)
  expect_length(fTnwb(30, 20, dewp2hurs(30, 20), 1010, 1, 0.13, 700,
    0.8, 0.5, 1, 0.4, 1e-4), 1L)

  result <- suppressWarnings(wbgt.Liljegren(
    30, 20, 1, 700, "2024-06-01 12:00:00", 0, 15,
    1e-4, TRUE, FALSE, TRUE
  ))
  expect_identical(names(result), c("data", "Tnwb", "Tg"))
  expect_true(all(vapply(result, length, integer(1)) == 1L))
})
