class_name OptionTest
extends GdUnitTestSuite


func test_from_member(
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
	assert_that(Option.from_member(instance, member_name)).is_equal(expectation)


func test_from_method_call(
		instance: Variant,
		method_name: StringName,
		arguments: Array,
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
	assert_that(Option.from_method_call.bindv(arguments).call(instance, method_name)).is_equal(expectation)


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
		times_expected: int,
		_test_parameters := [
			[Option.Some(2), 1],
			[Option.None, 0],
		],
):
	var cb := mock(Callbacks) as Callbacks
	var returned = input.pipe(cb.transform)
	verify(cb, times_expected).transform(any())
	assert_that(returned).is_equal(input)


func test_unwrap_returns_value_when_some():
	assert_that(Option.Some("air").unwrap()).is_equal("air")


func test_unwrap_fails_with_default_message_when_none() -> void:
	await assert_error(Option.None.unwrap).is_runtime_error("Assertion failed: %s" % Option.ERR_ILLEGAL_UNWRAP)


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
		times_called: int,
		_test_parameters := [
			[Option.Some(4), 42, 4, 0],
			[Option.None, 42, 42, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).produce()
	assert_that(input.unwrap_or_call(cb.produce)).is_equal(expected)
	verify(cb, times_called).produce()


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
		times_called: int,
		_test_parameters := [
			[Option.Some("foo"), 42, 3, 0],
			[Option.None, 42, 42, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).produce()
	assert_that(input.map_or_call(cb.produce, len)).is_equal(expected)
	verify(cb, times_called).produce()


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
			assert_that(input.and_then_call(func(x): return Option.Some(x * x) if x <= 1000 else Option.None))
			.is_equal(expected)
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
		times_called: int,
		_test_parameters := [
			[Option.Some("barbarians"), Option.Some("vikings"), Option.Some("barbarians"), 0],
			[Option.None, Option.Some("vikings"), Option.Some("vikings"), 1],
			[Option.None, Option.None, Option.None, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).produce()
	assert_that(input.or_else_call(cb.produce)).is_equal(expected)
	verify(cb, times_called).produce()


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
		times_called: int,
		_test_parameters := [
			[Option.Some("foo"), 42, Result.Ok("foo"), 0],
			[Option.None, 42, Result.Err(42), 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).produce()
	assert_that(input.ok_or_call(cb.produce)).is_equal(expected)
	verify(cb, times_called).produce()


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
	assert_that(Option.Some(42).transpose()).is_equal(Result.Err(Option.ERR_ILLEGAL_TRANSPOSE))


func test_not_null(
		x: Variant,
		expected: Option,
		_test_parameters := [
			[null, Option.None],
			[42, Option.Some(42)],
			["", Option.Some("")],
			[false, Option.Some(false)],
			[0, Option.Some(0)],
			[[], Option.Some([])],
		],
):
	assert_that(Option.not_null(x)).is_equal(expected)


func test_map_member(
		input: Option,
		member_name: StringName,
		expected: Option,
		_test_parameters := [
			[Option.None, &"prop", Option.None],
			[Option.Some(auto_free(CustomClass.new(42))), &"prop", Option.Some(42)],
			[Option.Some(auto_free(CustomClass.new(42))), &"unknown_prop", Option.None],
			[Option.Some(auto_free(Node.new())), &"process_mode", Option.Some(PROCESS_MODE_INHERIT)],
		],
):
	assert_that(input.map_member(member_name)).is_equal(expected)


func test_map_method_call(
		input: Option,
		method_name: StringName,
		arguments: Array,
		expected: Option,
		_test_parameters := [
			[Option.None, &"mul_by", [2], Option.None],
			[Option.Some(auto_free(CustomClass.new(42))), &"mul_by", [2], Option.Some(84)],
			[Option.Some(auto_free(CustomClass.new(42))), &"mul_by", [], Option.None],
			[Option.Some(auto_free(CustomClass.new(42))), &"unknown_method", [], Option.None],
		],
):
	assert_that(input.map_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_map_member_or(
		input: Option,
		default: Variant,
		member_name: StringName,
		expected: Variant,
		_test_parameters := [
			[Option.None, "default", &"prop", "default"],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"prop", 42],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"unknown_prop", -1],
		],
):
	assert_that(input.map_member_or(default, member_name)).is_equal(expected)


func test_map_method_call_or(
		input: Option,
		default: Variant,
		method_name: StringName,
		arguments: Array,
		expected: Variant,
		_test_parameters := [
			[Option.None, -1, &"mul_by", [2], -1],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"mul_by", [2], 84],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"mul_by", [], -1],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"unknown_method", [], -1],
		],
):
	assert_that(input.map_method_call_or.bindv(arguments).call(default, method_name)).is_equal(expected)


func test_map_member_or_call(
		input: Option,
		default: Variant,
		member_name: StringName,
		expected: Variant,
		times_called: int,
		_test_parameters := [
			[Option.None, -1, &"prop", -1, 1],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"prop", 42, 0],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"unknown_prop", -1, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).produce()
	assert_that(input.map_member_or_call(cb.produce, member_name)).is_equal(expected)
	verify(cb, times_called).produce()


func test_map_method_call_or_call(
		input: Option,
		default: Variant,
		method_name: StringName,
		arguments: Array,
		expected: Variant,
		times_called: int,
		_test_parameters := [
			[Option.None, -1, &"mul_by", [2], -1, 1],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"mul_by", [2], 84, 0],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"mul_by", [], -1, 1],
			[Option.Some(auto_free(CustomClass.new(42))), -1, &"unknown_method", [], -1, 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(default).on(cb).produce()
	assert_that(input.map_method_call_or_call.bindv(arguments).call(cb.produce, method_name)).is_equal(expected)
	verify(cb, times_called).produce()


func test_keep_when_member(
		input: Option,
		member_name: StringName,
		keep: bool,
		_test_parameters := [
			[Option.None, &"prop", false],
			[Option.Some(auto_free(CustomClass.new(0))), &"prop", false],
			[Option.Some(auto_free(CustomClass.new(42))), &"prop", true],
			[Option.Some(auto_free(CustomClass.new(42))), &"unknown_prop", false],
		],
):
	var expected: Option = input if keep else Option.None
	assert_that(input.keep_when_member(member_name)).is_equal(expected)


func test_keep_when_method_call(
		input: Option,
		method_name: StringName,
		arguments: Array,
		keep: bool,
		_test_parameters := [
			[Option.None, &"mul_by", [2], false],
			[Option.Some(auto_free(CustomClass.new(0))), &"mul_by", [2], false],
			[Option.Some(auto_free(CustomClass.new(42))), &"mul_by", [2], true],
			[Option.Some(auto_free(CustomClass.new(42))), &"mul_by", [], false],
			[Option.Some(auto_free(CustomClass.new(42))), &"unknown_method", [], false],
		],
):
	var expected: Option = input if keep else Option.None
	assert_that(input.keep_when_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_drop_when_member(
		input: Option,
		member_name: StringName,
		keep: bool,
		_test_parameters := [
			[Option.None, &"prop", false],
			[Option.Some(auto_free(CustomClass.new(0))), &"prop", true],
			[Option.Some(auto_free(CustomClass.new(42))), &"prop", false],
			[Option.Some(auto_free(CustomClass.new(42))), &"unknown_prop", true],
		],
):
	var expected: Option = input if keep else Option.None
	assert_that(input.drop_when_member(member_name)).is_equal(expected)


func test_drop_when_method_call(
		input: Option,
		method_name: StringName,
		arguments: Array,
		keep: bool,
		_test_parameters := [
			[Option.None, &"mul_by", [2], false],
			[Option.Some(auto_free(CustomClass.new(0))), &"mul_by", [2], true],
			[Option.Some(auto_free(CustomClass.new(42))), &"mul_by", [2], false],
			[Option.Some(auto_free(CustomClass.new(42))), &"mul_by", [], true],
			[Option.Some(auto_free(CustomClass.new(42))), &"unknown_method", [], true],
		],
):
	var expected: Option = input if keep else Option.None
	assert_that(input.drop_when_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_and_then_member(
		input: Option,
		member_name: StringName,
		expected: Option,
		_test_parameters := [
			[Option.None, &"inner_opt", Option.None],
			[Option.Some(auto_free(CustomClass.new(0, Option.Some(42)))), &"inner_opt", Option.Some(42)],
			[Option.Some(auto_free(CustomClass.new(0, Option.None))), &"inner_opt", Option.None],
			[Option.Some(auto_free(CustomClass.new(0))), &"unknown_prop", Option.None],
		],
):
	assert_that(input.and_then_member(member_name)).is_equal(expected)


func test_and_then_method_call(
		input: Option,
		method_name: StringName,
		arguments: Array,
		expected: Option,
		_test_parameters := [
			[Option.None, &"get_opt", [Option.Some(42)], Option.None],
			[Option.Some(auto_free(CustomClass.new(0))), &"get_opt", [Option.Some(42)], Option.Some(42)],
			[Option.Some(auto_free(CustomClass.new(0))), &"get_opt", [Option.None], Option.None],
			[Option.Some(auto_free(CustomClass.new(0))), &"unknown_method", [], Option.None],
		],
):
	assert_that(input.and_then_method_call.bindv(arguments).call(method_name)).is_equal(expected)


func test_ok_or_else(
		input: Option,
		other: Result,
		expected: Result,
		_test_parameters := [
			[Option.Some("foo"), Result.Err("ignored"), Result.Ok("foo")],
			[Option.None, Result.Err("uh-oh"), Result.Err("uh-oh")],
			[Option.None, Result.Ok(42), Result.Ok(42)],
		],
):
	assert_that(input.ok_or_else(other)).is_equal(expected)


func test_ok_or_else_call(
		input: Option,
		other: Result,
		expected: Result,
		times_called: int,
		_test_parameters := [
			[Option.Some("foo"), Result.Err(42), Result.Ok("foo"), 0],
			[Option.None, Result.Err(42), Result.Err(42), 1],
			[Option.None, Result.Ok(7), Result.Ok(7), 1],
		],
):
	var cb := mock(Callbacks) as Callbacks
	do_return(other).on(cb).produce()
	assert_that(input.ok_or_else_call(cb.produce)).is_equal(expected)
	verify(cb, times_called).produce()


func test_flatten_with_non_option_value():
	var input := Option.Some(42)
	assert_that(input.flatten()).is_equal(input)


class CustomClass:
	var prop: int
	var inner_opt: Option


	func _init(value: int, opt: Option = null) -> void:
		prop = value
		inner_opt = opt if opt != null else Option.None


	func mul_by(x: int) -> int:
		return prop * x


	func get_opt(opt: Option) -> Option:
		return opt


class Callbacks:
	func produce() -> Variant:
		return null


	func transform(_x: Variant) -> Variant:
		return null
