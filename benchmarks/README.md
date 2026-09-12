# Benchmark Kernels

These small C kernels are intentionally source-level and deterministic. They are
not performance benchmarks by themselves; they are inputs for measuring the
coverage and static effects of `AdaptiveWidthMemoryPass`.

The benchmark metrics harness compiles each file to LLVM IR with:

```bash
clang-18 -O0 -S -emit-llvm -Xclang -disable-O0-optnone
```

This keeps stack arrays and internal globals visible to the prototype pass.

