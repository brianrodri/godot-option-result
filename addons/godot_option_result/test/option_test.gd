class_name OptionTest
extends GdUnitTestSuite


func test_member(
		instance: Variant,
		member_name: StringName,
		expectation: Option,
		_test_parameters := [
			[auto_free(Node.new()), &"process_mode", Option.Some(PROCESS_MODE_INHERIT)],
			[auto_free(Node.new()), &"process_lols", Option.None],
			[null, &"process_mode", Option.None],
			[Vector3.ONE, &"x", Option.None],
			[auto_free(CustomClass.new(42)), &"prop", Option.Some(42)],
			[auto_free(CustomClass.new(42)), &"unknown_prop", Option.None],
		],
):
	assert_that(Option.member(instance, member_name)).is_equal(expectation)


func test_method_call(
		instance: Variant,
		method_name: StringName,
		method_args: Array,
		expectation: Option,
		_test_parameters := [
			[auto_free(Node.new()), &"is_node_ready", [], Option.Some(false)],
			[auto_free(Node.new()), &"is_food_ready", [], Option.None],
			[auto_free(Node.new()), &"can_process", [1, 2, 3], Option.None],
			[null, &"is_node_ready", [], Option.None],
			[Vector3.ONE, &"is_equal_approx", [Vector3.ONE], Option.Some(true)],
			[auto_free(CustomClass.new(42)), &"mul_by", [2], Option.Some(84)],
			[auto_free(CustomClass.new(42)), &"mul_by", [], Option.None],
			[auto_free(CustomClass.new(42)), &"mul_by", [2, 3], Option.None],
			[auto_free(CustomClass.new(42)), &"mul_by_two", [2], Option.None],
		],
):
	assert_that(Option.method_call.bindv(method_args).call(instance, method_name)).is_equal(expectation)


func test_to_string_with_simple_types(
		input: Option,
		expected: String,
		_test_parameters := [
			[Option.None, "None"],
			[Option.Some(null), "Some(<null>)"],
			[Option.Some(42), "Some(42)"],
			[Option.Some("42"), 'Some("42")'],
			[Option.Some(&"42"), 'Some(&"42")'],
			[Option.Some([1, 2, 3]), "Some([1, 2, 3])"],
			[Option.Some(["1", "2", "3"]), 'Some(["1", "2", "3"])'],
			[Option.Some({ a = 1 }), 'Some({ &"a": 1 })'],
			[Option.Some({ a = "1" }), 'Some({ &"a": "1" })'],
		],
):
	assert_str(str(input)).is_equal(expected)


func test_is_some(
		input: Option,
		expected: bool,
		_test_parameters := [
			[Option.Some(2), true],
			[Option.None, false],
		],
):
	assert_bool(input.is_some()).is_equal(expected)


func test_is_none(
		input: Option,
		expected: bool,
		_test_parameters := [
			[Option.Some(2), false],
			[Option.None, true],
		],
):
	assert_bool(input.is_none()).is_equal(expected)


func test_is_some_and(
		input: Option,
		expected: bool,
		_test_parameters := [
			[Option.Some(2), true],
			[Option.Some(0), false],
			[Option.None, false],
		],
):
	assert_bool(input.is_some_and(func(x): return x > 1)).is_equal(expected)


func test_is_none_or(
		input: Option,
		expected: bool,
		_test_parameters := [
			[Option.Some(2), true],
			[Option.Some(0), false],
			[Option.None, true],
		],
):
	assert_bool(input.is_none_or(func(x): return x > 1)).is_equal(expected)


func test_iterate_none():
	var found := []
	for value in Option.None:
		found.append(value)
	assert_array(found).is_empty()


func test_iterate_some():
	var found := []
	for value in Option.Some(42):
		found.append(value)
	assert_array(found).contains_exactly(42)


func test_pipe(
		input: Option,
		call_expected: bool,
		_test_parameters := [
			[Option.Some(2), true],
			[Option.None, false],
		],
):
	var state := { "called": false }
	var returned = input.pipe(func(_x): state.called = true)
	assert_bool(state.called).is_equal(call_expected)
	assert_that(returned).is_equal(input)


func test_unwrap_returns_value_when_some():
	assert_that(Option.Some("air").unwrap()).is_equal("air")


func test_unwrap_fails_with_default_message_when_none() -> void:
	await assert_error(Option.None.unwrap).is_runtime_error("Assertion failed: [method Option.unwrap] called on None")


func test_unwrap_fails_with_custom_message_when_none() -> void:
	await assert_error(Option.None.unwrap.bind("expected a value")).is_runtime_error("Assertion failed: expected a value")


func test_unwrap_substitutes_self_into_custom_message_when_none() -> void:
	await (
		assert_error(Option.None.unwrap.bind("{0} must be some")).is_runtime_error("Assertion failed: None must be some")
	)


func test_unwrap_or(
		input: Option,
		default: Variant,
		expected: Variant,
		_test_parameters := [
			[Option.Some("car"), "bike", "car"],
			[Option.None, "bike", "bike"],
		],
):
	assert_that(input.unwrap_or(default)).is_equal(expected)


func test_unwrap_or_call(
		input: Option,
		default: Variant,
		expected: Variant,
		call_expected: bool,
		_test_parameters := [
			[Option.Some(4), 42, 4, false],
			[Option.None, 42, 42, true],
		],
):
	var state := { "called": false }
	var get_default := func():
		state.called = true
		return default
	assert_that(input.unwrap_or_call(get_default)).is_equal(expected)
	assert_bool(state.called).is_equal(call_expected)


