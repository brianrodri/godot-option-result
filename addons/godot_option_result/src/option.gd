class_name Option
extends RefCounted
## Immutable.

## [code]None[/code] holds nothing.
static var None := new()

var _is_some: bool
var _value: Variant


## [code]Some(x)[/code] holds [param x].
static func Some(x: Variant) -> Option:
	return Option.new(true, x)


## [code]Some(x)[/code] when [code]x[/code] is not [code]null[/code], otherwise [code]None[/code].
static func not_null(x: Variant) -> Option:
	if x != null:
		return Option.Some(x)
	return Option.None


## [code]Some(instance.member)[/code] when [param member_name] is a valid property on [param instance], otherwise
## [code]None[/code].
static func member(instance: Variant, member_name: StringName) -> Option:
	var result: Result = Result.safe_member(instance, member_name)
	return result.ok()


## Returns [code]Some(instance.method(...method_args))[/code] when [param method_name] is a valid method on
## [param instance] that can be invoked with [param method_args], otherwise [code]None[/code].
static func method_call(instance: Variant, method_name: StringName, ...method_args: Array) -> Option:
	if method_args.is_empty():
		return Result.safe_method_call(instance, method_name).ok()
	var result: Result = Result.safe_method_call.bindv(method_args).call(instance, method_name)
	return result.ok()


func _init(as_some: bool = false, x: Variant = null) -> void:
	self._is_some = as_some
	self._value = x if self._is_some else null


func _to_string() -> String:
	if not self._is_some:
		return "None"
	var value_str := var_to_str(self._value) if self._value is String or self._value is StringName else str(self._value)
	return "Some({0})".format([value_str])


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
func pipe(f: Callable) -> Option:
	if self._is_some:
		f.call(self._value)
	return self


## Returns [code]x[/code] when [member self] is [code]Some(x)[/code], otherwise fails with
## [method @GlobalScope.assert] in debug builds and [method OS.crash] in release/non-debug builds.[br]
## [br]
## Calls [method String.format] on [param msg] to embed [member self] into the [code]{0}[/code] placeholder.
func unwrap(msg: String = "[method Option.unwrap] called on {0}") -> Variant:
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


## [code]Some(x.member)[/code] when [param member_name] is a valid property on [code]x[/code] from [member self],
## otherwise [code]None[/code].
func and_then_member(member_name: StringName) -> Option:
	if self._is_some:
		return member(self._value, member_name)
	return self


## Returns [code]Some(x.method(...method_args))[/code] when [param method_name] is a valid method on
## [code]x[/code] from [member self] that can be invoked with [param method_args], otherwise [code]None[/code].
func and_then_method_call(method_name: StringName, ...method_args: Array) -> Option:
	if self._is_some:
		return method_call.bindv(method_args).call(self._value, method_name)
	return None


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


## Transposes an [code]Option[Result][/code] into a [code]Result[Option][/code].
##
## [codeblock]
## self is Option.None                -> Result.Ok(Option.None)
## self is Option.Some(Result.Ok(x))  -> Result.Ok(Option.Some(x))
## self is Option.Some(Result.Err(e)) -> Result.Err(e)
## self is Option.Some(_)             -> Result.GdErr(Error.ERR_INVALID_DATA)
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


func _iter_init(_iter: Array) -> bool:
	return self._is_some


func _iter_next(_iter: Array) -> bool:
	return false


func _iter_get(_iter: Variant) -> Variant:
	return self._value
