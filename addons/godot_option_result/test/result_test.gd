class_name ResultTest
extends GdUnitTestSuite


func test_to_string_with_simple_types(
		input: Result,
		expected: String,
		_test_parameters := [
			# Oks
			[Result.Ok(null), "Ok(<null>)"],
			[Result.Ok(42), "Ok(42)"],
			[Result.Ok("42"), 'Ok("42")'],
			[Result.Ok(&"42"), 'Ok(&"42")'],
			[Result.Ok([1, 2, 3]), "Ok([1, 2, 3])"],
			[Result.Ok(["1", "2", "3"]), 'Ok(["1", "2", "3"])'],
			[Result.Ok({ a = 1 }), 'Ok({ &"a": 1 })'],
			[Result.Ok({ a = "1" }), 'Ok({ &"a": "1" })'],
			# GdErr(OK)
			[Result.GdErr(OK), "Ok(0)"],
			# Errs
			[Result.Err(null), "Err(<null>)"],
			[Result.Err(42), "Err(42)"],
			[Result.Err("42"), 'Err("42")'],
			[Result.Err([1, 2, 3]), "Err([1, 2, 3])"],
			[Result.Err(["1", "2", "3"]), 'Err(["1", "2", "3"])'],
			[Result.Err({ a = 1 }), 'Err({ &"a": 1 })'],
			[Result.Err({ a = "1" }), 'Err({ &"a": "1" })'],
		],
):
	assert_str(str(input)).is_equal(expected)


func test_to_string_with_builtin_gd_errors(
		e: Error,
		_test_parameters := [
			[FAILED],
			[ERR_UNAVAILABLE],
			[ERR_UNCONFIGURED],
			[ERR_UNAUTHORIZED],
			[ERR_PARAMETER_RANGE_ERROR],
			[ERR_OUT_OF_MEMORY],
			[ERR_FILE_NOT_FOUND],
			[ERR_FILE_BAD_DRIVE],
			[ERR_FILE_BAD_PATH],
			[ERR_FILE_NO_PERMISSION],
			[ERR_FILE_ALREADY_IN_USE],
			[ERR_FILE_CANT_OPEN],
			[ERR_FILE_CANT_WRITE],
			[ERR_FILE_CANT_READ],
			[ERR_FILE_UNRECOGNIZED],
			[ERR_FILE_CORRUPT],
			[ERR_FILE_MISSING_DEPENDENCIES],
			[ERR_FILE_EOF],
			[ERR_CANT_OPEN],
			[ERR_CANT_CREATE],
			[ERR_QUERY_FAILED],
			[ERR_ALREADY_IN_USE],
			[ERR_LOCKED],
			[ERR_TIMEOUT],
			[ERR_CANT_CONNECT],
			[ERR_CANT_RESOLVE],
			[ERR_CONNECTION_ERROR],
			[ERR_CANT_ACQUIRE_RESOURCE],
			[ERR_CANT_FORK],
			[ERR_INVALID_DATA],
			[ERR_INVALID_PARAMETER],
			[ERR_ALREADY_EXISTS],
			[ERR_DOES_NOT_EXIST],
			[ERR_DATABASE_CANT_READ],
			[ERR_DATABASE_CANT_WRITE],
			[ERR_COMPILATION_FAILED],
			[ERR_METHOD_NOT_FOUND],
			[ERR_LINK_FAILED],
			[ERR_SCRIPT_FAILED],
			[ERR_CYCLIC_LINK],
			[ERR_INVALID_DECLARATION],
			[ERR_DUPLICATE_SYMBOL],
			[ERR_PARSE_ERROR],
			[ERR_BUSY],
			[ERR_SKIP],
			[ERR_HELP],
			[ERR_BUG],
			[ERR_PRINTER_ON_FIRE],
		],
):
	var result := Result.GdErr(e)
	var expected_reason := error_string(e)
	assert_str(str(result)).is_equal('Err("{0}")'.format([expected_reason]))


