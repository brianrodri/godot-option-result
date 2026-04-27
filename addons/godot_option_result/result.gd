class_name Result
extends RefCounted
## Immutable.

const _SHARED_IMPL := preload("res://addons/godot_option_result/shared_impl.gd")

var _is_ok: bool
var _value: Variant


## [code]Ok(x)[/code] holds a success value [param x].
static func Ok(x: Variant = null) -> Result:
	return Result.new(true, x)


## [code]Err(e)[/code] holds an error value [param e].
static func Err(e: Variant = null) -> Result:
	return Result.new(false, e)


## Returns [code]Ok(Error.OK)[/code] when [param e] is [constant @GlobalScope.OK], otherwise [code]Err(error_string(e))[/code].
static func GdErr(e: Error) -> Result:
	if e == Error.OK:
		return Ok(Error.OK)
	return Err(error_string(e))


## Private constructor.
func _init(as_ok: bool, value: Variant) -> void:
	self._is_ok = as_ok
	self._value = value


func _to_string() -> String:
	return _SHARED_IMPL.format_compact("Result.Ok({0})" if self._is_ok else "Result.Err({0})", self._value)


## Returns whether [member self] is [code]Ok(x)[/code].
func is_ok() -> bool:
	return self._is_ok


## Returns whether [member self] is [code]Err(e)[/code].
func is_err() -> bool:
	return not self._is_ok


## Returns whether [member self] is [code]Ok(x)[/code] where [code]x[/code] satisfies the predicate [param p].
func is_ok_and(p: Callable) -> bool:
	if self._is_ok:
		var passed: bool = p.call(self._value)
		return passed
	return false


## Returns whether [member self] is [code]Err(e)[/code] where [code]e[/code] satisfies the predicate [param p].
func is_err_and(p: Callable) -> bool:
	if self._is_ok:
		return false
	var passed: bool = p.call(self._value)
	return passed


## Calls [param f] when [member self] is [code]Ok(x)[/code]. Returns [member self] regardless.
func tee(f: Callable) -> Result:
	if self._is_ok:
		f.call(self._value)
	return self


## Calls [param f] when [member self] is [code]Err(e)[/code]. Returns [member self] regardless.
func tee_err(f: Callable) -> Result:
	if not self._is_ok:
		f.call(self._value)
	return self


## Returns [code]x[/code] when [member self] is [code]Ok(x)[/code], otherwise crashes the game with [method OS.crash].
func unwrap(e := "[method Result.unwrap] called on Err") -> Variant:
	if not self._is_ok:
		OS.crash(e)
	return self._value


## Returns [code]e[/code] when [member self] is [code]Err(e)[/code], otherwise crashes the game with [method OS.crash].
func unwrap_err(e := "[method Result.unwrap_err] called on Ok") -> Variant:
	if self._is_ok:
		OS.crash(e)
	return self._value


## Returns [code]x[/code] when [member self] is [code]Ok(x)[/code], otherwise [param other].
func unwrap_or(other: Variant) -> Variant:
	if self._is_ok:
		return self._value
	return other


## Returns [code]x[/code] when [member self] is [code]Ok(x)[/code], otherwise [code]f(e)[/code] from [code]Err(e)[/code].
func unwrap_or_call(f: Callable) -> Variant:
	if self._is_ok:
		return self._value
	return f.call(self._value)


## Returns [code]Ok(f(x))[/code] when [member self] is [code]Ok(x)[/code], otherwise [member self].
func map(f: Callable) -> Result:
	if self._is_ok:
		return Ok(f.call(self._value))
	return self


## Returns [code]Err(f(e))[/code] when [member self] is [code]Err(e)[/code], otherwise [member self].
func map_err(f: Callable) -> Result:
	if self._is_ok:
		return self
	return Err(f.call(self._value))


## Returns [code]f(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [param d].
func map_or(d: Variant, f: Callable) -> Variant:
	if self._is_ok:
		return f.call(self._value)
	return d


## Returns [code]f(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [code]d(e)[/code] from [code]Err(e)[/code].
func map_or_call(d: Callable, f: Callable) -> Variant:
	if self._is_ok:
		return f.call(self._value)
	return d.call(self._value)


## Returns [param other] when [member self] is [code]Ok(x)[/code], otherwise [member self].
func and_then(other: Result) -> Result:
	if self._is_ok:
		return other
	return self


## Returns [code]f(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [member self].[br]
## [br]
## [param f] must return [Result].
func and_then_call(f: Callable) -> Result:
	if self._is_ok:
		var other: Result = f.call(self._value)
		return other
	return self


## Returns [param other] when [member self] is [code]Err(e)[/code], otherwise [member self].
func or_else(other: Result) -> Result:
	if self._is_ok:
		return self
	return other


## Returns [code]f(e)[/code] when [member self] is [code]Err(e)[/code], otherwise [member self].[br]
## [br]
## [param f] must return [Result].
func or_else_call(f: Callable) -> Result:
	if self._is_ok:
		return self
	var other: Result = f.call(self._value)
	return other


## Returns [Result] when [member self] is [code]Ok(Result)[/code], otherwise [member self].
func flatten() -> Result:
	if self._is_ok and self._value is Result:
		var inner: Result = self._value
		return inner
	return self


## Returns [code]Some(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [code]None[/code].
func ok() -> Option:
	if self._is_ok:
		return Option.Some(self._value)
	return Option.None


## Returns [code]Some(e)[/code] when [member self] is [code]Err(e)[/code], otherwise [code]None[/code].
func err() -> Option:
	if self._is_ok:
		return Option.None
	return Option.Some(self._value)


## Transposes a [code]Result(Option)[/code] into an [code]Option(Result)[/code].
##
## [codeblock]
## self is Result.Ok(Option.None)    → Option.None
## self is Result.Ok(Option.Some(x)) → Option.Some(Result.Ok(x))
## self is Result.Err(e)             → Option.Some(Result.Err(e))
## self is Result.Ok(_)              → Option.Some(Result.GdErr(Error.ERR_INVALID_DATA))
## [/codeblock]
func transpose() -> Option:
	if not self._is_ok:
		return Option.Some(self)
	if self._value is not Option:
		return Option.Some(Result.GdErr(Error.ERR_INVALID_DATA))
	var option_value: Option = self._value
	if option_value._is_some:
		return Option.Some(Result.Ok(option_value._value))
	return Option.None


## Returns whether [member self] and [param other] are strictly equal with [code]==[/code].
func is_equal(other: Result) -> bool:
	if other is Result:
		return self._is_ok == other._is_ok and self._value == other._value
	return false


## Returns whether [member self] and [param other] satisfy the [code]is_equal_approx[/code] function (if applicable),
## otherwise whether they are strictly equal with [code]==[/code].
func is_equal_approx(other: Result) -> bool:
	if other is Result:
		return self._is_ok == other._is_ok and _SHARED_IMPL.equal_approx(self._value, other._value)
	return false
