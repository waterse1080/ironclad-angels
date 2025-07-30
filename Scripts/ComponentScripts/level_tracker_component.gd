class_name LevelTrackerComponent
extends Node

signal xp_collected

@export var next_level_mult := 1.2
@export var level_up_sfx: String

var current_level := 0
var current_xp := 0
var xp_until_next_level := 100
var xp_bonus := 0
var xp_mult := 1.0

func _ready() -> void:
	if RunDataManager.run_is_active:
		var run_data: RunData = RunDataManager.current_run
		current_level = run_data.player_level
		for i in current_level:
			xp_until_next_level = int(float(xp_until_next_level) * next_level_mult)
		current_xp = run_data.player_xp_collected

func collect_xp(xp: int) -> int:
	xp += xp_bonus
	var loop_mult = 0.2 * RunDataManager.current_loop
	xp = ceili(xp * (xp_mult + loop_mult))
	current_xp += xp
	# Allow for multiple level ups to queue
	var times_to_level = 0
	while current_xp >= xp_until_next_level:
		current_level += 1
		times_to_level += 1
		SoundManager.play_sound(level_up_sfx, 1.0, 1.0)
		#print("Level: " + str(current_level))
		current_xp -= xp_until_next_level
		xp_until_next_level = int(float(xp_until_next_level) * next_level_mult)
	if times_to_level > 0:
		SignalBus.level_up.emit(times_to_level)
	xp_collected.emit()
	return xp
