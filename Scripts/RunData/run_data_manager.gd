extends Node

var run_is_active: bool = false
var current_run: RunData
var current_loop: int = 0
var current_rerolls: int = 3

func _ready() -> void:
	new_run()
	SignalBus.enemy_destroyed.connect(_on_enemy_destroyed)
	SignalBus.boss_destroyed.connect(_on_boss_destroyed)

## Called on game start, before player locks in choices
func new_run() -> void:
	current_run = RunData.new()
	current_loop = 0

## Called at game start
func set_run_start_info(parts: Array[Unlock], difficulty: Difficulty) -> void:
	current_run.parts_and_pilot = parts.duplicate()
	current_run.difficulty = difficulty

## Called at game end
func set_run_end_info(
	player_name: String,
	score: int,
	player_level: int,
	player_xp_collected: int,
	danger_level: int,
	time: float,
	upgrades: Array[BaseUpgrade]
	) -> void:
	current_run.set_player_name(player_name)
	current_run.score = score
	current_run.player_level = player_level
	current_run.player_xp_collected = player_xp_collected
	current_run.danger_level = danger_level
	current_run.time = time
	current_run.upgrades = upgrades
	current_run.loop_count = current_loop

## Called at game end after info is collected
func save_run(save: bool = true) -> void:
	SaveDataManager.add_run(current_run, save)

## Tracks total enemies defeated in a run
func _on_enemy_destroyed(_pos: Vector2):
	current_run.enemies_defeated += 1

## Tracks total bosses defeated in a run
func _on_boss_destroyed():
	current_run.bosses_defeated += 1
