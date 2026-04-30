static var _matching_consecutive_new_lines := RegEx.create_from_string("\n+", false)
static var _matching_format_token := RegEx.create_from_string("%s", false)


static func is_format_string(msg: String) -> bool:
	for match in _matching_format_token.search_all(msg):
		var start := match.get_start()
		if start == 0 or msg[start - 1] != "%":
			return true
	return false


static func format_compact(format_str: String, ...format_args: Array) -> String:
	return format_str.format(format_args.map(_compact_var_to_str))


static func equal_approx(value: Variant, other: Variant) -> bool:
	match typeof(value):
		var value_type when value_type != typeof(other):
			return false
		TYPE_NIL:
			return true
		TYPE_FLOAT:
			return is_equal_approx(value, other)
		# HINT: These types were sourced by searching for `is_equal_approx` using Godot Editor's "Search Help" modal.
		# gdlint:ignore = max-line-length
		TYPE_AABB, TYPE_BASIS, TYPE_COLOR, TYPE_PLANE, TYPE_QUATERNION, TYPE_RECT2, TYPE_TRANSFORM2D, TYPE_TRANSFORM3D, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4:
			return value.is_equal_approx(other)
		TYPE_OBJECT when (value as Object).has_method(&"is_equal_approx"):
			return value.is_equal_approx(other)
		TYPE_OBJECT when (other as Object).has_method(&"is_equal_approx"):
			return other.is_equal_approx(value)
		_:
			return value == other


static func _compact_var_to_str(value: Variant) -> String:
	return _matching_consecutive_new_lines.sub(var_to_str(value).strip_edges().dedent(), " ", true)
