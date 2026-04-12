extends GutTest

## Tests for FormationUtils — pure static slot math.


# -- assign_formation --

func test_assign_formation_mixed_preferences() -> void:
	var result := FormationUtils.assign_formation(["front", "back", "front", "back"])

	assert_eq(result[0].row, "front")
	assert_eq(result[0].slot, 0)
	assert_eq(result[1].row, "back")
	assert_eq(result[1].slot, 0)
	assert_eq(result[2].row, "front")
	assert_eq(result[2].slot, 1)
	assert_eq(result[3].row, "back")
	assert_eq(result[3].slot, 1)


func test_assign_formation_all_prefer_front() -> void:
	var result := FormationUtils.assign_formation(["front", "front", "front", "front"])

	# First two get front, rest overflow to back
	assert_eq(result[0].row, "front")
	assert_eq(result[1].row, "front")
	assert_eq(result[2].row, "back")
	assert_eq(result[3].row, "back")


func test_assign_formation_all_prefer_back() -> void:
	var result := FormationUtils.assign_formation(["back", "back", "back", "back"])

	# First two get back, rest overflow to front
	assert_eq(result[0].row, "back")
	assert_eq(result[1].row, "back")
	assert_eq(result[2].row, "front")
	assert_eq(result[3].row, "front")


func test_assign_formation_single_unit() -> void:
	var result := FormationUtils.assign_formation(["front"])

	assert_eq(result.size(), 1)
	assert_eq(result[0].row, "front")
	assert_eq(result[0].slot, 0)


func test_assign_formation_two_units() -> void:
	var result := FormationUtils.assign_formation(["front", "back"])

	assert_eq(result.size(), 2)
	assert_eq(result[0].row, "front")
	assert_eq(result[0].slot, 0)
	assert_eq(result[1].row, "back")
	assert_eq(result[1].slot, 0)


func test_assign_formation_empty() -> void:
	var result := FormationUtils.assign_formation([])

	assert_eq(result.size(), 0)


# -- hero_slot_index --

func test_hero_slot_index_front_0() -> void:
	assert_eq(FormationUtils.hero_slot_index("front", 0), 3)


func test_hero_slot_index_front_1() -> void:
	assert_eq(FormationUtils.hero_slot_index("front", 1), 2)


func test_hero_slot_index_back_0() -> void:
	assert_eq(FormationUtils.hero_slot_index("back", 0), 1)


func test_hero_slot_index_back_1() -> void:
	assert_eq(FormationUtils.hero_slot_index("back", 1), 0)


# -- monster_slot_index --

func test_monster_slot_index_front_0() -> void:
	assert_eq(FormationUtils.monster_slot_index("front", 0), 0)


func test_monster_slot_index_front_1() -> void:
	assert_eq(FormationUtils.monster_slot_index("front", 1), 1)


func test_monster_slot_index_back_0() -> void:
	assert_eq(FormationUtils.monster_slot_index("back", 0), 2)


func test_monster_slot_index_back_1() -> void:
	assert_eq(FormationUtils.monster_slot_index("back", 1), 3)
