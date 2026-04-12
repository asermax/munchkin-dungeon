extends GutTest

## Tests for TurnQueue — round-based initiative sorting.

var _queue: TurnQueue
var _heroes: Array
var _enemies: Array


func before_each() -> void:
	seed(42)

	_queue = TurnQueue.new()

	# Heroes with distinct initiatives
	_heroes = [
		TestFactory.make_hero_unit({
			"unit_overrides": {"id": "hero_fast"},
			"row": "front", "slot": 0,
		}),
		TestFactory.make_hero_unit({
			"unit_overrides": {"id": "hero_slow"},
			"row": "back", "slot": 0,
		}),
	]
	_heroes[0].initiative = 30
	_heroes[1].initiative = 10

	_enemies = [
		TestFactory.make_monster_unit({
			"monster_data": TestFactory.make_monster_data({"id": "enemy_mid", "initiative": 20}),
			"row": "front", "slot": 0,
		}),
	]

	_queue.setup(_heroes + _enemies)


# -- setup / start_round --

func test_round_number_starts_at_zero() -> void:
	assert_eq(_queue.get_round_number(), 0)


func test_start_round_increments_round() -> void:
	_queue.start_round()

	assert_eq(_queue.get_round_number(), 1)


func test_start_round_includes_all_living_units() -> void:
	_queue.start_round()
	var count := 0

	while true:
		var unit := _queue.get_next_unit()

		if unit == null:
			break

		count += 1

	assert_eq(count, 3, "all 3 living units should get a turn")


# -- get_next_unit --

func test_get_next_unit_returns_null_when_round_over() -> void:
	_queue.start_round()

	# Exhaust all turns
	while _queue.get_next_unit() != null:
		pass

	assert_null(_queue.get_next_unit())


func test_get_next_unit_skips_dead_units() -> void:
	_queue.start_round()

	# Kill the first unit that acts
	var first := _queue.get_next_unit()
	first.is_alive = false

	# Next round, dead unit should be skipped
	_queue.start_round()
	var count := 0

	while _queue.get_next_unit() != null:
		count += 1

	assert_eq(count, 2, "dead unit excluded from next round")


# -- remove_unit --

func test_remove_unit_marks_dead() -> void:
	_queue.remove_unit(_heroes[0])

	assert_false(_heroes[0].is_alive)


func test_remove_unit_excluded_from_next_round() -> void:
	_queue.remove_unit(_heroes[1])
	_queue.start_round()

	var acting_ids: Array[String] = []

	while true:
		var unit := _queue.get_next_unit()

		if unit == null:
			break

		acting_ids.append(unit.unit_id)

	assert_false(acting_ids.has(_heroes[1].unit_id), "removed unit shouldn't act")
	assert_eq(acting_ids.size(), 2)


# -- is_round_over --

func test_is_round_over_before_start() -> void:
	# Before starting, turn order is empty
	assert_true(_queue.is_round_over())


func test_is_round_over_during_round() -> void:
	_queue.start_round()

	assert_false(_queue.is_round_over())


func test_is_round_over_after_all_acted() -> void:
	_queue.start_round()

	while _queue.get_next_unit() != null:
		pass

	assert_true(_queue.is_round_over())


# -- get_living_count --

func test_get_living_count_heroes() -> void:
	assert_eq(_queue.get_living_count(true), 2)


func test_get_living_count_enemies() -> void:
	assert_eq(_queue.get_living_count(false), 1)


func test_get_living_count_after_death() -> void:
	_heroes[0].is_alive = false

	assert_eq(_queue.get_living_count(true), 1)


# -- initiative ordering with seed --

func test_initiative_order_generally_high_first() -> void:
	# Run 20 rounds and verify the highest-initiative unit acts first most often
	var first_count := 0

	for i in range(20):
		seed(i)
		_queue.start_round()
		var first_unit := _queue.get_next_unit()

		if first_unit == _heroes[0]:
			first_count += 1

		# Exhaust remaining turns
		while _queue.get_next_unit() != null:
			pass

	# With 30 initiative vs 20 and 10, the fast hero should go first most of the time
	assert_gt(first_count, 10, "highest initiative unit should act first majority of rounds")
