class_name RunData
extends Resource

@export var player_name: String = "AAA"
@export var score: int = 0
@export var player_level: int = 0
@export var player_xp_collected: int = 0
@export var danger_level: int = 0
@export var time: float = 0.0
@export var enemies_defeated: int = 0
@export var bosses_defeated: int = 0
@export var loop_count: int = 0
@export var difficulty: Difficulty
@export var parts_and_pilot: Array [Unlock]
@export var upgrades: Array[BaseUpgrade]

## Capitalizes and truncates to 3 characters
func set_player_name(name: String) -> void:
	name = name.erase(3, name.length() - 3)
	player_name = name.to_upper()

func print_run_data() -> void:
	print("Player: " + player_name)
	print("Score: " + str(score) + " | Difficulty: " + difficulty.NAME + " | Time: " + get_time_str())
	print("Level: " + str(player_level) + " | Danger Level: " + str(danger_level))
	var part_string = "Parts: "
	for part in parts_and_pilot:
		part_string += part.display_name + " | "
	print(part_string)
	print("----------------")

func get_time_str() -> String:
	var floored_time = floori(time)
	var milliseconds = str(int((time - float(floored_time)) * 100))
	var seconds = str(floored_time % 60)
	var minutes = str(floored_time / 60)
	if milliseconds.length() == 1:
		milliseconds = "0" + milliseconds
	if seconds.length() == 1:
		seconds = "0" + seconds
	if minutes.length() == 1:
		minutes = "0" + minutes
	return minutes + ":" + seconds + "." + milliseconds
