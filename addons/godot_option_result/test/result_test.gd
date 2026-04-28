class_name ResultTest
extends GdUnitTestSuite


static func greater_than_one(x):
	return x > 1


static func times_two(x):
	return x * 2


static func square_checked(x):
	return Result.Ok(x * x) if abs(x) < 1_000_000 else Result.Err("overflowed")


static func square_unchecked(x):
	return Result.Ok(x * x)


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
	assert_bool(result.is_ok_and(greater_than_one)).is_equal(expected)


func test_is_err_and(
		result: Result,
		expected: bool,
		_test_parameters := [
			[Result.Err(2), true],
			[Result.Err(0), false],
			[Result.Ok(123), false],
		],
):
	assert_bool(result.is_err_and(greater_than_one)).is_equal(expected)


func test_tee(
		input: Result,
		expected_called: bool,
		_test_parameters := [
			[Result.Ok(2), true],
			[Result.Err("e"), false],
		],
):
	var state := { "called": false }
	var mark_called := func(_x): state.called = true
	var returned = input.tee(mark_called)
	assert_that(returned).is_equal(input)
	assert_bool(state.called).is_equal(expected_called)


func test_tee_err(
		input: Result,
		expected_called: bool,
		_test_parameters := [
			[Result.Ok(2), false],
			[Result.Err("e"), true],
		],
):
	var state := { "called": false }
	var mark_called := func(_x): state.called = true
	var returned = input.tee_err(mark_called)
	assert_that(returned).is_equal(input)
	assert_that(state.called).is_equal(expected_called)


func test_unwrap__returns_value_when_ok():
	assert_that(Result.Ok(2).unwrap()).is_equal(2)


func test_unwrap_err__returns_error_when_err():
	assert_that(Result.Err("emergency failure").unwrap_err()).is_equal("emergency failure")


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
		_test_parameters := [
			[Result.Ok(2), 2],
			[Result.Err("foo"), 3],
		],
):
	assert_that(result.unwrap_or_call(len)).is_equal(expected)


func test_map(
		input: Result,
		expected: Result,
		_test_parameters := [
			[Result.Ok(2), Result.Ok(4)],
			[Result.Err(13), Result.Err(13)],
		],
):
	assert_that(input.map(times_two)).is_equal(expected)


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
		_test_parameters := [
			[Result.Ok("foo"), 3],
			[Result.Err(21), 42],
		],
):
	assert_that(input.map_or_call(times_two, len)).is_equal(expected)


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
		_test_parameters := [
			[Result.Ok(2), Result.Ok(4)],
			[Result.Ok(1_000_000), Result.Err("overflowed")],
			[Result.Err("not a number"), Result.Err("not a number")],
		],
):
	assert_that(input.and_then_call(square_checked)).is_equal(expected)


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
		f: Callable,
		expected: Result,
		_test_parameters := [
			[Result.Ok(2), square_unchecked, Result.Ok(2)],
			[Result.Err(3), square_unchecked, Result.Ok(9)],
			[Result.Err(3), Result.Err, Result.Err(3)],
		],
):
	assert_that(input.or_else_call(f)).is_equal(expected)


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
			[Result.Ok(42), Option.Some(Result.Err("Invalid data"))],
		],
):
	assert_that(input.transpose()).is_equal(expected)


func test_is_equal(
		a: Result,
		b: Result,
		expected: bool,
		_test_parameters := [
			[Result.Ok(1.0), Result.Ok(1.0), true],
			[Result.Ok(1.0), Result.Ok(1.0 + 1e-9), false],
			[Result.Ok(2), Result.Ok(2), true],
			[Result.Ok(2), Result.Ok(3), false],
			[Result.Ok(2), Result.Err(2), false],
			[Result.Err("x"), Result.Err("x"), true],
			[Result.Err("x"), Result.Err("y"), false],
		],
):
	assert_bool(a.is_equal(b)).is_equal(expected)


func test_is_equal_approx(
		a: Result,
		b: Result,
		expected: bool,
		_test_parameters := [
			[Result.Ok(1.0), Result.Ok(1.0), true],
			[Result.Ok(1.0), Result.Ok(1.0 + 1e-9), true],
			[Result.Ok("x"), Result.Ok("x"), true],
			[Result.Ok(1.0), Result.Ok(2.0), false],
			[Result.Ok("x"), Result.Ok("y"), false],
			[Result.Ok(1.0), Result.Err(1.0), false],
		],
):
	assert_bool(a.is_equal_approx(b)).is_equal(expected)


func test_gd_err(
		error: Error,
		expected: Result,
		_test_parameters := [
			[Error.OK, Result.Ok(Error.OK)],
			[Error.ERR_INVALID_DATA, Result.Err("Invalid data")],
		],
):
	assert_that(Result.GdErr(error)).is_equal(expected)
