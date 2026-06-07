@tool
class_name Result
extends RefCounted

const ERR_ILLEGAL_UNWRAP := "[method Result.unwrap] called on Err"
const ERR_ILLEGAL_UNWRAP_ERR := "[method Result.unwrap_err] called on Ok"
const ERR_ILLEGAL_TRANSPOSE := (
		"[method Result.transpose] when [member self] is [code]Ok(x)[/code] requires [code]x[/code] to be [Option]"
)
const ERR_UNSAFE_CALLABLE := "[param callable] must be valid [Callable]"
const ERR_UNSAFE_ARGUMENTS := (
		"[param arguments] size must match the [method Callable.get_argument_count] of [param callable]"
)
const ERR_UNSAFE_MEMBER_ACCESS := "[param member_name] must be valid property on [param instance]"
const ERR_UNSAFE_METHOD_ACCESS := "[param method_name] must be valid method on [param instance]"
const WARN_ILLEGAL_FLATTEN := (
		"[method Result.flatten] when [member self] is [code]Ok(x)[/code] requires [code]x[/code] to be [Result]"
)

var _is_ok: bool
var _value: Variant


## Constructs [code]Ok(x)[/code] holding [param x].
static func Ok(x: Variant = null) -> Result:
	return new(x, true)


## Constructs [code]Err(e)[/code] holding [param e].
static func Err(e: Variant = null) -> Result:
	return new(e, false)


## Constructs [Result] from the built-in [enum @GlobalScope.Error] enum.
##
## [codeblock]
## GdErr(Error.OK)   -> Ok(Error.OK)
## GdErr(other_code) -> Err(error_string(other_code))
## [/codeblock]
static func GdErr(code: Error) -> Result:
	if code == Error.OK:
		return Ok(Error.OK)
	return Err(error_string(code))


## Calls [param callable] safely, wrapping its return value or the reason it failed in a [Result].
##
## [codeblock]
## safe_call(callable, ...arguments) when valid call           -> Ok(callable.callv(arguments))
## safe_call(callable, ...arguments) when invalid callable     -> Err(ERR_UNSAFE_CALLABLE)
## safe_call(callable, ...arguments) when wrong argument count -> Err(ERR_UNSAFE_ARGUMENTS)
## [/codeblock]
static func safe_call(callable: Callable, ...arguments: Array) -> Result:
	if not callable.is_valid():
		return Err(ERR_UNSAFE_CALLABLE)
	if arguments.size() != callable.get_argument_count():
		return Err(ERR_UNSAFE_ARGUMENTS)
	return Ok(callable.callv(arguments))


## Reads [param member_name] from [param instance] into a [Result].
##
## [codeblock]
## safe_member(instance, member_name) when valid access   -> Ok(instance.member)
## safe_member(instance, member_name) when invalid access -> Err(ERR_UNSAFE_MEMBER_ACCESS)
## [/codeblock]
static func safe_member(instance: Variant, member_name: StringName) -> Result:
	if not is_instance_valid(instance) or member_name not in instance:
		return Err(ERR_UNSAFE_MEMBER_ACCESS)
	return Ok(instance.get(member_name))


## Calls [param method_name] on [param instance], wrapping its return value or the reason it failed in a [Result].
##
## [codeblock]
## safe_method_call(instance, method_name, ...arguments) when valid call           -> Ok(instance.method(...arguments))
## safe_method_call(instance, method_name, ...arguments) when invalid method       -> Err(ERR_UNSAFE_METHOD_ACCESS)
## safe_method_call(instance, method_name, ...arguments) when wrong argument count -> Err(ERR_UNSAFE_ARGUMENTS)
## [/codeblock]
static func safe_method_call(instance: Variant, method_name: StringName, ...arguments: Array) -> Result:
	var callable := Callable.create(instance, method_name)
	if not callable.is_valid():
		return Err(ERR_UNSAFE_METHOD_ACCESS)
	if arguments.size() != callable.get_argument_count():
		return Err(ERR_UNSAFE_ARGUMENTS)
	return Ok(callable.callv(arguments))


func _init(x: Variant, as_ok: bool) -> void:
	_value = x
	_is_ok = bool(as_ok)


