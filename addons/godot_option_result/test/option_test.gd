class_name OptionTest
extends GdUnitTestSuite

static var GREATER_THAN_ONE := func(x): return x > 1
static var IS_EVEN := func(x): return x % 2 == 0
static var STR_LEN := func(v): return len(v)
static var FORTY_TWO := func(): return 42
static var SQ_THEN_OPTION := func(x):
	var sq: int = x * x
	return Option.Some(sq) if sq <= 1_000_000 else Option.None
static var NONE_LAZY := func(): return Option.None
static var VIKINGS := func(): return Option.Some("vikings")


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
	assert_bool(input.is_some_and(GREATER_THAN_ONE)).is_equal(expected)


func test_is_none_or(
		input: Option,
		expected: bool,
		_test_parameters := [
			[Option.Some(2), true],
			[Option.Some(0), false],
			[Option.None, true],
		],
):
	assert_bool(input.is_none_or(GREATER_THAN_ONE)).is_equal(expected)


func test_tee(
		input: Option,
		call_expected: bool,
		_test_parameters := [
			[Option.Some(2), true],
			[Option.None, false],
		],
):
	var state := { "called": false }
	var mark_called := func(_x): state.called = true
	var returned = input.tee(mark_called)
	assert_bool(state.called).is_equal(call_expected)
	assert_that(returned).is_equal(input)


func test_unwrap__returns_value_when_some():
	assert_that(Option.Some("air").unwrap()).is_equal("air")


func test_unwrap_or(
		input: Option,
		expected: Variant,
		_test_parameters := [
			[Option.Some("car"), "car"],
			[Option.None, "bike"],
		],
):
	assert_that(input.unwrap_or("bike")).is_equal(expected)


func test_unwrap_or_call(
		input: Option,
		expected: Variant,
		_test_parameters := [
			[Option.Some(4), 4],
			[Option.None, 42],
		],
):
	assert_that(input.unwrap_or_call(FORTY_TWO)).is_equal(expected)


func test_map(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some("Hello, World!"), Option.Some(13)],
			[Option.None, Option.None],
		],
):
	assert_that(input.map(STR_LEN)).is_equal(expected)


func test_map_or(
		input: Option,
		expected: Variant,
		_test_parameters := [
			[Option.Some("foo"), 3],
			[Option.None, 42],
		],
):
	assert_that(input.map_or(42, STR_LEN)).is_equal(expected)


func test_map_or_call(
		input: Option,
		expected: Variant,
		_test_parameters := [
			[Option.Some("foo"), 3],
			[Option.None, 42],
		],
):
	assert_that(input.map_or_call(FORTY_TWO, STR_LEN)).is_equal(expected)


func test_keep_when(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.None, Option.None],
			[Option.Some(3), Option.None],
			[Option.Some(4), Option.Some(4)],
		],
):
	assert_that(input.keep_when(IS_EVEN)).is_equal(expected)


func test_drop_when(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.None, Option.None],
			[Option.Some(4), Option.None],
			[Option.Some(3), Option.Some(3)],
		],
):
	assert_that(input.drop_when(IS_EVEN)).is_equal(expected)


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
	assert_that(input.and_then_call(SQ_THEN_OPTION)).is_equal(expected)


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
		f: Callable,
		expected: Option,
		_test_parameters := [
			[Option.Some("barbarians"), VIKINGS, Option.Some("barbarians")],
			[Option.None, VIKINGS, Option.Some("vikings")],
			[Option.None, NONE_LAZY, Option.None],
		],
):
	assert_that(input.or_else_call(f)).is_equal(expected)


func test_xor_with(
		a: Option,
		b: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some(2), Option.None, Option.Some(2)],
			[Option.None, Option.Some(2), Option.Some(2)],
			[Option.Some(2), Option.Some(2), Option.None],
			[Option.None, Option.None, Option.None],
		],
):
	assert_that(a.xor_with(b)).is_equal(expected)


func test_flatten(
		input: Option,
		expected: Option,
		_test_parameters := [
			[Option.Some(Option.Some(6)), Option.Some(6)],
			[Option.Some(Option.None), Option.None],
			[Option.None, Option.None],
		],
):
	assert_that(input.flatten()).is_equal(expected)


func test_ok_or(
		input: Option,
		expected: Result,
		_test_parameters := [
			[Option.Some("foo"), Result.Ok("foo")],
			[Option.None, Result.Err(0)],
		],
):
	assert_that(input.ok_or(0)).is_equal(expected)


func test_ok_or_call(
		input: Option,
		expected: Result,
		_test_parameters := [
			[Option.Some("foo"), Result.Ok("foo")],
			[Option.None, Result.Err(42)],
		],
):
	assert_that(input.ok_or_call(FORTY_TWO)).is_equal(expected)


func test_transpose(
		input: Option,
		expected: Result,
		_test_parameters := [
			[Option.None, Result.Ok(Option.None)],
			[Option.Some(Result.Ok(5)), Result.Ok(Option.Some(5))],
			[Option.Some(Result.Err("SomeErr")), Result.Err("SomeErr")],
		],
):
	assert_that(input.transpose()).is_equal(expected)


func test_transpose__some_of_non_result_becomes_gd_err():
	assert_that(Option.Some(42).transpose()).is_equal(
		Result.Err(error_string(Error.ERR_INVALID_DATA)),
	)


func test_is_equal(
		a: Option,
		b: Option,
		expected: bool,
		_test_parameters := [
			[Option.Some(2), Option.Some(2), true],
			[Option.Some(2), Option.Some(3), false],
			[Option.Some(2), Option.None, false],
			[Option.None, Option.None, true],
		],
):
	assert_bool(a.is_equal(b)).is_equal(expected)


func test_is_equal_approx(
		a: Option,
		b: Option,
		expected: bool,
		_test_parameters := [
			[Option.Some(1.0), Option.Some(1.0), true],
			[Option.Some(1.0), Option.Some(1.0 + 1e-9), true],
			[Option.Some("x"), Option.Some("x"), true],
			[Option.Some(1.0), Option.Some(2.0), false],
			[Option.Some("x"), Option.Some("y"), false],
			[Option.Some(1.0), Option.None, false],
		],
):
	assert_bool(a.is_equal_approx(b)).is_equal(expected)
