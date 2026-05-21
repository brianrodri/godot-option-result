class_name Option
extends RefCounted

const ERR_ILLEGAL_UNWRAP := "[method Option.unwrap] called on [code]None[/code]"
const ERR_ILLEGAL_TRANSPOSE := (
		"[method Option.transpose] when [member self] is [code]Some(x)[/code] requires [code]x[/code] to be [Result]"
)
const WARN_ILLEGAL_FLATTEN := (
		"[method Option.flatten] when [member self] is [code]Some(x)[/code] requires [code]x[/code] to be [Option]"
)

## Holds nothing.
static var None := new()

var _is_some: bool
var _value: Variant


## Holds [code]Some(x)[/code].
static func Some(x: Variant) -> Option:
	return new(true, x)


## Holds [code]Some(x)[/code] when [param x] is not null, otherwise [code]None[/code].
static func not_null(x: Variant) -> Option:
	return None if x == null else Some(x)


## Reads [param member_name] from [param instance] into an [Option].
static func from_member(instance: Variant, member_name: StringName) -> Option:
	return Result.safe_member(instance, member_name).ok()


## Calls [param method_name] on [param instance], wrapping its return value in an [Option].
static func from_method_call(instance: Variant, method_name: StringName, ...arguments: Array) -> Option:
	return Result.safe_method_call.bindv(arguments).call(instance, method_name).ok()


func _init(as_some: bool = false, x: Variant = null) -> void:
	_is_some = as_some
	_value = x if _is_some else null


func _to_string() -> String:
	if _is_some:
		var value_str := var_to_str(_value) if _value is String or _value is StringName else str(_value)
		return "Some({0})".format([value_str])
	return "None"


## Returns whether [member self] is [code]Some(x)[/code].
##
## [codeblock]
## self is Some(x) -> true
## self is None    -> false
## [/codeblock]
func is_some() -> bool:
	return _is_some


## Returns whether [member self] is [code]None[/code].
##
## [codeblock]
## self is Some(x) -> false
## self is None    -> true
## [/codeblock]
func is_none() -> bool:
	return not _is_some


## Returns whether [member self] is [code]Some(x)[/code] and [param predicate] returns truthy for [code]x[/code].
##
## [codeblock]
## self is Some(x) when predicate.call(x) is truthy -> true
## self is Some(x) when predicate.call(x) is falsy  -> false
## self is None                                     -> false
## [/codeblock]
func is_some_and(predicate: Callable) -> bool:
	if _is_some:
		assert(predicate.is_valid())
		return bool(predicate.call(_value))
	return false


## Returns whether [member self] is [code]None[/code], or [param predicate] returns truthy for the wrapped value.
##
## [codeblock]
## self is Some(x) when predicate.call(x) is truthy -> true
## self is Some(x) when predicate.call(x) is falsy  -> false
## self is None                                     -> true
## [/codeblock]
func is_none_or(predicate: Callable) -> bool:
	if _is_some:
		assert(predicate.is_valid())
		return bool(predicate.call(_value))
	return true


## Calls [param callable] with the wrapped value when [member self] is [code]Some[/code], then returns [member self].
##
## [codeblock]
## self is Some(x) -> calls callable.call(x); returns self
## self is None    -> returns self
## [/codeblock]
func pipe(callable: Callable) -> Option:
	if _is_some:
		assert(callable.is_valid())
		callable.call(_value)
	return self


## Returns the wrapped value, asserting that [member self] is [code]Some[/code].
##
## [codeblock]
## self is Some(x) -> x
## self is None    -> asserts with [constant ERR_ILLEGAL_UNWRAP] and returns null
## [/codeblock]
func unwrap() -> Variant:
	if not _is_some:
		assert(false, ERR_ILLEGAL_UNWRAP)
		return null
	return _value


## Returns the wrapped value, or [param other] when [member self] is [code]None[/code].
##
## [codeblock]
## self is Some(x) -> x
## self is None    -> other
## [/codeblock]
func unwrap_or(other: Variant) -> Variant:
	if _is_some:
		return _value
	return other


## Returns the wrapped value, or [code]callable.call()[/code] when [member self] is [code]None[/code].
##
## [codeblock]
## self is Some(x) -> x
## self is None    -> callable.call()
## [/codeblock]
func unwrap_or_call(callable: Callable) -> Variant:
	if _is_some:
		return _value
	assert(callable.is_valid())
	return callable.call()


