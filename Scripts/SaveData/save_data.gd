class_name SaveData
extends Resource

const SAVE_PATH: String = "user://ironclad_angels_save_data.tres"
const DEFAULT_SAVE_PATH: String = "res://Scripts/SaveData/default_save.tres"

@export var unlocked_parts: Array[Unlock] = []
@export var last_used_parts: Array[Unlock] = []
@export var last_difficulty: Difficulty
@export var research_points: int = 0
@export var run_list: Array[RunData] = []

func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func load_or_create() -> SaveData:
	var data: SaveData
	if FileAccess.file_exists(SAVE_PATH):
		# https://forum.godotengine.org/t/how-to-save-nested-resources/43614
		data = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		var default = ResourceLoader.load(DEFAULT_SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
		data = default.duplicate(true)
	return data

func get_high_score() -> RunData:
	var highest: RunData
	for run in run_list:
		if highest == null:
			highest = run
		elif run.score > highest.score:
			highest = run
	return highest