func _to_string() -> String:
	var format_str := "Ok({0})" if _is_ok else "Err({0})"
	var value_str := var_to_str(_value) if _value is String or _value is StringName else str(_value)
	return format_str.format([value_str])


## Returns whether [member self] is an [code]Ok[/code] [Result].
##
## [codeblock]
## self is Ok(x)  -> true
## self is Err(e) -> false
## [/codeblock]
func is_ok() -> bool:
	return _is_ok


## Returns whether [member self] is an [code]Err[/code] [Result].
##
## [codeblock]
## self is Ok(x)  -> false
## self is Err(e) -> true
## [/codeblock]
func is_err() -> bool:
	return not _is_ok


## Returns whether [member self] is [code]Ok(x)[/code] and [param predicate] returns truthy for [code]x[/code].
##
## [codeblock]
## self is Ok(x) when predicate.call(x) is truthy -> true
## self is Ok(x) when predicate.call(x) is falsy  -> false
## self is Err(e)                                 -> false
## [/codeblock]
func is_ok_and(predicate: Callable) -> bool:
	if _is_ok:
		assert(predicate.is_valid())
		return bool(predicate.call(_value))
	return false


## Returns whether [member self] is [code]Ok(x)[/code] and [code]x.member[/code] is truthy.
##
## [codeblock]
## self is Ok(x) when x.member is truthy -> true
## self is Ok(x) when x.member is falsy  -> false
## self is Ok(x) when invalid access     -> false
## self is Err(e)                        -> false
## [/codeblock]
func is_ok_and_member(member_name: StringName) -> bool:
	if _is_ok:
		return bool(safe_member(_value, member_name).unwrap_or(false))
	return false


## Returns whether [member self] is [code]Ok(x)[/code] and [code]x.method(...arguments)[/code] is truthy.
##
## [codeblock]
## self is Ok(x) when x.method(...arguments) is truthy -> true
## self is Ok(x) when x.method(...arguments) is falsy  -> false
## self is Ok(x) when invalid call                     -> false
## self is Err(e)                                      -> false
## [/codeblock]
func is_ok_and_method_call(method_name: StringName, ...arguments: Array) -> bool:
	if _is_ok:
		return bool(safe_method_call.bindv(arguments).call(_value, method_name).unwrap_or(false))
	return false


## Returns whether [member self] is [code]Err(e)[/code] and [param predicate] returns truthy for [code]e[/code].
##
## [codeblock]
## self is Ok(x)                                   -> false
## self is Err(e) when predicate.call(e) is truthy -> true
## self is Err(e) when predicate.call(e) is falsy  -> false
## [/codeblock]
func is_err_and(predicate: Callable) -> bool:
	if _is_ok:
		return false
	assert(predicate.is_valid())
	return bool(predicate.call(_value))


## Returns whether [member self] is [code]Err(e)[/code] and [code]e.member[/code] is truthy.
##
## [codeblock]
## self is Ok(x)                           -> false
## self is Err(e) when e.member is truthy  -> true
## self is Err(e) when e.member is falsy   -> false
## self is Err(e) when invalid access      -> false
## [/codeblock]
func is_err_and_member(member_name: StringName) -> bool:
	if _is_ok:
		return false
	return bool(safe_member(_value, member_name).unwrap_or(false))


## Returns whether [member self] is [code]Err(e)[/code] and [code]e.method(...arguments)[/code] is truthy.
##
## [codeblock]
## self is Ok(x)                                       -> false
## self is Err(e) when e.method(...arguments) is truthy -> true
## self is Err(e) when e.method(...arguments) is falsy  -> false
## self is Err(e) when invalid call                     -> false
## [/codeblock]
func is_err_and_method_call(method_name: StringName, ...arguments: Array) -> bool:
	if _is_ok:
		return false
	return bool(safe_method_call.bindv(arguments).call(_value, method_name).unwrap_or(false))


## Calls [param callable] with the wrapped value when [member self] is [code]Ok[/code], then returns [member self].
##
## [codeblock]
## self is Ok(x)  -> calls callable.call(x); returns self
## self is Err(e) -> returns self
## [/codeblock]
func pipe(callable: Callable) -> Result:
	if _is_ok:
		assert(callable.is_valid())
		callable.call(_value)
	return self


