class_name EncounterPool
extends RefCounted

## Loads and categorizes encounters by difficulty for a given biome.
## Usage:
##   var pool := EncounterPool.new()
##   pool.load_biome("cave")
##   var enc: EncounterData = pool.pick("easy")

var _pools: Dictionary = {}  # difficulty -> Array[EncounterData]


func load_biome(biome: String) -> void:
	_pools.clear()
	_pools["easy"] = []
	_pools["medium"] = []
	_pools["hard"] = []
	_pools["boss"] = []

	var dir_path := "res://data/encounters/%s" % biome
	var dir := DirAccess.open(dir_path)

	if dir == null:
		push_error("EncounterPool: could not open %s" % dir_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
			# In exported builds, resources are stored as .tres.remap
			var clean_name := file_name.replace(".remap", "")
			var full_path := "%s/%s" % [dir_path, clean_name]
			var encounter: EncounterData = load(full_path)

			if encounter != null and encounter.difficulty in _pools:
				_pools[encounter.difficulty].append(encounter)

		file_name = dir.get_next()

	dir.list_dir_end()


func pick(difficulty: String) -> EncounterData:
	var pool: Array = _pools.get(difficulty, [])

	if pool.is_empty():
		push_warning("EncounterPool: no encounters for difficulty '%s'" % difficulty)
		return null

	return pool.pick_random()


func pick_boss() -> EncounterData:
	return pick("boss")


func has_encounters(difficulty: String) -> bool:
	var pool: Array = _pools.get(difficulty, [])
	return not pool.is_empty()
