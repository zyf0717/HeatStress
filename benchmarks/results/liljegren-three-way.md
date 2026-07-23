# Three-way Liljegren benchmark

Recorded 2026-07-23 on macOS arm64 (`aarch64-apple-darwin25.4.0`) with R
4.6.1. This fixed-coordinate benchmark compares complete
`wbgt.Liljegren()` calls at three implementations:

- pre-fork commit `f77a263ba6820a79b7092518ff4376c787ac45b2`;
- HeatStressR 2.1.6 scalar engine; and
- HeatStressR 2.1.6 batch engine.

Each value is the median of three repetitions over the same deterministic
weather series. Radiation is derived from solar elevation before timing.

| Rows | Pre-fork | Current scalar | Current batch | Batch / scalar speedup |
| ---: | ---: | ---: | ---: | ---: |
| 100 | 0.062 s | 0.105 s | 0.084 s | 1.25x |
| 1,000 | 0.414 s | 0.256 s | 0.020 s | 12.80x |
| 10,000 | 4.260 s | 2.624 s | 0.101 s | 25.98x |

Every measured output had finite Tg, Tnwb, and WBGT values. The pre-fork arm
uses the historical fixed-coordinate API; it is included only for performance
comparison and is not a numerical-equivalence claim.

Raw data: [`liljegren-three-way.csv`](liljegren-three-way.csv).
