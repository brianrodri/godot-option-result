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


## Returns [code]Ok(code)[/code] when [param code] is [constant @GlobalScope.OK], otherwise [code]Err(code)[/code].
static func GdError(code: Error) -> Result:
	if code == Error.OK:
		return Ok(Error.OK)
	return Err(_SHARED_IMPL.ERR_NAMES.get(code, "GdError called with unexpected [enum @GlobalScope.Error]"))


## Private constructor.
func _init(as_ok: bool, value: Variant = null) -> void:
	self._is_ok = as_ok
	self._value = value


func _to_string() -> String:
	return _SHARED_IMPL.format_compact("Ok({0})" if self._is_ok else "Err({0})", self._value)


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
	if not self._is_ok:
		var passed: bool = p.call(self._value)
		return passed
	return false


## Returns [code]Maybe(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [code]None[/code].
func ok() -> Option:
	if self._is_ok:
		return Option.Maybe(self._value)
	return Option.None


## Returns [code]Maybe(e)[/code] when [member self] is [code]Err(e)[/code], otherwise [code]None[/code].
func err() -> Option:
	if not self._is_ok:
		return Option.Maybe(self._value)
	return Option.None


## Returns [code]Ok(f(x))[/code] when [member self] is [code]Ok(x)[/code], otherwise [member self].
func map(f: Callable) -> Result:
	if self._is_ok:
		return Result.new(true, f.call(self._value))
	return self


## Returns [code]Err(f(e))[/code] when [member self] is [code]Err(e)[/code], otherwise [member self].
func map_err(f: Callable) -> Result:
	if not self._is_ok:
		return Result.new(false, f.call(self._value))
	return self


## Returns [code]x[/code] when [member self] is [code]Ok(x)[/code], otherwise crashes the game with an alert.
func unwrap(e := "[method Result.unwrap] called on Err") -> Variant:
	if not self._is_ok:
		OS.alert(e)
		OS.kill(OS.get_process_id())
	return self._value


## Returns [code]e[/code] when [member self] is [code]Err(e)[/code], otherwise crashes the game with an alert.
func unwrap_err(e := "[method Result.unwrap_err] called on Ok") -> Variant:
	if self._is_ok:
		OS.alert(e)
		OS.kill(OS.get_process_id())
	return self._value


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
	if not self._is_ok:
		return other
	return self


## Returns [code]f(e)[/code] when [member self] is [code]Err(e)[/code], otherwise [member self].[br]
## [br]
## [param f] must return [Result].
func or_else_call(f: Callable) -> Result:
	if not self._is_ok:
		var other: Result = f.call(self._value)
		return other
	return self


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
