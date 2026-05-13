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


func test_take_member(
		instance: Variant,
		member_name: StringName,
		expectation: Result,
		_test_parameters := [
			[auto_free(Node.new()), &"process_mode", Result.Ok(PROCESS_MODE_INHERIT)],
			[auto_free(Node.new()), &"process_lols", Result.GdErr(ERR_INVALID_DECLARATION)],
			[null, &"process_mode", Result.GdErr(ERR_INVALID_PARAMETER)],
			[Vector3.ONE, &"x", Result.GdErr(ERR_INVALID_PARAMETER)],
			[auto_free(CustomClass.new(42)), &"prop", Result.Ok(42)],
			[auto_free(CustomClass.new(42)), &"unknown_prop", Result.GdErr(ERR_INVALID_DECLARATION)],
		],
):
	assert_that(Result.take_member(instance, member_name)).is_equal(expectation)


func test_make_method_call(
		instance: Variant,
		method_name: StringName,
		method_args: Array,
		expectation: Result,
		_test_parameters := [
			[auto_free(Node.new()), &"is_node_ready", [], Result.Ok(false)],
			[auto_free(Node.new()), &"is_food_ready", [], Result.GdErr(ERR_INVALID_DECLARATION)],
			[auto_free(Node.new()), &"can_process", [1, 2, 3], Result.GdErr(ERR_PARAMETER_RANGE_ERROR)],
			[null, &"is_node_ready", [], Result.GdErr(ERR_INVALID_PARAMETER)],
			[Vector3.ONE, &"is_equal_approx", [Vector3.ONE], Result.GdErr(ERR_INVALID_PARAMETER)],
			[auto_free(CustomClass.new(42)), &"mul_by", [2], Result.Ok(84)],
			[auto_free(CustomClass.new(42)), &"mul_by", [], Result.GdErr(ERR_PARAMETER_RANGE_ERROR)],
			[auto_free(CustomClass.new(42)), &"mul_by", [2, 3], Result.GdErr(ERR_PARAMETER_RANGE_ERROR)],
			[auto_free(CustomClass.new(42)), &"mul_by_two", [2], Result.GdErr(ERR_INVALID_DECLARATION)],
		],
):
	assert_that(Result.make_method_call.bindv(method_args).call(instance, method_name)).is_equal(expectation)


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


func test_pipe(
		input: Result,
		call_expected: bool,
		_test_parameters := [
			[Result.Ok(2), true],
			[Result.Err("e"), false],
		],
):
	var state := { "called": false }
	var returned = input.pipe(func(_x): state.called = true)
	assert_that(returned).is_equal(input)
	assert_bool(state.called).is_equal(call_expected)


func test_pipe_err(
		input: Result,
		call_expected: bool,
		_test_parameters := [
			[Result.Ok(2), false],
			[Result.Err("e"), true],
		],
):
	var state := { "called": false }
	var returned = input.pipe_err(func(_x): state.called = true)
	assert_that(returned).is_equal(input)
	assert_that(state.called).is_equal(call_expected)


func test_unwrap_returns_value_when_ok():
	assert_int(Result.Ok(2).unwrap()).is_equal(2)


func test_unwrap_fails_with_default_message_when_err() -> void:
	await (
		assert_error(func(): Result.Err(42).unwrap()) \
				.is_runtime_error("Assertion failed: [method Result.unwrap] called on Err(42)")
	)


func test_unwrap_fails_with_custom_message_when_err() -> void:
	await (
		assert_error(func(): Result.Err("boom").unwrap("expected a value")) \
				.is_runtime_error("Assertion failed: expected a value")
	)


func test_unwrap_substitutes_self_into_custom_message_when_err() -> void:
	await (
		assert_error(func(): Result.Err("boom").unwrap("got {0}, wanted Ok")) \
				.is_runtime_error('Assertion failed: got Err("boom"), wanted Ok')
	)


func test_unwrap_err_returns_error_when_err():
	assert_str(Result.Err("emergency failure").unwrap_err()).is_equal("emergency failure")


func test_unwrap_err_fails_with_default_message_when_ok() -> void:
	await (
		assert_error(func(): Result.Ok(42).unwrap_err()) \
				.is_runtime_error("Assertion failed: [method Result.unwrap_err] called on Ok(42)")
	)


func test_unwrap_err_fails_with_custom_message_when_ok() -> void:
	await (
		assert_error(func(): Result.Ok(42).unwrap_err("expected an error")) \
				.is_runtime_error("Assertion failed: expected an error")
	)


func test_unwrap_err_substitutes_self_into_custom_message_when_ok() -> void:
	await (
		assert_error(func(): Result.Ok(42).unwrap_err("got {0}, wanted Err")) \
				.is_runtime_error("Assertion failed: got Ok(42), wanted Err")
	)


