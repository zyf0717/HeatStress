# Benchmark environment

- Captured: 2026-07-21T14:00:21+08:00
- Source commit: `a506c79f5171d198228bb2e6d21dd5c9fa2c2855`
- R: 4.6.1 (2026-06-24), `aarch64-apple-darwin25.4.0`
- Platform: macOS 26.5 (Darwin 25.5.0), arm64
- CPU: Apple M2 Max
- Memory: 32 GiB
- Repetitions: 3; each CSV reports median elapsed time and sampled allocation
  bytes (allocations of at least 1 KiB).

The deterministic synthetic datasets use hourly UTC timestamps, sinusoidal
22–30 °C air temperatures, dew points at or below air temperature, calm to
moderate winds, and 0–850 W/m² radiation. Vectorization inputs additionally
contain fixed missing-value positions. Solver fixtures use finite inputs only.

Command (the benchmark defaults, with result persistence enabled):

```sh
BENCHMARK_OUTPUT_DIR=benchmarks/results Rscript benchmarks/benchmark-vectorization.R
```

`vectorization-baseline.csv` covers `calZenith()` and total
`wbgt.Liljegren()`. `solver-baseline.csv` covers scalar `fTg()`, scalar
`fTnwb()`, and total `wbgt.Bernard()`.

All output-equivalence and finite-output checks passed. The greatest absolute
component difference between corrected scalar and batch `wbgt.Liljegren()`
outputs was `1.22e-6` °C; `NA` positions were aligned.

## Default vectorization results

| Benchmark | Rows | Scalar | Vectorized/batch | Speedup |
| --- | ---: | ---: | ---: | ---: |
| `calZenith()` | 100 | 0.004 s | 0.001 s | 4.00x |
| `calZenith()` | 1,000 | 0.046 s | 0.002 s | 23.00x |
| `calZenith()` | 10,000 | 0.432 s | 0.017 s | 25.41x |
| `calZenith()` | 87,600 | 3.779 s | 0.136 s | 27.79x |
| `wbgt.Liljegren()` | 100 | 0.082 s | 0.047 s | 1.74x |
| `wbgt.Liljegren()` | 1,000 | 0.262 s | 0.019 s | 13.79x |
| `wbgt.Liljegren()` | 10,000 | 2.678 s | 0.121 s | 22.13x |

## Default scalar-solver results

| Benchmark | Rows | Median elapsed time |
| --- | ---: | ---: |
| `fTg()` | 1 | <0.001 s |
| `fTnwb()` | 1 | 0.001 s |
| `wbgt.Bernard()` | 1 | 0.004 s |
| `fTg()` | 10 | 0.001 s |
| `fTnwb()` | 10 | 0.002 s |
| `wbgt.Bernard()` | 10 | <0.001 s |
| `fTg()` | 100 | 0.011 s |
| `fTnwb()` | 100 | 0.015 s |
| `wbgt.Bernard()` | 100 | 0.003 s |
