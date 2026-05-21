class_name Option
extends RefCounted

const ERR_ILLEGAL_UNWRAP := "[method Option.unwrap] called on [code]None[/code]"
const ERR_ILLEGAL_TRANSPOSE := (
		"[method Option.transpose] when [member self] is [code]Some(x)[/code] requires [code]x[/code] to be [Result]"
)
const WARN_ILLEGAL_FLATTEN := (
		"[method Option.flatten] when [member self] is [code]Some(x)[/code] requires [code]x[/code] to be [Option]"
)

static var None := new()

var _is_some: bool
var _value: Variant


static func Some(x: Variant) -> Option:
	return new(true, x)


static func not_null(x: Variant) -> Option:
	return None if x == null else Some(x)


static func from_member(instance: Variant, member_name: StringName) -> Option:
	return Result.safe_member(instance, member_name).ok()


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


func is_some() -> bool:
	return _is_some


func is_none() -> bool:
	return not _is_some


func is_some_and(predicate: Callable) -> bool:
	if _is_some:
		assert(predicate.is_valid())
		return bool(predicate.call(_value))
	return false


func is_none_or(predicate: Callable) -> bool:
	if _is_some:
		assert(predicate.is_valid())
		return bool(predicate.call(_value))
	return true


func pipe(callable: Callable) -> Option:
	if _is_some:
		assert(callable.is_valid())
		callable.call(_value)
	return self


func unwrap() -> Variant:
	assert(_is_some, ERR_ILLEGAL_UNWRAP)
	return _value


func unwrap_or(other: Variant) -> Variant:
	if _is_some:
		return _value
	return other


func unwrap_or_call(callable: Callable) -> Variant:
	if _is_some:
		return _value
	assert(callable.is_valid())
	return callable.call()


func map(callable: Callable) -> Option:
	if _is_some:
		assert(callable.is_valid())
		return Some(callable.call(_value))
	return None


func map_member(member_name: StringName) -> Option:
	if _is_some:
		return from_member(_value, member_name)
	return None


func map_method_call(method_name: StringName, ...arguments: Array) -> Option:
	if _is_some:
		return from_method_call.bindv(arguments).call(_value, method_name)
	return None


func map_or(default: Variant, callable: Callable) -> Variant:
	if _is_some:
		assert(callable.is_valid())
		return callable.call(_value)
	return default


func map_member_or(default: Variant, member_name: StringName) -> Variant:
	if _is_some:
		return from_member(_value, member_name).unwrap_or(default)
	return default


func map_method_call_or(default: Variant, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_some:
		return from_method_call.bindv(arguments).call(_value, method_name).unwrap_or(default)
	return default


func map_or_call(default_provider: Callable, callable: Callable) -> Variant:
	if _is_some:
		assert(callable.is_valid())
		return callable.call(_value)
	assert(default_provider.is_valid())
	return default_provider.call()


func map_member_or_call(default_provider: Callable, member_name: StringName) -> Variant:
	if _is_some:
		return from_member(_value, member_name).unwrap_or_call(default_provider)
	assert(default_provider.is_valid())
	return default_provider.call()


func map_method_call_or_call(default_provider: Callable, method_name: StringName, ...arguments: Array) -> Variant:
	if _is_some:
		return from_method_call.bindv(arguments).call(_value, method_name).unwrap_or_call(default_provider)
	assert(default_provider.is_valid())
	return default_provider.call()


func keep_when(predicate: Callable) -> Option:
	if _is_some:
		assert(predicate.is_valid())
		return self if predicate.call(_value) else None
	return None


func keep_when_member(member_name: StringName) -> Option:
	if _is_some and from_member(_value, member_name).unwrap_or(false):
		return self
	return None


func keep_when_method_call(method_name: StringName, ...arguments: Array) -> Option:
	if _is_some and from_method_call.bindv(arguments).call(_value, method_name).unwrap_or(false):
		return self
	return None


func drop_when(predicate: Callable) -> Option:
	if _is_some:
		assert(predicate.is_valid())
		return None if predicate.call(_value) else self
	return None


func drop_when_member(member_name: StringName) -> Option:
	if _is_some and not from_member(_value, member_name).unwrap_or(false):
		return self
	return None


func drop_when_method_call(method_name: StringName, ...arguments: Array) -> Option:
	if _is_some and not from_method_call.bindv(arguments).call(_value, method_name).unwrap_or(false):
		return self
	return None


func and_then(other: Option) -> Option:
	if _is_some:
		return other
	return None


func and_then_call(callable: Callable) -> Option:
	if _is_some:
		assert(callable.is_valid())
		var other: Option = callable.call(_value)
		return other
	return None


func and_then_member(member_name: StringName) -> Option:
	if _is_some:
		return from_member(_value, member_name).flatten()
	return None


func and_then_method_call(method_name: StringName, ...arguments: Array) -> Option:
	if _is_some:
		return from_method_call.bindv(arguments).call(_value, method_name).flatten()
	return None


func or_else(other: Option) -> Option:
	if _is_some:
		return self
	return other


func or_else_call(callable: Callable) -> Option:
	if _is_some:
		return self
	assert(callable.is_valid())
	var other: Option = callable.call()
	return other


func xor_with(other: Option) -> Option:
	if _is_some != other._is_some:
		return self if _is_some else other
	return None


func ok_or(err_value: Variant) -> Result:
	if _is_some:
		return Result.Ok(_value)
	return Result.Err(err_value)


func ok_or_call(callable: Callable) -> Result:
	if _is_some:
		return Result.Ok(_value)
	assert(callable.is_valid())
	return Result.Err(callable.call())


func ok_or_else(result: Result) -> Result:
	if _is_some:
		return Result.Ok(_value)
	return result


func ok_or_else_call(callable: Callable) -> Result:
	if _is_some:
		return Result.Ok(_value)
	assert(callable.is_valid())
	var call_result: Result = callable.call()
	return call_result


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
## self is Option.None                -> Result.Ok(Option.None)
## self is Option.Some(Result.Ok(x))  -> Result.Ok(Option.Some(x))
## self is Option.Some(Result.Err(e)) -> Result.Err(e)
## self is Option.Some(not_a_result)  -> Result.Err(Option.ERR_ILLEGAL_TRANSPOSE)
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