func test_unwrap_or(
		result: Result,
		default: Variant,
		expected: Variant,
		_test_parameters := [
			[Result.Ok(9), 0, 9],
			[Result.Err("error"), 0, 0],
		],
):
	assert_that(result.unwrap_or(default)).is_equal(expected)


func test_unwrap_or_call(
		result: Result,
		expected: Variant,
		call_expected: bool,
		_test_parameters := [
			[Result.Ok(2), 2, false],
			[Result.Err("foo"), 3, true],
		],
):
	var state := { "called": false }
	var get_length := func(e):
		state.called = true
		return len(e)
	assert_that(result.unwrap_or_call(get_length)).is_equal(expected)
	assert_bool(state.called).is_equal(call_expected)


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
		call_expected: bool,
		_test_parameters := [
			[Result.Ok("foo"), 3, false],
			[Result.Err(21), 42, true],
		],
):
	var state := { "called": false }
	var get_times_two := func(x):
		state.called = true
		return x * 2
	assert_that(input.map_or_call(get_times_two, len)).is_equal(expected)
	assert_bool(state.called).is_equal(call_expected)


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
		call_expected: bool,
		_test_parameters := [
			[Result.Ok(2), Result.Ok(4), true],
			[Result.Ok(1_000_000), Result.Err("overflowed"), true],
			[Result.Err("not a number"), Result.Err("not a number"), false],
		],
):
	var state := { "called": false }
	var get_square := func(x):
		state.called = true
		return Result.Ok(x * x) if abs(x) < 1_000_000 else Result.Err("overflowed")
	assert_that(input.and_then_call(get_square)).is_equal(expected)
	assert_bool(state.called).is_equal(call_expected)


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
		call_expected: bool,
		_test_parameters := [
			[Result.Ok(2), Result.Ok(4), Result.Ok(2), false],
			[Result.Err(3), Result.Ok(9), Result.Ok(9), true],
			[Result.Err(3), Result.Err(3), Result.Err(3), true],
		],
):
	var state := { "called": false }
	var get_default := func(_x):
		state.called = true
		return default
	assert_that(input.or_else_call(get_default)).is_equal(expected)
	assert_bool(state.called).is_equal(call_expected)


func test_recover_with(
		input: Result,
		expected: Result,
		_test_parameters := [
			[Result.Err("retryable"), Result.Ok("fallback")],
			[Result.Err("fatal"), Result.Err("fatal")],
			[Result.Ok("already-ok"), Result.Ok("already-ok")],
		],
):
	assert_that(input.recover_with("retryable", "fallback")).is_equal(expected)


func test_recover_with_call_executes_only_on_match():
	var state := { "called": false }
	var f := func(_err: String) -> String:
		state.called = true
		return "fallback"
	assert_that(Result.Err("retryable").recover_with_call("retryable", f).pipe_err(f)).is_equal(Result.Ok("fallback"))
	assert_bool(state.called).is_true()


func test_recover_with_call_skips_callback_on_mismatch():
	var state := { "called": false }
	var f := func(_val: String) -> String:
		state.called = true
		return "fallback"
	var original := Result.Err("something-else")
	assert_that(original.recover_with_call("retryable", f)).is_equal(original)
	assert_bool(state.called).is_false()


func test_reject_with(
		input: Result,
		expected: Result,
		_test_parameters := [
			[Result.Ok("bad"), Result.Err("rejected")],
			[Result.Ok("good"), Result.Ok("good")],
			[Result.Err("already-err"), Result.Err("already-err")],
		],
):
	assert_that(input.reject_with("bad", "rejected")).is_equal(expected)


func test_reject_with_call_executes_only_on_match():
	var state := { "called": false }
	var f := func(_val: String) -> String:
		state.called = true
		return "rejected"
	assert_that(Result.Ok("bad").reject_with_call("bad", f)).is_equal(Result.Err("rejected"))
	assert_bool(state.called).is_true()


func test_reject_with_call_skips_callback_on_mismatch():
	var state := { "called": false }
	var f := func(_val: String) -> String:
		state.called = true
		return "rejected"
	var original := Result.Ok("something-else")
	assert_that(original.reject_with_call("bad", f)).is_equal(original)
	assert_bool(state.called).is_false()


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
	var some_invalid_data_error := Option.Some(Result.GdErr(Error.ERR_INVALID_DATA))
	assert_that(ok_value_but_not_option.transpose()).is_equal(some_invalid_data_error)


class CustomClass:
	var prop: int


	func _init(value: int) -> void:
		prop = value


	func mul_by(x: int) -> int:
		return prop * x
