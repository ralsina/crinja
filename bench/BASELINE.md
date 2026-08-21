== Render (pre-parsed templates) ==
Warning: benchmarking without the `--release` flag won't yield useful results
     render simple  61.75k ( 16.19µs) (± 5.78%)  7.71kB/op        fastest
      render loops 860.85  (  1.16ms) (± 2.79%)   500kB/op  71.73× slower
render expressions  29.91k ( 33.44µs) (± 1.89%)  11.4kB/op   2.06× slower
     render macros  14.73k ( 67.89µs) (± 2.36%)  27.3kB/op   4.19× slower

== Parse + compile ==
Warning: benchmarking without the `--release` flag won't yield useful results
parse simple  48.65k ( 20.56µs) (± 2.18%)  9.71kB/op        fastest
 parse loops  14.63k ( 68.33µs) (± 2.20%)  31.7kB/op   3.32× slower

# Baseline benchmark

Run with `crystal build bench/benchmark.cr -o bin/bench && ./bin/bench`.

Note: built without `--release` per project policy, so absolute numbers are
low but relative comparisons between runs remain valid.

Scenarios:
- **simple**: variable output, member access (`user.age`), if/else.
- **loops**: 100-item for-loop with `loop.index`, member access, filters
  (`round`, `map`, `sum`, `length`, `sort`, `join`).
- **expressions**: arithmetic, boolean ops, test expression (`is equalto`),
  dict member + index access, undefined w/ default filter, format filter.
- **macros**: macro definition and calls (positional + kwargs), range loop,
  `set`.