## Calls [param callable] with the wrapped error when [member self] is [code]Err[/code], then returns [member self].
##
## [codeblock]
## self is Ok(x)  -> returns self
## self is Err(e) -> calls callable.call(e); returns self
## [/codeblock]
func pipe_err(callable: Callable) -> Result:
	if not _is_ok:
		assert(callable.is_valid())
		callable.call(_value)
	return self


## Returns the wrapped value, asserting that [member self] is [code]Ok[/code].
##
## [codeblock]
## self is Ok(x)  -> x
## self is Err(e) -> asserts with [constant ERR_ILLEGAL_UNWRAP] and returns null
## [/codeblock]
func unwrap() -> Variant:
	if not _is_ok:
		assert(false, ERR_ILLEGAL_UNWRAP)
		return null
	return _value


## Returns the wrapped error, asserting that [member self] is [code]Err[/code].
##
## [codeblock]
## self is Ok(x)  -> asserts with [constant ERR_ILLEGAL_UNWRAP_ERR]
## self is Err(e) -> e
## [/codeblock]
func unwrap_err() -> Variant:
	if _is_ok:
		assert(false, ERR_ILLEGAL_UNWRAP_ERR)
		return null
	return _value


## Returns the wrapped value, or [param other] when [member self] is [code]Err[/code].
##
## [codeblock]
## self is Ok(x)  -> x
## self is Err(e) -> other
## [/codeblock]
func unwrap_or(other: Variant) -> Variant:
	if _is_ok:
		return _value
	return other


## Returns the wrapped value, or [code]callable.call(e)[/code] when [member self] is [code]Err(e)[/code].
##
## [codeblock]
## self is Ok(x)  -> x
## self is Err(e) -> callable.call(e)
## [/codeblock]
func unwrap_or_call(callable: Callable) -> Variant:
	if _is_ok:
		return _value
	assert(callable.is_valid())
	return callable.call(_value)


## Maps [code]Ok(x)[/code] to [code]Ok(callable.call(x))[/code], leaves [code]Err[/code] unchanged.
##
## [codeblock]
## self is Ok(x)  -> Ok(callable.call(x))
## self is Err(e) -> self
## [/codeblock]
func map(callable: Callable) -> Result:
	if _is_ok:
		assert(callable.is_valid())
		return Ok(callable.call(_value))
	return self


## Maps [code]Ok(x)[/code] to a [Result] wrapping [code]x.member[/code], leaves [code]Err[/code] unchanged.
##
## [codeblock]
## self is Ok(x) when valid access   -> Ok(x.member)
## self is Ok(x) when invalid access -> Err(ERR_UNSAFE_MEMBER_ACCESS)
## self is Err(e)                    -> self
## [/codeblock]
func map_member(member_name: StringName) -> Result:
	if _is_ok:
		return safe_member(_value, member_name)
	return self


## Maps [code]Ok(x)[/code] to a [Result] wrapping [code]x.method(...arguments)[/code], leaves [code]Err[/code]
## unchanged.
##
## [codeblock]
## self is Ok(x) when valid call   -> Ok(x.method(...arguments))
## self is Ok(x) when invalid call -> Err(ERR_UNSAFE_METHOD_ACCESS or ERR_UNSAFE_ARGUMENTS)
## self is Err(e)                  -> self
## [/codeblock]
func map_method_call(method_name: StringName, ...arguments: Array) -> Result:
	if _is_ok:
		return safe_method_call.bindv(arguments).call(_value, method_name)
	return self


## Maps [code]Err(e)[/code] to [code]Err(callable.call(e))[/code], leaves [code]Ok[/code] unchanged.
##
## [codeblock]
## self is Ok(x)  -> self
## self is Err(e) -> Err(callable.call(e))
## [/codeblock]
func map_err(callable: Callable) -> Result:
	if _is_ok:
		return self
	assert(callable.is_valid())
	return Err(callable.call(_value))


## Maps [code]Err(e)[/code] to a [Result] wrapping [code]e.member[/code], leaves [code]Ok[/code] unchanged.
##
## [codeblock]
## self is Ok(x)                      -> self
## self is Err(e) when valid access   -> Err(e.member)
## self is Err(e) when invalid access -> Err(ERR_UNSAFE_MEMBER_ACCESS)
## [/codeblock]
func map_err_member(member_name: StringName) -> Result:
	if _is_ok:
		return self
	var inner: Result = safe_member(_value, member_name)
	return Err(inner._value) if inner._is_ok else inner