func test_map(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some("Hello, World!"), Option.Some(13)],
			[Option.None, Option.None],
		],
):
	assert_that(input.map(len)).is_equal(expected)


func test_map_or(
		input: Option,
		expected: Variant,
		_test_parameters := [
			[Option.Some("foo"), 3],
			[Option.None, 42],
		],
):
	assert_that(input.map_or(42, len)).is_equal(expected)


func test_map_or_call(
		input: Option,
		default: Variant,
		expected: Variant,
		call_expected: bool,
		_test_parameters := [
			[Option.Some("foo"), 42, 3, false],
			[Option.None, 42, 42, true],
		],
):
	var state := { "called": false }
	var get_default := func():
		state.called = true
		return default
	assert_that(input.map_or_call(get_default, len)).is_equal(expected)
	assert_bool(state.called).is_equal(call_expected)


func test_keep_when(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.None, Option.None],
			[Option.Some(3), Option.None],
			[Option.Some(4), Option.Some(4)],
		],
):
	assert_that(input.keep_when(func(x): return x % 2 == 0)).is_equal(expected)


func test_drop_when(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.None, Option.None],
			[Option.Some(4), Option.None],
			[Option.Some(3), Option.Some(3)],
		],
):
	assert_that(input.drop_when(func(x): return x % 2 == 0)).is_equal(expected)


func test_and_then(
		self_opt: Option,
		other: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some(2), Option.None, Option.None],
			[Option.None, Option.Some("foo"), Option.None],
			[Option.Some(2), Option.Some("foo"), Option.Some("foo")],
			[Option.None, Option.None, Option.None],
		],
):
	assert_that(self_opt.and_then(other)).is_equal(expected)


func test_and_then_call(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some(2), Option.Some(4)],
			[Option.Some(1_000_000), Option.None],
			[Option.None, Option.None],
		],
):
	(
		assert_that(input.and_then_call(func(x): return Option.Some(x * x) if x <= 1000 else Option.None)).is_equal(expected)
	)


func test_or_else(
		self_opt: Option,
		other: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some(2), Option.None, Option.Some(2)],
			[Option.None, Option.Some(100), Option.Some(100)],
			[Option.Some(2), Option.Some(100), Option.Some(2)],
			[Option.None, Option.None, Option.None],
		],
):
	assert_that(self_opt.or_else(other)).is_equal(expected)


func test_or_else_call(
		input: Option,
		default: Option,
		expected: Option,
		call_expected: bool,
		_test_parameters := [
			[Option.Some("barbarians"), Option.Some("vikings"), Option.Some("barbarians"), false],
			[Option.None, Option.Some("vikings"), Option.Some("vikings"), true],
			[Option.None, Option.None, Option.None, true],
		],
):
	var state := { "called": false }
	var f := func():
		state.called = true
		return default
	assert_that(input.or_else_call(f)).is_equal(expected)
	assert_bool(state.called).is_equal(call_expected)


func test_xor_with(
		a: Option,
		b: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some(1), Option.None, Option.Some(1)],
			[Option.None, Option.Some(2), Option.Some(2)],
			[Option.Some(1), Option.Some(2), Option.None],
			[Option.None, Option.None, Option.None],
		],
):
	assert_that(a.xor_with(b)).is_equal(expected)


func test_flatten(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some(Option.Some(Option.Some(6))), Option.Some(Option.Some(6))],
			[Option.Some(Option.Some(6)), Option.Some(6)],
			[Option.Some(Option.None), Option.None],
			[Option.None, Option.None],
		],
):
	assert_that(input.flatten()).is_equal(expected)


func test_ok_or(
		input: Option,
		default: Variant,
		expected: Result,
		_test_parameters := [
			[Option.Some("foo"), "uh-oh!", Result.Ok("foo")],
			[Option.None, 0, Result.Err(0)],
		],
):
	assert_that(input.ok_or(default)).is_equal(expected)


func test_ok_or_call(
		input: Option,
		default: Variant,
		expected: Result,
		call_expected: bool,
		_test_parameters := [
			[Option.Some("foo"), 42, Result.Ok("foo"), false],
			[Option.None, 42, Result.Err(42), true],
		],
):
	var state := { "called": false }
	var get_default := func():
		state.called = true
		return default
	assert_that(input.ok_or_call(get_default)).is_equal(expected)
	assert_bool(state.called).is_equal(call_expected)


func test_transpose(
		input: Option,
		expected: Result,
		_test_parameters := [
			[Option.None, Result.Ok(Option.None)],
			[Option.Some(Result.Ok(5)), Result.Ok(Option.Some(5))],
			[Option.Some(Result.Err("SomeErr")), Result.Err("SomeErr")],
		],
):
	assert_that(input).is_equal(expected.transpose())
	assert_that(input.transpose()).is_equal(expected)
	assert_that(input.transpose().transpose()).is_equal(input)


func test_transpose_with_non_result_value():
	var some_value_but_not_result := Option.Some(42)
	var invalid_data_error := Result.GdErr(Error.ERR_INVALID_DATA)
	assert_that(some_value_but_not_result.transpose()).is_equal(invalid_data_error)


class CustomClass:
	var prop: int


	func _init(value: int) -> void:
		prop = value


	func mul_by(x: int) -> int:
		return prop * x