## Maps [code]Some(x)[/code] to [code]Some(callable.call(x))[/code], leaves [code]None[/code] unchanged.
##
## [codeblock]
## self is Some(x) -> Some(callable.call(x))
## self is None    -> None
## [/codeblock]
func map(callable: Callable) -> Option:
	if _is_some:
		assert(callable.is_valid())
		return Some(callable.call(_value))
	return None


## Maps [code]Some(x)[/code] to an [Option] wrapping [code]x.member[/code], leaves [code]None[/code] unchanged.
##
## [codeblock]
## self is Some(x) when valid access   -> Some(x.member)
## self is Some(x) when invalid access -> None
## self is None                        -> None
## [/codeblock]
func map_member(member_name: StringName) -> Option:
	if _is_some:
		return from_member(_value, member_name)
	return None


## Maps [code]Some(x)[/code] to an [Option] wrapping [code]x.method(...arguments)[/code], leaves [code]None[/code]
## unchanged.
##
## [codeblock]
## self is Some(x) when valid call   -> Some(x.method(...arguments))
## self is Some(x) when invalid call -> None
## self is None                      -> None
## [/codeblock]
func map_method_call(method_name: StringName, ...arguments: Array) -> Option:
	if _is_some:
		return from_method_call.bindv(arguments).call(_value, method_name)
	return None


## Returns [code]callable.call(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [param default].
##
## [codeblock]
## self is Some(x) -> callable.call(x)
## self is None    -> default
## [/codeblock]
func map_or(default: Variant, callable: Callable) -> Variant:
	if _is_some:
		assert(callable.is_valid())
		return callable.call(_value)
	return default


## Returns [code]x.member[/code] when accessible on [code]Some(x)[/code], otherwise [param default].
##
## [codeblock]
## self is Some(x) when valid access   -> x.member
## self is Some(x) when invalid access -> default
## self is None                        -> default
## [/codeblock]
func map_member_or(default: Variant, member_name: StringName) -> Variant:
	if _is_some:
		return from_member(_value, member_name).unwrap_or(default)
	return default


