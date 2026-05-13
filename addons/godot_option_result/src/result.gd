class_name Result
extends RefCounted
## Immutable.

var _is_ok: bool
var _value: Variant


## [code]Ok(x)[/code] holds a success value [param x].
static func Ok(x: Variant = null) -> Result:
	return Result.new(true, x)


## [code]Err(e)[/code] holds an error value [param e].
static func Err(e: Variant = null) -> Result:
	return Result.new(false, e)


## Returns [code]Ok(Error.OK)[/code] when [param e] is [constant @GlobalScope.OK], otherwise
## [code]Err(error_string(e))[/code].
static func GdErr(e: Error) -> Result:
	if e == Error.OK:
		return Ok(Error.OK)
	return Err(error_string(e))


## [code]Ok(instance.member)[/code] when [param member_name] is a valid property on [param instance], otherwise
## [code]Err(error_string)[/code].
static func take_member(instance: Variant, member_name: StringName) -> Result:
	if not is_instance_valid(instance):
		return GdErr(ERR_INVALID_PARAMETER)
	if member_name not in instance:
		return GdErr(ERR_INVALID_DECLARATION)
	return Ok(instance.get(member_name))


## [code]Ok(instance.method(...method_args))[/code] when [param method_name] is a valid method on [param instance],
## otherwise [code]Err(error_string)[/code]. The call will be made with [param method_args] as arguments.
static func make_method_call(instance: Variant, method_name: StringName, ...method_args: Array) -> Result:
	if not is_instance_valid(instance):
		return GdErr(ERR_INVALID_PARAMETER)
	if not instance.has_method(method_name):
		return GdErr(ERR_INVALID_DECLARATION)
	return Ok(Callable(instance, method_name).callv(method_args))


## Private constructor.
func _init(as_ok: bool, value: Variant) -> void:
	self._is_ok = as_ok
	self._value = value


func _to_string() -> String:
	var format_str := "Ok({0})" if self._is_ok else "Err({0})"
	var value_str := var_to_str(self._value) if self._value is String or self._value is StringName else str(self._value)
	return format_str.format([value_str])


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
func pipe(f: Callable) -> Result:
	if self._is_ok:
		f.call(self._value)
	return self


## Calls [param f] when [member self] is [code]Err(e)[/code]. Returns [member self] regardless.
func pipe_err(f: Callable) -> Result:
	if not self._is_ok:
		f.call(self._value)
	return self


## Returns [code]x[/code] when [member self] is [code]Ok(x)[/code], otherwise fails with
## [method @GlobalScope.assert] in debug builds and [method OS.crash] in release/non-debug builds.[br]
## [br]
## Calls [method String.format] on [param msg] to embed [member self] into the [code]{0}[/code] placeholder.
func unwrap(msg: String = "[method Result.unwrap] called on {0}") -> Variant:
	if not self._is_ok:
		if OS.is_debug_build():
			assert(false, msg.format([self.to_string()]))
		else:
			OS.crash(msg.format([self.to_string()]))
	return self._value


## Returns [code]e[/code] when [member self] is [code]Err(e)[/code], otherwise fails with
## [method @GlobalScope.assert] in debug builds and [method OS.crash] in release/non-debug builds.[br]
## [br]
## Calls [method String.format] on [param msg] to embed [member self] into the [code]{0}[/code] placeholder.
func unwrap_err(msg: String = "[method Result.unwrap_err] called on {0}") -> Variant:
	if self._is_ok:
		if OS.is_debug_build():
			assert(false, msg.format([self.to_string()]))
		else:
			OS.crash(msg.format([self.to_string()]))
	return self._value


## Returns [code]x[/code] when [member self] is [code]Ok(x)[/code], otherwise [param other].
func unwrap_or(other: Variant) -> Variant:
	if self._is_ok:
		return self._value
	return other


## Returns [code]x[/code] when [member self] is [code]Ok(x)[/code], otherwise [code]f(e)[/code] when [member self] is
## [code]Err(e)[/code].
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


## Returns [code]f(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [code]d(e)[/code] when [member self] is
## [code]Err(e)[/code].
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


## Returns [code]Ok(val)[/code] when [member self] is [code]Err(ok_err)[/code], otherwise [member self].
func recover_with(ok_err: Variant, val: Variant) -> Result:
	if self._is_ok or self._value != ok_err:
		return self
	return Result.Ok(val)


## Returns [code]Ok(f(ok_err))[/code] when [member self] is [code]Err(ok_err)[/code], otherwise [member self].
func recover_with_call(ok_err: Variant, f: Callable) -> Result:
	if self._is_ok or self._value != ok_err:
		return self
	return Result.Ok(f.call(self._value))


## Returns [code]Err(err)[/code] when [member self] is [code]Ok(bad_ok)[/code], otherwise [member self].
func reject_with(bad_ok: Variant, err: Variant) -> Result:
	if not self._is_ok or self._value != bad_ok:
		return self
	return Result.Err(err)


## Returns [code]Err(f(bad_ok))[/code] when [member self] is [code]Ok(bad_ok)[/code], otherwise [member self].
func reject_with_call(bad_ok: Variant, f: Callable) -> Result:
	if not self._is_ok or self._value != bad_ok:
		return self
	return Result.Err(f.call(self._value))


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


## Transposes a [code]Result[Option][/code] into an [code]Option[Result][/code].
##
## [codeblock]
## self is Result.Ok(Option.None)    -> Option.None
## self is Result.Ok(Option.Some(x)) -> Option.Some(Result.Ok(x))
## self is Result.Err(e)             -> Option.Some(Result.Err(e))
## self is Result.Ok(_)              -> Option.Some(Result.GdErr(Error.ERR_INVALID_DATA))
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
