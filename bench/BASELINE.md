== Render (pre-parsed templates) ==
     render simple 269.34k (  3.71µs) (± 4.31%)  7.71kB/op        fastest
      render loops   3.45k (290.02µs) (± 4.21%)   500kB/op  78.11× slower
render expressions 134.71k (  7.42µs) (± 8.43%)  11.4kB/op   2.00× slower
     render macros  55.46k ( 18.03µs) (±12.25%)  27.3kB/op   4.86× slower

== Parse + compile ==
parse simple 169.63k (  5.90µs) (± 4.65%)  9.71kB/op        fastest
 parse loops  53.88k ( 18.56µs) (± 4.27%)  31.7kB/op   3.15× slower

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
