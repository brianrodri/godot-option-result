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


static func Ok(x: Variant = null) -> Result:
	return new(true, x)


static func Err(e: Variant = null) -> Result:
	return new(false, e)


static func GdErr(code: Error) -> Result:
	if code == Error.OK:
		return Ok(Error.OK)
	return Err(error_string(code))


static func safe_call(callable: Callable, ...arguments: Array) -> Result:
	if not callable.is_valid():
		return Err(ERR_UNSAFE_CALLABLE)
	if arguments.size() != callable.get_argument_count():
		return Err(ERR_UNSAFE_ARGUMENTS)
	return Ok(callable.callv(arguments))


static func safe_member(instance: Variant, member_name: StringName) -> Result:
	if not is_instance_valid(instance) or member_name not in instance:
		return Err(ERR_UNSAFE_MEMBER_ACCESS)
	return Ok(instance.get(member_name))


static func safe_method_call(instance: Variant, method_name: StringName, ...arguments: Array) -> Result:
	var callable := Callable.create(instance, method_name)
	if not callable.is_valid():
		return Err(ERR_UNSAFE_METHOD_ACCESS)
	if arguments.size() != callable.get_argument_count():
		return Err(ERR_UNSAFE_ARGUMENTS)
	return Ok(callable.callv(arguments))


func _init(as_ok: bool, value: Variant) -> void:
	_is_ok = as_ok
	_value = value


func _to_string() -> String:
	var format_str := "Ok({0})" if _is_ok else "Err({0})"
	var value_str := var_to_str(_value) if _value is String or _value is StringName else str(_value)
	return format_str.format([value_str])


func is_ok() -> bool:
	return _is_ok


func is_err() -> bool:
	return not _is_ok


func is_ok_and(predicate: Callable) -> bool:
	if _is_ok:
		assert(predicate.is_valid())
		var passed: bool = predicate.call(_value)
		return passed
	return false


func is_err_and(predicate: Callable) -> bool:
	if _is_ok:
		return false
	assert(predicate.is_valid())
	var passed: bool = predicate.call(_value)
	return passed


func pipe(callable: Callable) -> Result:
	if _is_ok:
		assert(callable.is_valid())
		callable.call(_value)
	return self


func pipe_err(callable: Callable) -> Result:
	if not _is_ok:
		assert(callable.is_valid())
		callable.call(_value)
	return self


func unwrap() -> Variant:
	assert(_is_ok, ERR_ILLEGAL_UNWRAP)
	return _value


func unwrap_err() -> Variant:
	assert(not _is_ok, ERR_ILLEGAL_UNWRAP_ERR)
	return _value


func unwrap_or(other: Variant) -> Variant:
	if _is_ok:
		return _value
	return other


func unwrap_or_call(callable: Callable) -> Variant:
	if _is_ok:
		return _value
	assert(callable.is_valid())
	return callable.call(_value)


func map(callable: Callable) -> Result:
	if _is_ok:
		assert(callable.is_valid())
		return Ok(callable.call(_value))
	return self


func map_member(member_name: StringName) -> Result:
	if _is_ok:
		return safe_member(_value, member_name)
	return self


func map_method_call(method_name: StringName, ...arguments: Array) -> Result:
	if _is_ok:
		return safe_method_call.bindv(arguments).call(_value, method_name)
	return self


func map_err(callable: Callable) -> Result:
	if _is_ok:
		return self
	assert(callable.is_valid())
	return Err(callable.call(_value))


func map_err_member(member_name: StringName) -> Result:
	if _is_ok:
		return self
	return safe_member(_value, member_name)


func map_err_method_call(method_name: StringName, ...arguments: Array) -> Result:
	if _is_ok:
		return self
	return safe_method_call.bindv(arguments).call(_value, method_name)


func map_or(default: Variant, callable: Callable) -> Variant:
	if _is_ok:
		assert(callable.is_valid())
		return callable.call(_value)
	return default


func map_member_or(default: Variant, member_name: StringName) -> Variant:
	if _is_ok:
		return safe_member(_value, member_name).unwrap_or(default)
	return default


func map_method_call_or(default: Variant, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_ok:
		return safe_method_call.bindv(arguments).call(_value, method_name).unwrap_or(default)
	return default


func map_or_call(default_provider: Callable, callable: Callable) -> Variant:
	if _is_ok:
		assert(callable.is_valid())
		return callable.call(_value)
	assert(default_provider.is_valid())
	return default_provider.call(_value)


func map_member_or_call(default_provider: Callable, member_name: StringName) -> Variant:
	if _is_ok:
		return safe_member(_value, member_name).unwrap_or_call(default_provider)
	assert(default_provider.is_valid())
	return default_provider.call(_value)


func map_method_call_or_call(default_provider: Callable, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_ok:
		return safe_method_call.bindv(arguments).call(_value, method_name).unwrap_or_call(default_provider)
	assert(default_provider.is_valid())
	return default_provider.call(_value)


func and_then(other: Result) -> Result:
	if _is_ok:
		return other
	return self


func and_then_call(callable: Callable) -> Result:
	if _is_ok:
		assert(callable.is_valid())
		var other: Result = callable.call(_value)
		return other
	return self


func and_then_member(member_name: StringName) -> Result:
	if _is_ok:
		var other: Result = safe_member(_value, member_name)
		return other.flatten()
	return self


func and_then_method_call(method_name: StringName, ...arguments: Array) -> Result:
	if _is_ok:
		var other: Result = safe_method_call.bindv(arguments).call(_value, method_name)
		return other.flatten()
	return self


func or_else(other: Result) -> Result:
	if _is_ok:
		return self
	return other


func or_else_call(callable: Callable) -> Result:
	if _is_ok:
		return self
	assert(callable.is_valid())
	var other: Result = callable.call(_value)
	return other


func or_else_member(member_name: StringName) -> Result:
	if _is_ok:
		return self
	var other: Result = safe_member(_value, member_name)
	return other


func or_else_method_call(method_name: StringName, ...arguments: Array) -> Result:
	if _is_ok:
		return self
	var other: Result = safe_method_call.bindv(arguments).call(_value, method_name)
	return other


func ok() -> Option:
	if _is_ok:
		return Option.Some(_value)
	return Option.None


func err() -> Option:
	if _is_ok:
		return Option.None
	return Option.Some(_value)


func flatten() -> Result:
	if not _is_ok:
		return self
	if _value is not Result:
		push_warning(WARN_ILLEGAL_FLATTEN)
		return self
	var inner: Result = _value
	return inner


## Transposes a [code]Result[Option][/code] into an [code]Option[Result][/code].
##
## [codeblock]
## self is Result.Ok(Option.None)    -> Option.None
## self is Result.Ok(Option.Some(x)) -> Option.Some(Result.Ok(x))
## self is Result.Ok(not_an_option)  -> Option.Some(Result.Err(Result.ERR_ILLEGAL_TRANSPOSE))
## self is Result.Err(e)             -> Option.Some(Result.Err(e))
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
