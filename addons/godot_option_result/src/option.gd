class_name Option
extends RefCounted
## Immutable.

const _SHARED_IMPL := preload("res://addons/godot_option_result/src/shared_impl.gd")

## [code]None[/code] holds nothing.
static var None := new()

var _is_some: bool
var _value: Variant


## [code]Some(x)[/code] holds [param x].
static func Some(x: Variant) -> Option:
	return Option.new(true, x)


## Private constructor.
func _init(as_some: bool = false, x: Variant = null) -> void:
	self._is_some = as_some
	self._value = x if self._is_some else null


func _to_string() -> String:
	return _SHARED_IMPL.format_compact("Option.Some({0})", self._value) if self._is_some else "Option.None"


## Returns whether [member self] is [code]Some(x)[/code].
func is_some() -> bool:
	return self._is_some


## Returns whether [member self] is [code]None[/code].
func is_none() -> bool:
	return not self._is_some


## Returns whether [member self] is [code]Some(x)[/code] where [code]x[/code] satisfies predicate [param p].
func is_some_and(p: Callable) -> bool:
	if self._is_some:
		var passed: bool = p.call(self._value)
		return passed
	return false


## Returns whether [member self] is [code]None[/code] [i]or[/i] [code]Some(x)[/code] where [code]x[/code] satisfies the
## predicate [param p].
func is_none_or(p: Callable) -> bool:
	if self._is_some:
		var passed: bool = p.call(self._value)
		return passed
	return true


## Calls [param f] when [member self] is [code]Some(x)[/code]. Returns [member self] regardless.
func tee(f: Callable) -> Option:
	if self._is_some:
		f.call(self._value)
	return self


## Returns [code]x[/code] when [member self] is [code]Some(x)[/code], otherwise fails with
## [method @GlobalScope.assert] in debug builds and [method OS.crash] in non-debug/exported builds.
func unwrap(msg := "[method Option.unwrap] called on {0}") -> Variant:
	if not self._is_some:
		if OS.is_debug_build():
			assert(false, msg.format([self.to_string()]))
		else:
			OS.crash(msg.format([self.to_string()]))
	return self._value


## Returns [code]x[/code] when [member self] is [code]Some(x)[/code], otherwise [param other].
func unwrap_or(other: Variant) -> Variant:
	if self._is_some:
		return self._value
	return other


## Returns [code]x[/code] when [member self] is [code]Some(x)[/code], otherwise [code]f()[/code].
func unwrap_or_call(f: Callable) -> Variant:
	if self._is_some:
		return self._value
	return f.call()


## Returns [code]Some(f(x))[/code] when [member self] is [code]Some(x)[/code], otherwise [code]None[/code].
func map(f: Callable) -> Option:
	if self._is_some:
		return Some(f.call(self._value))
	return self


## Returns [code]f(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [param d].
func map_or(d: Variant, f: Callable) -> Variant:
	if self._is_some:
		return f.call(self._value)
	return d


## Returns [code]f(x)[/code] when [member self] is [code]Some(x)[/code], otherwise the return value of [param d].
func map_or_call(d: Callable, f: Callable) -> Variant:
	if self._is_some:
		return f.call(self._value)
	return d.call()


## Returns [code]Some(x)[/code] when [member self] is [code]Some(x)[/code] that satisfies the predicate [param p],
## otherwise [code]None[/code].
func keep_when(p: Callable) -> Option:
	if self._is_some and p.call(self._value):
		return self
	return None


## Returns [code]Some(x)[/code] when [member self] is [code]Some(x)[/code] that fails the predicate [param p], otherwise
## [code]None[/code].
func drop_when(p: Callable) -> Option:
	if self._is_some and not p.call(self._value):
		return self
	return None


## Returns [param other] when [member self] is [code]Some(x)[/code], otherwise [code]None[/code].
func and_then(other: Option) -> Option:
	if self._is_some:
		return other
	return self


## Returns [code]f(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [code]None[/code].[br]
## [br]
## [param f] must return an [Option].
func and_then_call(f: Callable) -> Option:
	if self._is_some:
		var other: Option = f.call(self._value)
		return other
	return self


## Returns [param other] when [member self] is [code]None[/code], otherwise [member self].
func or_else(other: Option) -> Option:
	if self._is_some:
		return self
	return other


## Returns [code]f()[/code] when [member self] is [code]None[/code], otherwise [member self].[br]
## [br]
## [param f] must return [Option].
func or_else_call(f: Callable) -> Option:
	if self._is_some:
		return self
	var other: Option = f.call()
	return other


## Returns [code]Some(x)[/code] when exactly one of [member self] and [param other] is [code]Some(x)[/code], otherwise
## [code]None[/code].
func xor_with(other: Option) -> Option:
	if self._is_some != other._is_some:
		return self if self._is_some else other
	return None


## Returns [Option] when [member self] is [code]Some(Option)[/code], otherwise [member self].
func flatten() -> Option:
	if self._is_some and self._value is Option:
		var inner: Option = self._value
		return inner
	return self


## Returns [code]Ok(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [code]Err(e)[/code].
func ok_or(e: Variant) -> Result:
	if self._is_some:
		return Result.Ok(self._value)
	return Result.Err(e)


## Returns [code]Ok(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [code]Err(f())[/code].
func ok_or_call(f: Callable) -> Result:
	if self._is_some:
		return Result.Ok(self._value)
	return Result.Err(f.call())


## Transposes an [code]Option(Result)[/code] into a [code]Result(Option)[/code].
##
## [codeblock]
## self is Option.None                → Result.Ok(Option.None)
## self is Option.Some(Result.Ok(x))  → Result.Ok(Option.Some(x))
## self is Option.Some(Result.Err(e)) → Result.Err(e)
## self is Option.Some(_)             → Result.GdErr(Error.ERR_INVALID_DATA)
## [/codeblock]
func transpose() -> Result:
	if not self._is_some:
		return Result.Ok(None)
	if self._value is not Result:
		return Result.GdErr(Error.ERR_INVALID_DATA)
	var result_value: Result = self._value
	if result_value.is_err():
		return result_value
	return Result.Ok(Some(result_value._value))


## Returns whether the values of [member self] and [param other] are strictly equal with [code]==[/code].
func is_equal(other: Option) -> bool:
	if other is Option:
		if self._is_some and other._is_some:
			return self._value == other._value
		return self._is_some == other._is_some
	return false


## Returns whether the values of [member self] and [param other] satisfy the [code]is_equal_approx[/code] function (if
## applicable), otherwise whether they are strictly equal with [code]==[/code].
func is_equal_approx(other: Option) -> bool:
	if other is Option:
		if self._is_some and other._is_some:
			return _SHARED_IMPL.equal_approx(self._value, other._value)
		return self._is_some == other._is_some
	return false
