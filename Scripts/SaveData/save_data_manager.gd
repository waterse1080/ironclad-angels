# global class name: SaveDataManager
extends Node

## Emmitted on save_data modification
signal save_updated
## Emmitted on save_data being commited to memory
signal saved

## Should not be modified directly
var save_data: SaveData

func _ready() -> void:
	save_data = SaveData.load_or_create()
	print("---Prior Runs---")
	for run in save_data.run_list:
		run.print_run_data()
	print("Research Points: " + str(save_data.research_points))

## Called by other functions when modifying save_data
func _update_save(save: bool = true) -> void:
	save_updated.emit()
	print("save_data updated")
	if save:
		save()

## Check if part is already unlocked
func is_part_unlocked(part: Unlock) -> bool:
	for unlock in save_data.unlocked_parts:
		if unlock.display_name == part.display_name:
			return true 
	return false

## Unlock new parts for the player to use
func unlock_parts(new_parts: Array[Unlock], save: bool = true) -> void:
	# TODO prevent duplicates
	save_data.unlocked_parts.append_array(new_parts.duplicate())
	_update_save(save)

## Add or subtract research points [br]
## Cannot go negative
func modify_research_points(mod: int, save: bool = true) -> bool:
	if save_data.research_points + mod >= 0:
		save_data.research_points += mod
		_update_save(save)
		return true
	return false

## Commit the given run to save_data
func add_run(run: RunData, save: bool = true) -> void:
	save_data.run_list.append(run)
	_update_save(save)

## Commit save_data changes to memory
func save() -> void:
	save_data.save()
	print("save_data saved")
	saved.emit()

func set_last_used_parts(parts: Array[Unlock]) -> void:
	if parts.size() != 3:
		push_warning("Incorrect number of parts: " + str(parts.size()))
	save_data.last_used_parts = parts.duplicate()

func get_last_used_parts() -> Array[Unlock]:
	return save_data.last_used_parts

func set_last_difficulty(difficulty: Difficulty) -> void:
	save_data.last_difficulty = difficulty.duplicate()

func get_last_difficulty() -> Difficulty:
	return save_data.last_difficulty
