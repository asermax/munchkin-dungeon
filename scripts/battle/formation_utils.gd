class_name FormationUtils
extends RefCounted

## Static utilities for formation assignment and slot indexing.
## Shared by BattleManager, PartyView, and BattleUI.

const MAX_PER_ROW: int = 2


static func assign_formation(preferred_rows: Array) -> Array[Dictionary]:
	## Given an array of preferred row strings ("front"/"back"), returns
	## [{row: String, slot: int}] with overflow when a row is full.
	var front_count := 0
	var back_count := 0
	var result: Array[Dictionary] = []

	for preferred: String in preferred_rows:
		var assigned_row: String
		var assigned_slot: int

		if preferred == "front" and front_count < MAX_PER_ROW:
			assigned_row = "front"
			assigned_slot = front_count
			front_count += 1
		elif preferred == "back" and back_count < MAX_PER_ROW:
			assigned_row = "back"
			assigned_slot = back_count
			back_count += 1
		elif front_count < MAX_PER_ROW:
			assigned_row = "front"
			assigned_slot = front_count
			front_count += 1
		else:
			assigned_row = "back"
			assigned_slot = back_count
			back_count += 1

		result.append({"row": assigned_row, "slot": assigned_slot})

	return result


static func hero_slot_index(row: String, slot: int) -> int:
	## Heroes: [back_1, back_0, front_1, front_0] — back on far left, front_0 rightmost (near enemies)
	if row == "front":
		return 3 - slot

	return 1 - slot


static func monster_slot_index(row: String, slot: int) -> int:
	## Monsters: [front_0, front_1, back_0, back_1] — front row on the left
	if row == "front":
		return slot

	return 2 + slot
