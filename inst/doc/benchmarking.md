# Benchmarking

Return to the [package README](https://github.com/zyf0717/HeatStressR#readme).

`calZenith()` processes date vectors in one pass. The batch engine is the
default because it vectorizes the dominant numerical solves. It remains
single-process unless `workers > 1`; PSOCK startup can outweigh the benefit of
additional workers for small inputs.

Performance depends on input size, coordinate reuse, worker count, and local
hardware. Measure the current release on the target workload with the
reproducible harness:

```sh
Rscript benchmarks/benchmark-liljegren-three-way.R
Rscript benchmarks/benchmark-liljegren-workers.R
```

The worker-count benchmark holds total input rows fixed for every comparison.
It measures strong scaling across parallel-process counts rather than
throughput under increasing work.

Timed benchmarks use `diagnostics = FALSE`; diagnostic validation is run
separately when required. See the [benchmark documentation](https://github.com/zyf0717/HeatStressR/blob/master/benchmarks/README.md)
for workload definitions, result locations, and interpretation.