## Maps [code]Err(e)[/code] to a [Result] wrapping [code]e.method(...arguments)[/code], leaves [code]Ok[/code]
## unchanged.
##
## [codeblock]
## self is Ok(x)                    -> self
## self is Err(e) when valid call   -> Err(e.method(...arguments))
## self is Err(e) when invalid call -> Err(ERR_UNSAFE_METHOD_ACCESS or ERR_UNSAFE_ARGUMENTS)
## [/codeblock]
func map_err_method_call(method_name: StringName, ...arguments: Array) -> Result:
	if _is_ok:
		return self
	var inner: Result = safe_method_call.bindv(arguments).call(_value, method_name)
	return Err(inner._value) if inner._is_ok else inner


## Returns [code]callable.call(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [param default].
##
## [codeblock]
## self is Ok(x)  -> callable.call(x)
## self is Err(e) -> default
## [/codeblock]
func map_or(default: Variant, callable: Callable) -> Variant:
	if _is_ok:
		assert(callable.is_valid())
		return callable.call(_value)
	return default


## Returns [code]x.member[/code] when accessible on [code]Ok(x)[/code], otherwise [param default].
##
## [codeblock]
## self is Ok(x) when valid access   -> x.member
## self is Ok(x) when invalid access -> default
## self is Err(e)                    -> default
## [/codeblock]
func map_member_or(default: Variant, member_name: StringName) -> Variant:
	if _is_ok:
		return safe_member(_value, member_name).unwrap_or(default)
	return default