func test_safe_call(
		f: Callable,
		args: Array,
		expectation: Result,
		_test_parameters := [
			[auto_free(Node.new()).is_node_ready, [], Result.Ok(false)],
			[Callable.create(auto_free(Node.new()), &"is_food_ready"), [], Result.Err(Result.ERR_UNSAFE_CALLABLE)],
			[auto_free(Node.new()).can_process, [1, 2, 3], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[Callable.create(null, &"is_node_ready"), [], Result.Err(Result.ERR_UNSAFE_CALLABLE)],
			[Vector3.ONE.is_equal_approx, [Vector3.ONE], Result.Ok(true)],
			[auto_free(CustomClass.new(42)).mul_by, [2], Result.Ok(84)],
			[auto_free(CustomClass.new(42)).mul_by, [], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[auto_free(CustomClass.new(42)).mul_by, [2, 3], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[Callable.create(auto_free(CustomClass.new(42)), &"mul_by_two"), [2], Result.Err(Result.ERR_UNSAFE_CALLABLE)],
		],
):
	assert_that(Result.safe_call.bindv(args).call(f)).is_equal(expectation)


func test_safe_member(
		instance: Variant,
		member_name: StringName,
		expectation: Result,
		_test_parameters := [
			[auto_free(Node.new()), &"process_mode", Result.Ok(PROCESS_MODE_INHERIT)],
			[auto_free(Node.new()), &"process_lols", Result.Err(Result.ERR_UNSAFE_MEMBER_ACCESS)],
			[null, &"process_mode", Result.Err(Result.ERR_UNSAFE_MEMBER_ACCESS)],
			[Vector3.ONE, &"x", Result.Err(Result.ERR_UNSAFE_MEMBER_ACCESS)],
			[auto_free(CustomClass.new(42)), &"prop", Result.Ok(42)],
			[auto_free(CustomClass.new(42)), &"unknown_prop", Result.Err(Result.ERR_UNSAFE_MEMBER_ACCESS)],
		],
):
	assert_that(Result.safe_member(instance, member_name)).is_equal(expectation)


func test_safe_method_call(
		instance: Variant,
		method_name: StringName,
		arguments: Array,
		expectation: Result,
		_test_parameters := [
			[auto_free(Node.new()), &"is_node_ready", [], Result.Ok(false)],
			[auto_free(Node.new()), &"is_food_ready", [], Result.Err(Result.ERR_UNSAFE_METHOD_ACCESS)],
			[auto_free(Node.new()), &"can_process", [1, 2, 3], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[null, &"is_node_ready", [], Result.Err(Result.ERR_UNSAFE_METHOD_ACCESS)],
			[Vector3.ONE, &"is_equal_approx", [Vector3.ONE], Result.Ok(true)],
			[auto_free(CustomClass.new(42)), &"mul_by", [2], Result.Ok(84)],
			[auto_free(CustomClass.new(42)), &"mul_by", [], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[auto_free(CustomClass.new(42)), &"mul_by", [2, 3], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[auto_free(CustomClass.new(42)), &"mul_by_two", [2], Result.Err(Result.ERR_UNSAFE_METHOD_ACCESS)],
		],
):
	assert_that(Result.safe_method_call.bindv(arguments).call(instance, method_name)).is_equal(expectation)


func test_is_ok(
		result: Result,
		expected: bool,
		_test_parameters := [
			[Result.Ok(-3), true],
			[Result.Err("Some error message"), false],
		],
):
	assert_bool(result.is_ok()).is_equal(expected)


func test_is_err(
		result: Result,
		expected: bool,
		_test_parameters := [
			[Result.Ok(-3), false],
			[Result.Err("Some error message"), true],
		],
):
	assert_bool(result.is_err()).is_equal(expected)


func test_is_ok_and(
		result: Result,
		expected: bool,
		_test_parameters := [
			[Result.Ok(2), true],
			[Result.Ok(0), false],
			[Result.Err(123), false],
			[Result.Err("hey"), false],
		],
):
	assert_bool(result.is_ok_and(func(x): return x > 1)).is_equal(expected)


func test_is_err_and(
		result: Result,
		expected: bool,
		_test_parameters := [
			[Result.Err(2), true],
			[Result.Err(0), false],
			[Result.Ok(123), false],
		],
):
	assert_bool(result.is_err_and(func(x): return x > 1)).is_equal(expected)


func test_is_ok_and_member(
		result: Result,
		member_name: StringName,
		expected: bool,
		_test_parameters := [
			[Result.Ok(auto_free(CustomClass.new(42))), &"prop", true],
			[Result.Ok(auto_free(CustomClass.new(0))), &"prop", false],
			[Result.Ok(auto_free(CustomClass.new(42))), &"unknown_prop", false],
			[Result.Err(auto_free(CustomClass.new(42))), &"prop", false],
		],
):
	assert_bool(result.is_ok_and_member(member_name)).is_equal(expected)


func test_is_ok_and_method_call(
		result: Result,
		method_name: StringName,
		arguments: Array,
		expected: bool,
		_test_parameters := [
			[Result.Ok(auto_free(CustomClass.new(42))), &"mul_by", [2], true],
			[Result.Ok(auto_free(CustomClass.new(42))), &"mul_by", [0], false],
			[Result.Ok(auto_free(CustomClass.new(42))), &"mul_by", [], false],
			[Result.Ok(auto_free(CustomClass.new(42))), &"unknown_method", [], false],
			[Result.Err(auto_free(CustomClass.new(42))), &"mul_by", [2], false],
		],
):
	assert_bool(result.is_ok_and_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_is_err_and_member(
		result: Result,
		member_name: StringName,
		expected: bool,
		_test_parameters := [
			[Result.Err(auto_free(CustomClass.new(42))), &"prop", true],
			[Result.Err(auto_free(CustomClass.new(0))), &"prop", false],
			[Result.Err(auto_free(CustomClass.new(42))), &"unknown_prop", false],
			[Result.Ok(auto_free(CustomClass.new(42))), &"prop", false],
		],
):
	assert_bool(result.is_err_and_member(member_name)).is_equal(expected)


func test_is_err_and_method_call(
		result: Result,
		method_name: StringName,
		arguments: Array,
		expected: bool,
		_test_parameters := [
			[Result.Err(auto_free(CustomClass.new(42))), &"mul_by", [2], true],
			[Result.Err(auto_free(CustomClass.new(42))), &"mul_by", [0], false],
			[Result.Err(auto_free(CustomClass.new(42))), &"mul_by", [], false],
			[Result.Err(auto_free(CustomClass.new(42))), &"unknown_method", [], false],
			[Result.Ok(auto_free(CustomClass.new(42))), &"mul_by", [2], false],
		],
):
	assert_bool(result.is_err_and_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_pipe(
		input: Result,
		times_called: int,
		_test_parameters := [
			[Result.Ok(2), 1],
			[Result.Err("e"), 0],
		],
):
	var cb := mock(Callbacks) as Callbacks
	var returned = input.pipe(cb.transform)
	assert_that(returned).is_equal(input)
	verify(cb, times_called).transform(input._value if times_called > 0 else any())


func test_pipe_err(
		input: Result,
		times_called: int,
		_test_parameters := [
			[Result.Ok(2), 0],
			[Result.Err("e"), 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	var returned = input.pipe_err(cb.transform)
	assert_that(returned).is_equal(input)
	verify(cb, times_called).transform(input._value if times_called > 0 else any())


func test_unwrap_returns_value_when_ok():
	assert_int(Result.Ok(2).unwrap()).is_equal(2)


func test_unwrap_fails_with_default_message_when_err() -> void:
	await (
			assert_error(func(): Result.Err(42).unwrap())
			.is_runtime_error("Assertion failed: " + Result.ERR_ILLEGAL_UNWRAP)
	)


func test_unwrap_err_returns_error_when_err():
	assert_str(Result.Err("emergency failure").unwrap_err()).is_equal("emergency failure")


func test_unwrap_err_fails_with_default_message_when_ok() -> void:
	await (
			assert_error(func(): Result.Ok(42).unwrap_err())
			.is_runtime_error("Assertion failed: " + Result.ERR_ILLEGAL_UNWRAP_ERR)
	)


func test_unwrap_or(
		input: Result,
		default: Variant,
		expected: Variant,
		_test_parameters := [
			[Result.Ok(9), 0, 9],
			[Result.Err("error"), 0, 0],
		],
):
	assert_that(input.unwrap_or(default)).is_equal(expected)


func test_unwrap_or_call(
		input: Result,
		expected: Variant,
		times_called: int,
		_test_parameters := [
			[Result.Ok(2), 2, 0],
			[Result.Err("foo"), 3, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(expected).on(cb).transform(any())
	assert_that(input.unwrap_or_call(cb.transform)).is_equal(expected)
	verify(cb, times_called).transform(input._value if times_called > 0 else any())


func test_map(
		input: Result,
		expected: Result,
		_test_parameters := [
			[Result.Ok(2), Result.Ok(4)],
			[Result.Err(13), Result.Err(13)],
		],
):
	assert_that(input.map(func(x): return x * 2)).is_equal(expected)


func test_map_err(
		input: Result,
		expected: Result,
		_test_parameters := [
			[Result.Ok(2), Result.Ok(2)],
			[Result.Err("foo"), Result.Err(3)],
		],
):
	assert_that(input.map_err(len)).is_equal(expected)


func test_map_err_member(
		input: Result,
		member_name: StringName,
		expected: Result,
		_test_parameters := [
			[Result.Ok(42), &"prop", Result.Ok(42)],
			[Result.Err(auto_free(CustomClass.new(7))), &"prop", Result.Err(7)],
			[Result.Err(auto_free(CustomClass.new(7))), &"unknown_prop", Result.Err(Result.ERR_UNSAFE_MEMBER_ACCESS)],
		],
):
	assert_that(input.map_err_member(member_name)).is_equal(expected)


func test_map_err_method_call(
		input: Result,
		method_name: StringName,
		arguments: Array,
		expected: Result,
		_test_parameters := [
			[Result.Ok(42), &"mul_by", [2], Result.Ok(42)],
			[Result.Err(auto_free(CustomClass.new(7))), &"mul_by", [2], Result.Err(14)],
			[Result.Err(auto_free(CustomClass.new(7))), &"mul_by", [], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[Result.Err(auto_free(CustomClass.new(7))), &"unknown_method", [], Result.Err(Result.ERR_UNSAFE_METHOD_ACCESS)],
		],
):
	assert_that(input.map_err_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_map_or(
		input: Result,
		default: Variant,
		expected: Variant,
		_test_parameters := [
			[Result.Ok("foo"), 42, 3],
			[Result.Err("bar"), 42, 42],
		],
):
	assert_that(input.map_or(default, len)).is_equal(expected)


func test_map_or_call(
		input: Result,
		expected: Variant,
		times_called: int,
		_test_parameters := [
			[Result.Ok("foo"), 3, 0],
			[Result.Err(21), 42, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(expected).on(cb).transform(any())
	assert_that(input.map_or_call(cb.transform, len)).is_equal(expected)
	verify(cb, times_called).transform(input._value if times_called > 0 else any())


func test_and_then(
		self_result: Result,
		other: Result,
		expected: Result,
		_test_parameters := [
			[Result.Ok(2), Result.Err("late error"), Result.Err("late error")],
			[Result.Err("early error"), Result.Ok("foo"), Result.Err("early error")],
			[Result.Err("not a 2"), Result.Err("late error"), Result.Err("not a 2")],
			[Result.Ok(2), Result.Ok("different result type"), Result.Ok("different result type")],
		],
):
	assert_that(self_result.and_then(other)).is_equal(expected)


func test_and_then_call(
		input: Result,
		expected: Result,
		times_called: int,
		_test_parameters := [
			[Result.Ok(2), Result.Ok(4), 1],
			[Result.Ok(1_000_000), Result.Err("overflowed"), 1],
			[Result.Err("not a number"), Result.Err("not a number"), 0],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(expected).on(cb).transform(any())
	assert_that(input.and_then_call(cb.transform)).is_equal(expected)
	verify(cb, times_called).transform(input._value if times_called > 0 else any())


func test_or_else(
		self_result: Result,
		other: Result,
		expected: Result,
		_test_parameters := [
			[Result.Ok(2), Result.Err("late error"), Result.Ok(2)],
			[Result.Err("early error"), Result.Ok(2), Result.Ok(2)],
			[Result.Err("not a 2"), Result.Err("late error"), Result.Err("late error")],
			[Result.Ok(2), Result.Ok(100), Result.Ok(2)],
		],
):
	assert_that(self_result.or_else(other)).is_equal(expected)


func test_or_else_call(
		input: Result,
		default: Result,
		expected: Result,
		times_called: int,
		_test_parameters := [
			[Result.Ok(2), Result.Ok(4), Result.Ok(2), 0],
			[Result.Err(3), Result.Ok(9), Result.Ok(9), 1],
			[Result.Err(3), Result.Err(3), Result.Err(3), 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).transform(any())
	assert_that(input.or_else_call(cb.transform)).is_equal(expected)
	verify(cb, times_called).transform(input._value if times_called > 0 else any())


func test_ok(
		input: Result,
		expected: Option,
		_test_parameters := [
			[Result.Ok(2), Option.Some(2)],
			[Result.Err("Nothing here"), Option.None],
		],
):
	assert_that(input.ok()).is_equal(expected)


func test_err(
		input: Result,
		expected: Option,
		_test_parameters := [
			[Result.Ok(2), Option.None],
			[Result.Err("Nothing here"), Option.Some("Nothing here")],
		],
):
	assert_that(input.err()).is_equal(expected)


func test_flatten(
		input: Result,
		expected: Result,
		_test_parameters := [
			[Result.Ok(Result.Ok(Result.Ok(5))), Result.Ok(Result.Ok(5))],
			[Result.Ok(Result.Ok("hello")), Result.Ok("hello")],
			[Result.Ok(Result.Err(6)), Result.Err(6)],
			[Result.Err(6), Result.Err(6)],
			[Result.Err(Result.Ok("uh-oh")), Result.Err(Result.Ok("uh-oh"))],
		],
):
	assert_that(input.flatten()).is_equal(expected)


func test_transpose(
		input: Result,
		expected: Option,
		_test_parameters := [
			[Result.Ok(Option.None), Option.None],
			[Result.Ok(Option.Some(5)), Option.Some(Result.Ok(5))],
			[Result.Err("SomeErr"), Option.Some(Result.Err("SomeErr"))],
		],
):
	assert_that(input).is_equal(expected.transpose())
	assert_that(input.transpose()).is_equal(expected)
	assert_that(input.transpose().transpose()).is_equal(input)


func test_transpose_with_non_option_value():
	var ok_value_but_not_option := Result.Ok(42)
	var some_invalid_data_error := Option.Some(Result.Err(Result.ERR_ILLEGAL_TRANSPOSE))
	assert_that(ok_value_but_not_option.transpose()).is_equal(some_invalid_data_error)


func test_map_member(
		input: Result,
		member_name: StringName,
		expected: Result,
		_test_parameters := [
			[Result.Err("e"), &"prop", Result.Err("e")],
			[Result.Ok(auto_free(CustomClass.new(42))), &"prop", Result.Ok(42)],
			[Result.Ok(auto_free(CustomClass.new(42))), &"unknown_prop", Result.Err(Result.ERR_UNSAFE_MEMBER_ACCESS)],
		],
):
	assert_that(input.map_member(member_name)).is_equal(expected)


func test_map_method_call(
		input: Result,
		method_name: StringName,
		arguments: Array,
		expected: Result,
		_test_parameters := [
			[Result.Err("e"), &"mul_by", [2], Result.Err("e")],
			[Result.Ok(auto_free(CustomClass.new(42))), &"mul_by", [2], Result.Ok(84)],
			[Result.Ok(auto_free(CustomClass.new(42))), &"mul_by", [], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[Result.Ok(auto_free(CustomClass.new(42))), &"unknown_method", [], Result.Err(Result.ERR_UNSAFE_METHOD_ACCESS)],
		],
):
	assert_that(input.map_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_map_member_or(
		input: Result,
		default: Variant,
		member_name: StringName,
		expected: Variant,
		_test_parameters := [
			[Result.Err("e"), "default", &"prop", "default"],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"prop", 42],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"unknown_prop", -1],
		],
):
	assert_that(input.map_member_or(default, member_name)).is_equal(expected)


func test_map_method_call_or(
		input: Result,
		default: Variant,
		method_name: StringName,
		arguments: Array,
		expected: Variant,
		_test_parameters := [
			[Result.Err("e"), -1, &"mul_by", [2], -1],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"mul_by", [2], 84],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"mul_by", [], -1],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"unknown_method", [], -1],
		],
):
	assert_that(input.map_method_call_or.bindv(arguments).call(default, method_name)).is_equal(expected)


func test_map_member_or_call(
		input: Result,
		default: Variant,
		member_name: StringName,
		expected: Variant,
		times_called: int,
		_test_parameters := [
			[Result.Err("e"), -1, &"prop", -1, 1],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"prop", 42, 0],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"unknown_prop", -1, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).transform(any())
	assert_that(input.map_member_or_call(cb.transform, member_name)).is_equal(expected)
	verify(cb, times_called).transform(input._value if times_called > 0 else any())


func test_map_method_call_or_call(
		input: Result,
		default: Variant,
		method_name: StringName,
		arguments: Array,
		expected: Variant,
		times_called: int,
		_test_parameters := [
			[Result.Err("e"), -1, &"mul_by", [2], -1, 1],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"mul_by", [2], 84, 0],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"mul_by", [], -1, 1],
			[Result.Ok(auto_free(CustomClass.new(42))), -1, &"unknown_method", [], -1, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).transform(any())
	assert_that(input.map_method_call_or_call.bindv(arguments).call(cb.transform, method_name)).is_equal(expected)
	verify(cb, times_called).transform(input._value if times_called > 0 else any())


func test_map_member_or_call_passes_only_x_when_access_fails():
	var instance := auto_free(CustomClass.new(42))
	var captured: Array = []
	var default_provider := func(arg, extra = "<not_passed>"):
		captured.append([arg, extra])
		return -1

	var output: Variant = Result.Ok(instance).map_member_or_call(default_provider, &"unknown_prop")

	assert_that(output).is_equal(-1)
	assert_that(captured.size()).is_equal(1)
	assert_that(captured[0][0]).is_equal(instance)
	assert_that(captured[0][1]).is_equal("<not_passed>")


func test_map_method_call_or_call_passes_only_x_when_call_fails():
	var instance := auto_free(CustomClass.new(42))
	var captured: Array = []
	var default_provider := func(arg, extra = "<not_passed>"):
		captured.append([arg, extra])
		return -1

	var output: Variant = Result.Ok(instance).map_method_call_or_call(default_provider, &"unknown_method")

	assert_that(output).is_equal(-1)
	assert_that(captured.size()).is_equal(1)
	assert_that(captured[0][0]).is_equal(instance)
	assert_that(captured[0][1]).is_equal("<not_passed>")


func test_map_err_member_or_call_passes_only_e_when_access_fails():
	var instance := auto_free(CustomClass.new(42))
	var captured: Array = []
	var default_provider := func(arg, extra = "<not_passed>"):
		captured.append([arg, extra])
		return -1

	var output: Variant = Result.Err(instance).map_err_member_or_call(default_provider, &"unknown_prop")

	assert_that(output).is_equal(-1)
	assert_that(captured.size()).is_equal(1)
	assert_that(captured[0][0]).is_equal(instance)
	assert_that(captured[0][1]).is_equal("<not_passed>")


func test_map_err_method_call_or_call_passes_only_e_when_call_fails():
	var instance := auto_free(CustomClass.new(42))
	var captured: Array = []
	var default_provider := func(arg, extra = "<not_passed>"):
		captured.append([arg, extra])
		return -1

	var output: Variant = Result.Err(instance).map_err_method_call_or_call(default_provider, &"unknown_method")

	assert_that(output).is_equal(-1)
	assert_that(captured.size()).is_equal(1)
	assert_that(captured[0][0]).is_equal(instance)
	assert_that(captured[0][1]).is_equal("<not_passed>")


func test_and_then_member(
		input: Result,
		member_name: StringName,
		expected: Result,
		_test_parameters := [
			[Result.Err("e"), &"inner_result", Result.Err("e")],
			[Result.Ok(auto_free(CustomClass.new(0, Result.Ok(42)))), &"inner_result", Result.Ok(42)],
			[Result.Ok(auto_free(CustomClass.new(0, Result.Err("inner")))), &"inner_result", Result.Err("inner")],
			[Result.Ok(auto_free(CustomClass.new(0))), &"unknown_prop", Result.Err(Result.ERR_UNSAFE_MEMBER_ACCESS)],
		],
):
	assert_that(input.and_then_member(member_name)).is_equal(expected)


func test_and_then_method_call(
		input: Result,
		method_name: StringName,
		arguments: Array,
		expected: Result,
		_test_parameters := [
			[Result.Err("e"), &"get_result", [Result.Ok(42)], Result.Err("e")],
			[Result.Ok(auto_free(CustomClass.new(0))), &"get_result", [Result.Ok(42)], Result.Ok(42)],
			[Result.Ok(auto_free(CustomClass.new(0))), &"get_result", [Result.Err("inner")], Result.Err("inner")],
			[Result.Ok(auto_free(CustomClass.new(0))), &"unknown_method", [], Result.Err(Result.ERR_UNSAFE_METHOD_ACCESS)],
		],
):
	assert_that(input.and_then_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_or_else_member(
		input: Result,
		member_name: StringName,
		expected: Result,
		_test_parameters := [
			[Result.Ok(42), &"prop", Result.Ok(42)],
			[Result.Err(auto_free(CustomClass.new(7))), &"prop", Result.Ok(7)],
			[Result.Err(auto_free(CustomClass.new(7))), &"unknown_prop", Result.Err(Result.ERR_UNSAFE_MEMBER_ACCESS)],
		],
):
	assert_that(input.or_else_member(member_name)).is_equal(expected)


func test_or_else_method_call(
		input: Result,
		method_name: StringName,
		arguments: Array,
		expected: Result,
		_test_parameters := [
			[Result.Ok(42), &"mul_by", [2], Result.Ok(42)],
			[Result.Err(auto_free(CustomClass.new(7))), &"mul_by", [2], Result.Ok(14)],
			[Result.Err(auto_free(CustomClass.new(7))), &"mul_by", [], Result.Err(Result.ERR_UNSAFE_ARGUMENTS)],
			[Result.Err(auto_free(CustomClass.new(7))), &"unknown_method", [], Result.Err(Result.ERR_UNSAFE_METHOD_ACCESS)],
		],
):
	assert_that(input.or_else_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_flatten_with_non_result_value():
	var input := Result.Ok(42)
	assert_that(input.flatten()).is_equal(input)


class CustomClass:
	var prop: int
	var inner_result: Result


	func _init(value: int, res: Result = null) -> void:
		prop = value
		inner_result = res if res != null else Result.Err(0)


	func mul_by(x: int) -> int:
		return prop * x


	func get_result(res: Result) -> Result:
		return res


class Callbacks:
	func produce() -> Variant:
		return null


	func transform(_x: Variant) -> Variant:
		return null
