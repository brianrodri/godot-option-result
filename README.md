# Option & Result for Godot

Simple GDScript implementations of Rust's [`Option<T>`](https://doc.rust-lang.org/std/option/) and [`Result<T, E>`](https://doc.rust-lang.org/std/result/) for Godot.

## Installation

Copy `addons/godot_option_result/` into your project. No plugin activation required — `Option` and `Result` are globally available as named classes.

## API Parity

Legend:

- Methods marked `—` are not implemented.
- Methods marked `!` have been changed due to **necessity**.
- Methods marked `*` have been changed for consistency & style.

### `Option`

| GDScript                 | Rust                | Notes                                                        |
| ------------------------ | ------------------- | ------------------------------------------------------------ |
| `Some(x)`                | `Some(x)`           |                                                              |
| `None`                   | `None`              |                                                              |
| `is_some()`              | `is_some()`         |                                                              |
| `is_none()`              | `is_none()`         |                                                              |
| `is_some_and(p)`         | `is_some_and(f)`    |                                                              |
| `is_none_or(p)`          | `is_none_or(f)`     |                                                              |
| `tee(f)`\*               | `inspect(f)`        | run side effects without influencing the original "pipeline" |
| `unwrap(msg?)`\!         | `unwrap()`          | uses `assert(msg)` rather than `panic`/crashing the program  |
| `unwrap_or(other)`       | `unwrap_or(other)`  |                                                              |
| `unwrap_or_call(f)`\*    | `unwrap_or_else(f)` | lazy (`*_call`) counterpart to the eager `unwrap_or`         |
| `map(f)`                 | `map(f)`            |                                                              |
| `map_or(d, f)`           | `map_or(d, f)`      |                                                              |
| `map_or_call(d, f)`\*    | `map_or_else(d, f)` | lazy (`*_call`) counterpart to the eager `map_or`            |
| `keep_when(p)`\*         | `filter(p)`         | consistent two-word naming pattern for bool-ish operations   |
| `drop_when(p)`           | —                   | for symmetry with `keep_when`                                |
| `and_then(other)`!       | `and(other)`        | `and` is a reserved keyword so chose to adopt `and_then`     |
| `and_then_call(f)`\*     | `and_then(f)`       | lazy (`*_call`) counterpart to the eager `and_then`          |
| `or_else(other)`!        | `or(other)`         | `or` is a reserved keyword so chose to adopt `or_else`       |
| `or_else_call(f)`\*      | `or_else(f)`        | lazy (`*_call`) counterpart to the eager `or_else`           |
| `xor_with(other)`\*      | `xor(other)`        | consistent two-word naming pattern for bool-ish operations   |
| `flatten()`              | `flatten()`         |                                                              |
| `ok_or(e)`               | `ok_or(e)`          |                                                              |
| `ok_or_call(f)`\*        | `ok_or_else(f)`     | lazy (`*_call`) counterpart to the eager `ok_or`             |
| `transpose()`            | `transpose()`       |                                                              |
| `is_equal(other)`        | —                   | Godot-specific                                               |
| `is_equal_approx(other)` | —                   | Godot-specific                                               |
| —                        | `zip(other)`        | needs immutable tuple type but Godot only has mutable arrays |

### `Result`

| GDScript                 | Rust                | Notes                                                          |
| ------------------------ | ------------------- | -------------------------------------------------------------- |
| `Ok(x)`                  | `Ok(x)`             |                                                                |
| `Err(e)`                 | `Err(e)`            |                                                                |
| `GdErr(e)`               | —                   | Godot-specific                                                 |
| `is_ok()`                | `is_ok()`           |                                                                |
| `is_err()`               | `is_err()`          |                                                                |
| `is_ok_and(p)`           | `is_ok_and(p)`      |                                                                |
| `is_err_and(p)`          | `is_err_and(p)`     |                                                                |
| `tee(f)`                 | `inspect(f)`        | run side effects without influencing the original "pipeline"   |
| `tee_err(f)`             | `inspect_err(f)`    | run side effects without influencing the original "pipeline"   |
| `unwrap(msg?)`\!         | `unwrap()`          | uses `assert(msg)` rather than `panic`/crashing the program    |
| `unwrap_err(msg?)`\!     | `unwrap_err()`      | uses `assert(msg)` rather than crashing the program            |
| `unwrap_or(other)`       | `unwrap_or(other)`  |                                                                |
| `unwrap_or_call(f)`\*    | `unwrap_or_else(f)` | lazy (`*_call`) counterpart to the eager `unwrap_or`           |
| `map(f)`                 | `map(f)`            |                                                                |
| `map_err(f)`             | `map_err(f)`        |                                                                |
| `map_or(d, f)`           | `map_or(d, f)`      |                                                                |
| `map_or_call(d, f)`\*    | `map_or_else(d, f)` | lazy (`*_call`) counterpart to the eager `map_or`              |
| `and_then(other)`!       | `and(other)`        | `and` is a reserved keyword; chose to adopt `and_then` instead |
| `and_then_call(f)`\*     | `and_then(f)`       | lazy (`*_call`) counterpart to the eager `and_then`            |
| `or_else(other)`!        | `or(other)`         | `or` is a reserved keyword; chose to adopt `or_else` instead   |
| `or_else_call(f)`\*      | `or_else(f)`        | lazy (`*_call`) counterpart to the eager `or_else`             |
| `flatten()`              | `flatten()`         |                                                                |
| `ok()`                   | `ok()`              |                                                                |
| `err()`                  | `err()`             |                                                                |
| `transpose()`            | `transpose()`       |                                                                |
| `is_equal(other)`        | —                   | Godot-specific                                                 |
| `is_equal_approx(other)` | —                   | Godot-specific                                                 |
