const ERR_NAMES: Dictionary[Error, StringName] = {
	FAILED = "Generic error",
	ERR_UNAVAILABLE = "Unavailable error",
	ERR_UNCONFIGURED = "Unconfigured error",
	ERR_UNAUTHORIZED = "Unauthorized error",
	ERR_PARAMETER_RANGE_ERROR = "Parameter range error",
	ERR_OUT_OF_MEMORY = "Out of memory (OOM) error",
	ERR_FILE_NOT_FOUND = "File: Not found error",
	ERR_FILE_BAD_DRIVE = "File: Bad drive error",
	ERR_FILE_BAD_PATH = "File: Bad path error",
	ERR_FILE_NO_PERMISSION = "File: No permission error",
	ERR_FILE_ALREADY_IN_USE = "File: Already in use error",
	ERR_FILE_CANT_OPEN = "File: Can't open error",
	ERR_FILE_CANT_WRITE = "File: Can't write error",
	ERR_FILE_CANT_READ = "File: Can't read error",
	ERR_FILE_UNRECOGNIZED = "File: Unrecognized error",
	ERR_FILE_CORRUPT = "File: Corrupt error",
	ERR_FILE_MISSING_DEPENDENCIES = "File: Missing dependencies error",
	ERR_FILE_EOF = "File: End of file (EOF) error",
	ERR_CANT_OPEN = "Can't open error",
	ERR_CANT_CREATE = "Can't create error",
	ERR_QUERY_FAILED = "Query failed error",
	ERR_ALREADY_IN_USE = "Already in use error",
	ERR_LOCKED = "Locked error",
	ERR_TIMEOUT = "Timeout error",
	ERR_CANT_CONNECT = "Can't connect error",
	ERR_CANT_RESOLVE = "Can't resolve error",
	ERR_CONNECTION_ERROR = "Connection error",
	ERR_CANT_ACQUIRE_RESOURCE = "Can't acquire resource error",
	ERR_CANT_FORK = "Can't fork process error",
	ERR_INVALID_DATA = "Invalid data error",
	ERR_INVALID_PARAMETER = "Invalid parameter error",
	ERR_ALREADY_EXISTS = "Already exists error",
	ERR_DOES_NOT_EXIST = "Does not exist error",
	ERR_DATABASE_CANT_READ = "Database: Read error",
	ERR_DATABASE_CANT_WRITE = "Database: Write error",
	ERR_COMPILATION_FAILED = "Compilation failed error",
	ERR_METHOD_NOT_FOUND = "Method not found error",
	ERR_LINK_FAILED = "Linking failed error",
	ERR_SCRIPT_FAILED = "Script failed error",
	ERR_CYCLIC_LINK = "Cycling link (import cycle) error",
	ERR_INVALID_DECLARATION = "Invalid declaration error",
	ERR_DUPLICATE_SYMBOL = "Duplicate symbol error",
	ERR_PARSE_ERROR = "Parse error",
	ERR_BUSY = "Busy error",
	ERR_SKIP = "Skip error",
	ERR_HELP = "Help error",
	ERR_BUG = "Bug error",
	ERR_PRINTER_ON_FIRE = "Printer on fire error",
}


static func format_compact(format_str: String, ...format_args: Array) -> String:
	return format_str.format(format_args.map(_compact_var_to_str))


static func equal_approx(value: Variant, other: Variant) -> bool:
	match typeof(value):
		var value_type when value_type != typeof(other):
			return false
		TYPE_FLOAT:
			return is_equal_approx(value, other)
		TYPE_OBJECT when value.has_method(&"is_equal_approx"):
			return value.is_equal_approx(other)
		# HINT: These types were sourced by searching for `is_equal_approx` using Godot Editor's "Search Help" modal.
		TYPE_AABB, TYPE_BASIS, TYPE_COLOR, TYPE_PLANE, TYPE_QUATERNION, TYPE_RECT2, \
		TYPE_TRANSFORM2D, TYPE_TRANSFORM3D, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4:
			return value.is_equal_approx(other)
		_:
			return value == other


static func _compact_var_to_str(value: Variant) -> String:
	return var_to_str(value).replace("\n", " ")
