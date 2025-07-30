class_name WaveSpawner
extends Node

signal danger_timer_updated

@export var DIFFICULTY: Difficulty
@export var DANGER_WAVES: Array[WaveList]
@export var SPAWN_DISTANCE := 1500
@export var DANGER_LEVEL := 0

var active_wave: Wave
var active_wave_list: WaveList

var danger_timer := 0.0
var wave_timer := 0.0
var std_timer := 0.0
var rare_timer := 0.0
var boss_spawn_trackers: Dictionary = {} ## (EnemyStash.ENEMIES, int)
var boss_spawn_counts: Dictionary = {} ## (EnemyStash.ENEMIES, int)
var objective_complete_flag: bool = false

@onready var player = $"../Player" #TODO need a better way later

func _ready():
	SignalBus.boss_spawn_progress.connect(add_boss_spawn_mod)
	SignalBus.objectives_complete.connect(on_objectives_complete)
	var danger_time_current: float = danger_timer
	if RunDataManager.run_is_active:
		var run_data: RunData = RunDataManager.current_run
		DANGER_LEVEL = run_data.danger_level
		danger_time_current = int(run_data.time) % run_data.difficulty.WAVE_TIME
	swap_danger(true)
	danger_timer = danger_time_current

func _process(delta):
	danger_timer += delta
	wave_timer += delta
	std_timer += delta
	rare_timer += delta

	if danger_timer >= DIFFICULTY.WAVE_TIME:
		swap_danger()
		return
	if wave_timer >= active_wave.TOTAL_WAVE_TIME:
		reset_timers([danger_timer, 0.0, 0.0, 0.0])
		swap_wave()
		return
	if std_timer >= active_wave.STANDARD_SPAWN_TIMER:
		spawn_standard_enemies()
	if rare_timer >= active_wave.RARE_SPAWN_TIMER:
		spawn_rare_enemies()
	danger_timer_updated.emit()

func _physics_process(delta: float) -> void:
	if objective_complete_flag:
		call_deferred("game_over_check")

# Swap wavelist, or increase stats if at max danger level
func swap_danger(initial := false):
	if not initial:
		DANGER_LEVEL += 1
	print("Danger Level: " + str(DANGER_LEVEL))
	reset_timers([0.0, 0.0, 0.0, 0.0])
	if DANGER_LEVEL <= DANGER_WAVES.size() - 1:
		active_wave_list = DANGER_WAVES[DANGER_LEVEL]
	else:
		active_wave_list = DANGER_WAVES.back()
		print("max danger level already achieved, increasing by other means...")
		#Increase stats
		for wave in active_wave_list.WAVES:
			wave.INITIAL_DAMAGE_MULT += 0.1
			wave.INITIAL_HEALTH_MULT += 0.5
			wave.INITIAL_SPAWN_COUNT += 1

			wave.STANDARD_DAMAGE_MULT += 0.1
			wave.STANDARD_HEALTH_MULT += 0.5
			wave.STANDARD_SPAWN_TIMER *= 0.8

			wave.RARE_DAMAGE_MULT += 0.1
			wave.RARE_HEALTH_MULT += 0.5
			wave.RARE_SPAWN_TIMER *= 0.8

	swap_wave()

func swap_wave():
	var new_wave = active_wave_list.WAVES.pick_random()
	if active_wave_list.WAVES.size() > 1:
		while new_wave == active_wave:
			new_wave = active_wave_list.WAVES.pick_random()
	active_wave = new_wave
	spawn_initial_enemies()

func reset_timers(given_timers: Array[float]):
	danger_timer = given_timers[0]
	wave_timer = given_timers[1]
	std_timer = given_timers[2]
	rare_timer = given_timers[3]

func spawn_standard_enemies():
	#print("STD")
	spawn_enemies(
		active_wave.STANDARD,
		active_wave.STANDARD_HEALTH_MULT,
		active_wave.STANDARD_DAMAGE_MULT,
		active_wave.STANDARD_SPEED_MULT,
		active_wave.STANDARD_SCALE_MULT,
		active_wave.STANDARD_SPAWN_COUNT
	)
	std_timer = 0.0

func spawn_rare_enemies():
	#print("RARE")
	spawn_enemies(
		active_wave.RARE,
		active_wave.RARE_HEALTH_MULT,
		active_wave.RARE_DAMAGE_MULT,
		active_wave.RARE_SPEED_MULT,
		active_wave.RARE_SCALE_MULT,
		active_wave.RARE_SPAWN_COUNT
	)
	rare_timer = 0.0

func spawn_initial_enemies():
	#print("INIT")
	spawn_enemies(
		active_wave.INITIAL,
		active_wave.INITIAL_HEALTH_MULT,
		active_wave.INITIAL_DAMAGE_MULT,
		active_wave.INITIAL_SPEED_MULT,
		active_wave.INITIAL_SCALE_MULT,
		active_wave.INITIAL_SPAWN_COUNT
	)
	std_timer -= active_wave.INITIAL_SPAWN_TIMER_DELAY
	rare_timer -= active_wave.INITIAL_SPAWN_TIMER_DELAY

func spawn_enemies(enemies: Array[EnemyStash.ENEMIES], health_mod: float, dmg_mod: float, speed_mod: float, scale_mod: float, spawn_count := 1) -> void:
	if objective_complete_flag:
		return
	if player == null:
		return
	if enemies.size() == 0:
		return
	var enemy = enemies.pick_random()
	for i in spawn_count:
		var enemy_scene = EnemyStash.load_enemy_scene(enemy)
		var new_enemy: ProtoEnemy = enemy_scene.instantiate()
		new_enemy.HEALTH_MOD = health_mod
		new_enemy.DAMAGE *= dmg_mod
		new_enemy.SPEED *= speed_mod
		new_enemy.scale *= scale_mod
		var player_pos = player.get_position()
		var spawn_pos = player_pos + Vector2.from_angle(randf_range(0, 2 * PI)) * SPAWN_DISTANCE
		new_enemy.set_position(spawn_pos)
		self.add_sibling.call_deferred(new_enemy)
		#enemyList.push_back(new_enemy)

func add_boss_spawn_mod(boss: EnemyStash.ENEMIES, progress_mod: int) -> void:
	if not boss_spawn_trackers.has(boss):
		boss_spawn_trackers[boss] = 0
	boss_spawn_trackers[boss] += progress_mod
	if boss_spawn_trackers[boss] >= 100:
		if not boss_spawn_counts.has(boss):
			boss_spawn_counts[boss] = 0
		else:
			boss_spawn_counts[boss] += 1
		var count_mult = float(boss_spawn_counts[boss] + RunDataManager.current_loop)
		spawn_enemies(
			[boss],
			active_wave.STANDARD_HEALTH_MULT + count_mult * 0.5,
			active_wave.STANDARD_DAMAGE_MULT + count_mult * 0.1,
			active_wave.STANDARD_SPEED_MULT + count_mult * 0.2,
			1.0,
			1
		)
		boss_spawn_trackers[boss] = 0

func on_objectives_complete() -> void:
	objective_complete_flag = true
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() <= 0:
		SignalBus.area_cleared.emit()
		return
	for enemy in enemies:
		SignalBus.add_objective_marker.emit(enemy)

func game_over_check() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() <= 0:
		SignalBus.area_cleared.emit()