## Returns [code]x.method(...arguments)[/code] when callable on [code]Some(x)[/code], otherwise [param default].
##
## [codeblock]
## self is Some(x) when valid call   -> x.method(...arguments)
## self is Some(x) when invalid call -> default
## self is None                      -> default
## [/codeblock]
func map_method_call_or(default: Variant, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_some:
		return from_method_call.bindv(arguments).call(_value, method_name).unwrap_or(default)
	return default


## Returns [code]callable.call(x)[/code] when [member self] is [code]Some(x)[/code], otherwise
## [code]default_provider.call()[/code].
##
## [codeblock]
## self is Some(x) -> callable.call(x)
## self is None    -> default_provider.call()
## [/codeblock]
func map_or_call(default_provider: Callable, callable: Callable) -> Variant:
	if _is_some:
		assert(callable.is_valid())
		return callable.call(_value)
	assert(default_provider.is_valid())
	return default_provider.call()


## Returns [code]x.member[/code] when accessible on [code]Some(x)[/code], otherwise
## [code]default_provider.call()[/code].
##
## [codeblock]
## self is Some(x) when valid access   -> x.member
## self is Some(x) when invalid access -> default_provider.call()
## self is None                        -> default_provider.call()
## [/codeblock]
func map_member_or_call(default_provider: Callable, member_name: StringName) -> Variant:
	if _is_some:
		return from_member(_value, member_name).unwrap_or_call(default_provider)
	assert(default_provider.is_valid())
	return default_provider.call()


## Returns [code]x.method(...arguments)[/code] when callable on [code]Some(x)[/code], otherwise
## [code]default_provider.call()[/code].
##
## [codeblock]
## self is Some(x) when valid call   -> x.method(...arguments)
## self is Some(x) when invalid call -> default_provider.call()
## self is None                      -> default_provider.call()
## [/codeblock]
func map_method_call_or_call(default_provider: Callable, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_some:
		return from_method_call.bindv(arguments).call(_value, method_name).unwrap_or_call(default_provider)
	assert(default_provider.is_valid())
	return default_provider.call()


## Keeps [member self] when [code]Some(x)[/code] satisfies [param predicate], otherwise collapses to [code]None[/code].
##
## [codeblock]
## self is Some(x) when predicate.call(x) is truthy -> self
## self is Some(x) when predicate.call(x) is falsy  -> None
## self is None                                     -> None
## [/codeblock]
func keep_when(predicate: Callable) -> Option:
	if _is_some:
		assert(predicate.is_valid())
		return self if predicate.call(_value) else None
	return None


## Keeps [member self] when [code]x.member[/code] is truthy, otherwise collapses to [code]None[/code].
##
## [codeblock]
## self is Some(x) when x.member is truthy -> self
## self is Some(x) when x.member is falsy  -> None
## self is Some(x) when invalid access     -> None
## self is None                            -> None
## [/codeblock]
func keep_when_member(member_name: StringName) -> Option:
	if _is_some and from_member(_value, member_name).unwrap_or(false):
		return self
	return None


## Keeps [member self] when [code]x.method(...arguments)[/code] is truthy, otherwise collapses to
## [code]None[/code].
##
## [codeblock]
## self is Some(x) when x.method(...arguments) is truthy -> self
## self is Some(x) when x.method(...arguments) is falsy  -> None
## self is Some(x) when invalid call                     -> None
## self is None                                          -> None
## [/codeblock]
func keep_when_method_call(method_name: StringName, ...arguments: Array) -> Option:
	if _is_some and from_method_call.bindv(arguments).call(_value, method_name).unwrap_or(false):
		return self
	return None


## Drops [member self] when [code]Some(x)[/code] satisfies [param predicate], otherwise keeps it.
##
## [codeblock]
## self is Some(x) when predicate.call(x) is truthy -> None
## self is Some(x) when predicate.call(x) is falsy  -> self
## self is None                                     -> None
## [/codeblock]
func drop_when(predicate: Callable) -> Option:
	if _is_some:
		assert(predicate.is_valid())
		return None if predicate.call(_value) else self
	return None


## Drops [member self] when [code]x.member[/code] is truthy, otherwise keeps it.
##
## [codeblock]
## self is Some(x) when x.member is truthy -> None
## self is Some(x) when x.member is falsy  -> self
## self is Some(x) when invalid access     -> self
## self is None                            -> None
## [/codeblock]
func drop_when_member(member_name: StringName) -> Option:
	if _is_some and not from_member(_value, member_name).unwrap_or(false):
		return self
	return None


## Drops [member self] when [code]x.method(...arguments)[/code] is truthy, otherwise keeps it.
##
## [codeblock]
## self is Some(x) when x.method(...arguments) is truthy -> None
## self is Some(x) when x.method(...arguments) is falsy  -> self
## self is Some(x) when invalid call                     -> self
## self is None                                          -> None
## [/codeblock]
func drop_when_method_call(method_name: StringName, ...arguments: Array) -> Option:
	if _is_some and not from_method_call.bindv(arguments).call(_value, method_name).unwrap_or(false):
		return self
	return None


## Returns [param other] when [member self] is [code]Some[/code], otherwise [code]None[/code].
##
## [codeblock]
## self is Some(x) -> other
## self is None    -> None
## [/codeblock]
func and_then(other: Option) -> Option:
	if _is_some:
		return other
	return None


## Returns [code]callable.call(x)[/code] when [member self] is [code]Some(x)[/code], otherwise [code]None[/code].
##
## [codeblock]
## self is Some(x) -> callable.call(x)
## self is None    -> None
## [/codeblock]
func and_then_call(callable: Callable) -> Option:
	if _is_some:
		assert(callable.is_valid())
		var other: Option = callable.call(_value)
		return other
	return None


## Chains an [Option]-valued member access, flattening the result.
##
## [codeblock]
## self is Some(x) when x.member is Option(y)  -> Option(y)
## self is Some(x) when x.member is not Option -> Some(x.member) [with warning]
## self is Some(x) when invalid access         -> None
## self is None                                -> None
## [/codeblock]
func and_then_member(member_name: StringName) -> Option:
	if _is_some:
		return from_member(_value, member_name).flatten()
	return None


## Chains an [Option]-valued method call, flattening the result.
##
## [codeblock]
## self is Some(x) when x.method(...arguments) is Option(y)  -> Option(y)
## self is Some(x) when x.method(...arguments) is not Option -> Some(x.method(...arguments)) [with warning]
## self is Some(x) when invalid call                         -> None
## self is None                                              -> None
## [/codeblock]
func and_then_method_call(method_name: StringName, ...arguments: Array) -> Option:
	if _is_some:
		return from_method_call.bindv(arguments).call(_value, method_name).flatten()
	return None


## Returns [member self] when [code]Some[/code], otherwise [param other].
##
## [codeblock]
## self is Some(x) -> self
## self is None    -> other
## [/codeblock]
func or_else(other: Option) -> Option:
	if _is_some:
		return self
	return other


## Returns [member self] when [code]Some[/code], otherwise [code]callable.call()[/code].
##
## [codeblock]
## self is Some(x) -> self
## self is None    -> callable.call()
## [/codeblock]
func or_else_call(callable: Callable) -> Option:
	if _is_some:
		return self
	assert(callable.is_valid())
	var other: Option = callable.call()
	return other


## Returns whichever of [member self] or [param other] is [code]Some[/code] when exactly one is, otherwise
## [code]None[/code].
##
## [codeblock]
## self is Some(x), other is None    -> self
## self is None,    other is Some(y) -> other
## self is Some(x), other is Some(y) -> None
## self is None,    other is None    -> None
## [/codeblock]
func xor_with(other: Option) -> Option:
	if _is_some != other._is_some:
		return self if _is_some else other
	return None


## Transforms [member self] into a [Result], using [param err_value] for the [code]Err[/code] case.
##
## [codeblock]
## self is Some(x) -> Ok(x)
## self is None    -> Err(err_value)
## [/codeblock]
func ok_or(err_value: Variant) -> Result:
	if _is_some:
		return Result.Ok(_value)
	return Result.Err(err_value)


## Transforms [member self] into a [Result], using [code]callable.call()[/code] for the [code]Err[/code] case.
##
## [codeblock]
## self is Some(x) -> Ok(x)
## self is None    -> Err(callable.call())
## [/codeblock]
func ok_or_call(callable: Callable) -> Result:
	if _is_some:
		return Result.Ok(_value)
	assert(callable.is_valid())
	return Result.Err(callable.call())


## Transforms [member self] into a [Result], using [param result] when [member self] is [code]None[/code].
##
## [codeblock]
## self is Some(x) -> Ok(x)
## self is None    -> result
## [/codeblock]
func ok_or_else(result: Result) -> Result:
	if _is_some:
		return Result.Ok(_value)
	return result


## Transforms [member self] into a [Result], using [code]callable.call()[/code] when [member self] is [code]None[/code].
##
## [codeblock]
## self is Some(x) -> Ok(x)
## self is None    -> callable.call()
## [/codeblock]
func ok_or_else_call(callable: Callable) -> Result:
	if _is_some:
		return Result.Ok(_value)
	assert(callable.is_valid())
	var call_result: Result = callable.call()
	return call_result


## Flattens [code]Some(Option)[/code] into the inner [Option].
##
## [codeblock]
## self is Some(Option(x))     -> Option(x)
## self is Some(not_an_option) -> self [with warning]
## self is None                -> None
## [/codeblock]
func flatten() -> Option:
	if not _is_some:
		return None
	if _value is not Option:
		push_warning(WARN_ILLEGAL_FLATTEN)
		return self
	var inner: Option = _value
	return inner


## Transposes an [code]Option[Result][/code] into a [code]Result[Option][/code].
##
## [codeblock]
## self is None               -> Ok(None)
## self is Some(Ok(x))        -> Ok(Some(x))
## self is Some(Err(e))       -> Err(e)
## self is Some(not_a_result) -> Err(ERR_ILLEGAL_TRANSPOSE)
## [/codeblock]
func transpose() -> Result:
	if not _is_some:
		return Result.Ok(None)
	if _value is not Result:
		return Result.Err(ERR_ILLEGAL_TRANSPOSE)
	var inner: Result = _value
	if inner.is_err():
		return inner
	return Result.Ok(Some(inner._value))


func _iter_init(_iter: Array) -> bool:
	return _is_some


func _iter_next(_iter: Array) -> bool:
	return false


func _iter_get(_iter: Variant) -> Variant:
	return _value