## Returns [code]x.method(...arguments)[/code] when callable on [code]Ok(x)[/code], otherwise [param default].
##
## [codeblock]
## self is Ok(x) when valid call   -> x.method(...arguments)
## self is Ok(x) when invalid call -> default
## self is Err(e)                  -> default
## [/codeblock]
func map_method_call_or(default: Variant, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_ok:
		return safe_method_call.bindv(arguments).call(_value, method_name).unwrap_or(default)
	return default


## Returns [code]callable.call(e)[/code] when [member self] is [code]Err(e)[/code], otherwise [param default].
##
## [codeblock]
## self is Ok(x)  -> default
## self is Err(e) -> callable.call(e)
## [/codeblock]
func map_err_or(default: Variant, callable: Callable) -> Variant:
	if _is_ok:
		return default
	assert(callable.is_valid())
	return callable.call(_value)


## Returns [code]e.member[/code] when accessible on [code]Err(e)[/code], otherwise [param default].
##
## [codeblock]
## self is Ok(x)                      -> default
## self is Err(e) when valid access   -> e.member
## self is Err(e) when invalid access -> default
## [/codeblock]
func map_err_member_or(default: Variant, member_name: StringName) -> Variant:
	if _is_ok:
		return default
	return safe_member(_value, member_name).unwrap_or(default)


## Returns [code]e.method(...arguments)[/code] when callable on [code]Err(e)[/code], otherwise [param default].
##
## [codeblock]
## self is Ok(x)                    -> default
## self is Err(e) when valid call   -> e.method(...arguments)
## self is Err(e) when invalid call -> default
## [/codeblock]
func map_err_method_call_or(default: Variant, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_ok:
		return default
	return safe_method_call.bindv(arguments).call(_value, method_name).unwrap_or(default)


## Returns [code]callable.call(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [param default_provider]
## called with the wrapped error.
##
## [codeblock]
## self is Ok(x)  -> callable.call(x)
## self is Err(e) -> default_provider.call(e)
## [/codeblock]
func map_or_call(default_provider: Callable, callable: Callable) -> Variant:
	if _is_ok:
		assert(callable.is_valid())
		return callable.call(_value)
	assert(default_provider.is_valid())
	return default_provider.call(_value)


## Returns [code]x.member[/code] when accessible on [code]Ok(x)[/code], otherwise [param default_provider] called with
## the wrapped error.
##
## [codeblock]
## self is Ok(x) when valid access   -> x.member
## self is Ok(x) when invalid access -> default_provider.call(x)
## self is Err(e)                    -> default_provider.call(e)
## [/codeblock]
func map_member_or_call(default_provider: Callable, member_name: StringName) -> Variant:
	if _is_ok:
		return safe_member(_value, member_name).unwrap_or_call(default_provider.bind(_value).unbind(1))
	assert(default_provider.is_valid())
	return default_provider.call(_value)


## Returns [code]x.method(...arguments)[/code] when callable on [code]Ok(x)[/code], otherwise [param default_provider]
## called with the wrapped error.
##
## [codeblock]
## self is Ok(x) when valid call   -> x.method(...arguments)
## self is Ok(x) when invalid call -> default_provider.call(x)
## self is Err(e)                  -> default_provider.call(e)
## [/codeblock]
func map_method_call_or_call(default_provider: Callable, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_ok:
		return safe_method_call.bindv(arguments).call(_value, method_name).unwrap_or_call(
			default_provider.bind(_value).unbind(1),
		)
	assert(default_provider.is_valid())
	return default_provider.call(_value)


## Returns [code]callable.call(e)[/code] when [member self] is [code]Err(e)[/code], otherwise
## [param default_provider].
##
## [codeblock]
## self is Ok(x)  -> default_provider.call(x)
## self is Err(e) -> callable.call(e)
## [/codeblock]
func map_err_or_call(default_provider: Callable, callable: Callable) -> Variant:
	if _is_ok:
		assert(default_provider.is_valid())
		return default_provider.call(_value)
	assert(callable.is_valid())
	return callable.call(_value)


## Returns [code]e.member[/code] when accessible on [code]Err(e)[/code], otherwise [param default_provider] called
## with the wrapped value.
##
## [codeblock]
## self is Ok(x)                      -> default_provider.call(x)
## self is Err(e) when valid access   -> e.member
## self is Err(e) when invalid access -> default_provider.call(e)
## [/codeblock]
func map_err_member_or_call(default_provider: Callable, member_name: StringName) -> Variant:
	if _is_ok:
		assert(default_provider.is_valid())
		return default_provider.call(_value)
	return safe_member(_value, member_name).unwrap_or_call(default_provider.bind(_value).unbind(1))


## Returns [code]e.method(...arguments)[/code] when callable on [code]Err(e)[/code], otherwise [param default_provider]
## called with the wrapped value.
##
## [codeblock]
## self is Ok(x)                    -> default_provider.call(x)
## self is Err(e) when valid call   -> e.method(...arguments)
## self is Err(e) when invalid call -> default_provider.call(e)
## [/codeblock]
func map_err_method_call_or_call(default_provider: Callable, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_ok:
		assert(default_provider.is_valid())
		return default_provider.call(_value)
	return safe_method_call.bindv(arguments).call(_value, method_name).unwrap_or_call(
		default_provider.bind(_value).unbind(1),
	)


## Returns [param other] when [member self] is [code]Ok[/code], otherwise [member self].
##
## [codeblock]
## self is Ok(x)  -> other
## self is Err(e) -> self
## [/codeblock]
func and_then(other: Result) -> Result:
	if _is_ok:
		return other
	return self


## Returns [code]callable.call(x)[/code] when [member self] is [code]Ok(x)[/code], otherwise [member self].
##
## [codeblock]
## self is Ok(x)  -> callable.call(x)
## self is Err(e) -> self
## [/codeblock]
func and_then_call(callable: Callable) -> Result:
	if _is_ok:
		assert(callable.is_valid())
		var other: Result = callable.call(_value)
		return other
	return self


## Chains a [Result]-valued member access, flattening the result.
##
## [codeblock]
## self is Ok(x) when x.member is Result(y)  -> Result(y)
## self is Ok(x) when x.member is not Result -> Ok(x.member) [with warning]
## self is Ok(x) when invalid access         -> Err(ERR_UNSAFE_MEMBER_ACCESS)
## self is Err(e)                            -> self
## [/codeblock]
func and_then_member(member_name: StringName) -> Result:
	if _is_ok:
		var other: Result = safe_member(_value, member_name)
		return other.flatten()
	return self


## Chains a [Result]-valued method call, flattening the result.
##
## [codeblock]
## self is Ok(x) when x.method(...arguments) is Result(y)  -> Result(y)
## self is Ok(x) when x.method(...arguments) is not Result -> Ok(x.method(...arguments)) [with warning]
## self is Ok(x) when invalid call                         -> Err(ERR_UNSAFE_METHOD_ACCESS or ERR_UNSAFE_ARGUMENTS)
## self is Err(e)                                          -> self
## [/codeblock]
func and_then_method_call(method_name: StringName, ...arguments: Array) -> Result:
	if _is_ok:
		var other: Result = safe_method_call.bindv(arguments).call(_value, method_name)
		return other.flatten()
	return self


## Returns [member self] when [code]Ok[/code], otherwise [param other].
##
## [codeblock]
## self is Ok(x)  -> self
## self is Err(e) -> other
## [/codeblock]
func or_else(other: Result) -> Result:
	if _is_ok:
		return self
	return other


## Returns [member self] when [code]Ok[/code], otherwise [code]callable.call(e)[/code].
##
## [codeblock]
## self is Ok(x)  -> self
## self is Err(e) -> callable.call(e)
## [/codeblock]
func or_else_call(callable: Callable) -> Result:
	if _is_ok:
		return self
	assert(callable.is_valid())
	var other: Result = callable.call(_value)
	return other


## Recovers [code]Err(e)[/code] by reading [code]e.member[/code], leaves [code]Ok[/code] unchanged.
##
## [codeblock]
## self is Ok(x)                      -> self
## self is Err(e) when valid access   -> Ok(e.member)
## self is Err(e) when invalid access -> Err(ERR_UNSAFE_MEMBER_ACCESS)
## [/codeblock]
func or_else_member(member_name: StringName) -> Result:
	if _is_ok:
		return self
	var other: Result = safe_member(_value, member_name)
	return other


## Recovers [code]Err(e)[/code] by calling [code]e.method(...arguments)[/code], leaves [code]Ok[/code] unchanged.
##
## [codeblock]
## self is Ok(x)                    -> self
## self is Err(e) when valid call   -> Ok(e.method(...arguments))
## self is Err(e) when invalid call -> Err(ERR_UNSAFE_METHOD_ACCESS or ERR_UNSAFE_ARGUMENTS)
## [/codeblock]
func or_else_method_call(method_name: StringName, ...arguments: Array) -> Result:
	if _is_ok:
		return self
	var other: Result = safe_method_call.bindv(arguments).call(_value, method_name)
	return other


## Converts [member self] into an [Option], discarding any [code]Err[/code] value.
##
## [codeblock]
## self is Ok(x)  -> Some(x)
## self is Err(e) -> None
## [/codeblock]
func ok() -> Option:
	if _is_ok:
		return Option.Some(_value)
	return Option.None


## Converts [member self] into an [Option] over the [code]Err[/code] value, discarding any [code]Ok[/code] value.
##
## [codeblock]
## self is Ok(x)  -> None
## self is Err(e) -> Some(e)
## [/codeblock]
func err() -> Option:
	if _is_ok:
		return Option.None
	return Option.Some(_value)


## Flattens [code]Ok(Result)[/code] into the inner [Result].
##
## [codeblock]
## self is Ok(Result(x))      -> Result(x)
## self is Ok(not_a_result)   -> self [with warning]
## self is Err(e)             -> self
## [/codeblock]
func flatten() -> Result:
	if not _is_ok:
		return self
	if _value is not Result:
		push_warning(WARN_ILLEGAL_FLATTEN)
		return self
	var inner: Result = _value
	return inner


## Returns a [code]Result[/code] with the opposite wrapper; the inner value remains the same.
##
## [codeblock]
## self is Ok(x)  -> Err(x)
## self is Err(e) -> Ok(e)
## [/codeblock]
func invert() -> Result:
	if _is_ok:
		return Err(_value)
	return Ok(_value)


## Transposes a [code]Result[Option][/code] into an [code]Option[Result][/code].
##
## [codeblock]
## self is Ok(None)           -> None
## self is Ok(Some(x))        -> Some(Ok(x))
## self is Ok(not_an_option)  -> Some(Err(ERR_ILLEGAL_TRANSPOSE))
## self is Err(e)             -> Some(Err(e))
## [/codeblock]
func transpose() -> Option:
	if not _is_ok:
		return Option.Some(self)
	if _value is not Option:
		return Option.Some(Err(ERR_ILLEGAL_TRANSPOSE))
	var option_value: Option = _value
	if option_value._is_some:
		return Option.Some(Ok(option_value._value))
	return Option.None
