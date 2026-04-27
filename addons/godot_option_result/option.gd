class_name Option
extends RefCounted
## Immutable.

const _SHARED_IMPL := preload("res://addons/godot_option_result/shared_impl.gd")

## [code]None[/code] holds nothing.
static var None := new()

var _value: Variant


## [code]Some(x)[/code] holds the non-null [param x].
static func Some(x: Variant) -> Option:
	assert(x != null, "[param x] must not be null")
	return Option.new(x)


## Returns [code]Some(x)[/code] when [param x] is not null, otherwise [code]None[/code].
static func Maybe(x: Variant) -> Option:
	return None if x == null else Option.new(x)


## Private constructor.
func _init(x: Variant = null) -> void:
	self._value = x


func _to_string() -> String:
	return _SHARED_IMPL.format_compact("Some({0})", self._value) if self._value != null else "None"


## Returns whether [member self] is [code]Some(x)[/code].
func is_some() -> bool:
	return self._value != null


## Returns whether [member self] is [code]None[/code].
func is_none() -> bool:
	return self._value == null


## Returns [code]Ok(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [code]Err(e)[/code].
func ok_or(e: Variant) -> Result:
	if self._value != null:
		return Result.Ok(self._value)
	return Result.Err(e)


## Returns [code]Ok(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [code]Err(f())[/code].
func ok_or_call(f: Callable) -> Result:
	if self._value != null:
		return Result.Ok(self._value)
	return Result.Err(f.call())


## Returns [code]x[/code] when [member self] is [code]Some(x)[/code], otherwise crashes the game with an alert.
func unwrap(e := "[method Option.unwrap] called on None") -> Variant:
	if self._value == null:
		OS.alert(e)
		OS.kill(OS.get_process_id())
	return self._value


## Returns [code]x[/code] when [member self] is [code]Some(x)[/code], otherwise [param other].
func unwrap_or(other: Variant) -> Variant:
	if self._value != null:
		return self._value
	return other


## Returns [code]x[/code] when [member self] is [code]Some(x)[/code], otherwise [code]f()[/code].
func unwrap_or_call(f: Callable) -> Variant:
	if self._value != null:
		return self._value
	return f.call()


## Returns [code]Maybe(f(x))[/code] when [member self] is [code]Some(x)[/code], otherwise [code]None[/code].
func map(f: Callable) -> Option:
	if self._value != null:
		return Maybe(f.call(self._value))
	return self


## Returns [param other] when [member self] is [code]None[/code], otherwise [member self].
func or_else(other: Option) -> Option:
	if self._value == null:
		return other
	return self


## Returns [code]f()[/code] when [member self] is [code]None[/code], otherwise [member self].[br]
## [br]
## [param f] must return [Option].
func or_else_call(f: Callable) -> Option:
	if self._value == null:
		var other: Option = f.call()
		return other
	return self


## Returns [param other] when [member self] is [code]Some(x)[/code], otherwise [code]None[/code].
func and_then(other: Option) -> Option:
	if self._value != null:
		return other
	return self


## Returns [code]f(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [code]None[/code].[br]
## [br]
## [param f] must return an [Option].
func and_then_call(f: Callable) -> Option:
	if self._value != null:
		var other: Option = f.call(self._value)
		return other
	return self


## Returns [code]Some(x)[/code] when exactly one of [member self] and [param other] is [code]Some(x)[/code], otherwise [code]None[/code].
func xor_with(other: Option) -> Option:
	if (self._value == null) != (other._value == null):
		return other if self._value == null else self
	return None


## Returns [code]Some(x)[/code] when exactly one of [member self] and [code]f()[/code] is [code]Some(x)[/code], otherwise [code]None[/code].[br]
## [br]
## [param f] must return an [Option].
func xor_with_call(f: Callable) -> Option:
	var other: Option = f.call()
	if (self._value == null) != (other._value == null):
		return other if self._value == null else self
	return None


## Returns [code]Maybe(x)[/code] when [member self] is [code]Some(Maybe(x))[/code] (recursively), otherwise [member self].
func flatten() -> Option:
	if self._value is not Option:
		return self
	return self._value.flatten()


## Returns [code]Some(x)[/code] when [member self] is [code]Some(x)[/code] that satisfies the predicate [param p], otherwise [code]None[/code].
func keep_when(p: Callable) -> Option:
	if self._value != null and p.call(self._value):
		return self
	return None


## Returns [code]Some(x)[/code] when [member self] is [code]Some(x)[/code] that [i]doesn't[/i] satisfy the predicate [param p], otherwise [code]None[/code].
func drop_when(p: Callable) -> Option:
	if self._value != null and not p.call(self._value):
		return self
	return None


## Returns whether the values of [member self] and [param other] are strictly equal with [code]==[/code].
func is_equal(other: Option) -> bool:
	if other is Option:
		return self._value == other._value
	return false


## Returns whether the values of [member self] and [param other] satisfy the [code]is_equal_approx[/code] function (if
## applicable), otherwise whether they are strictly equal with [code]==[/code].
func is_equal_approx(other: Option) -> bool:
	if other is Option:
		return _SHARED_IMPL.equal_approx(self._value, other._value)
	return false
