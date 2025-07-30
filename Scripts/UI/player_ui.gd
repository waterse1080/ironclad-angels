class_name PlayerUI
extends Control

@export var player: Player
@export var wave_spawner: WaveSpawner

var old_boost: float = 999999.0
var score: int = 0
var game_time: float = 0.0

@onready var xp = $LowerLeft/XP as ProgressBar
@onready var xp_anim = $LowerLeft/XP/AnimationPlayer as AnimationPlayer
@onready var level_text = $LowerLeft/Level as Label
@onready var hp = $LowerLeft/HP as ProgressBar
@onready var hp_shaker = $LowerLeft/HP/ShakerComponent as ShakerComponent
@onready var hp_anim = $LowerLeft/HP/AnimationPlayer as AnimationPlayer
@onready var danger_level = $LowerRight/DangerLevel as ProgressBar
@onready var danger_text = $LowerRight/Danger as Label
@onready var ammo_widget = $LowerRight/AmmoWidget as AmmoWidget
@onready var boost = $LowerLeft/Boost as ProgressBar
@onready var boost_shaker = $LowerLeft/Boost/ShakerComponent as ShakerComponent
@onready var boost_anim = $LowerLeft/Boost/AnimationPlayer as AnimationPlayer
@onready var score_label = $UpperLeft/ScoreLabel
@onready var time_label = $UpperLeft/TimeLabel

func start_tracking() -> void:
	SignalBus.ammo_updated.connect(ammo_widget.update_text)
	SignalBus.enemy_destroyed.connect(enemy_destroyed)
	SignalBus.boss_destroyed.connect(boss_destroyed)
	if not player.level_tracker_component:
		await player.ready
	player.level_tracker_component.xp_collected.connect(update_level)
	player.body.health_component.healed.connect(heal)
	player.body.health_component.hurt.connect(hurt)
	player.body.update_boost.connect(update_boost)
	player.body.update_boost_timer.connect(update_boost_timer)
	wave_spawner.danger_timer_updated.connect(update_danger)
	hp_shaker.force_stop_shake()
	if RunDataManager.run_is_active:
		var run_data: RunData = RunDataManager.current_run
		game_time = run_data.time
		score = run_data.score
	update_all_ui(true)

func update_all_ui(_initial := false) -> void:
	update_level(_initial)
	update_health()
	update_danger()
	update_boost()
	update_score()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	game_time += delta
	update_time()

func update_level(_initial := false) -> void:
	xp.max_value = player.level_tracker_component.xp_until_next_level
	xp.value = player.level_tracker_component.current_xp
	level_text.text = "LEVEL: " + str(player.level_tracker_component.current_level)
	if not _initial:
		xp_anim.stop()
		xp_anim.play("Collect")

func hurt(health := 0.0, _crit := false, _blood := false) -> void:
	hp_anim.stop()
	hp_anim.play("Hurt")
	hp_shaker.force_stop_shake()
	hp_shaker.play_shake()
	update_health(health, _crit)

func heal(health := 0.0, _crit := false) -> void:
	hp_anim.stop()
	hp_anim.play("Heal")
	update_health(health, _crit)

func update_health(health := 0.0, _crit := false) -> void:
	hp.max_value = player.body.health_component.max_health
	hp.value = player.body.health_component.health

func update_danger() -> void:
	danger_level.max_value = wave_spawner.DIFFICULTY.WAVE_TIME
	danger_level.value = wave_spawner.danger_timer
	danger_text.text = "Danger: " + str(wave_spawner.DANGER_LEVEL)
	#TODO: Update danger text and fill color to match active wave danger

func update_boost() -> void:
	boost.max_value = player.body.boost_duration_max
	boost.value = player.body.boost_duration_max - player.body.boost_duration
	if boost.modulate == Color(1.0, 1.0, 1.0, 0.5):
		boost_anim.stop()
		boost_anim.play("cooldown")
	if boost.value < old_boost:
		boost_shaker.play_shake()
	old_boost = boost.value

func update_boost_timer() -> void:
	var wait_time = player.body.boost_cooldown_timer.wait_time
	var time_left = player.body.boost_cooldown_timer.time_left
	boost.max_value = wait_time
	boost.value = wait_time - time_left
	boost.modulate = Color(1.0, 1.0, 1.0, 0.5)

func enemy_destroyed(_pos: Vector2 = Vector2.ZERO) -> void:
	score += 10
	update_score()

func boss_destroyed() -> void:
	score += 1000
	update_score()

func update_score() -> void:
	var score_string = str(score)
	for i in 8 - score_string.length():
		score_string = "0" + score_string
	score_label.text = score_string

func update_time() -> void:
	var floored_time = floori(game_time)
	var milliseconds = str(int((game_time - float(floored_time)) * 100))
	var seconds = str(floored_time % 60)
	var minutes = str(floored_time / 60)
	if milliseconds.length() == 1:
		milliseconds = "0" + milliseconds
	if seconds.length() == 1:
		seconds = "0" + seconds
	if minutes.length() == 1:
		minutes = "0" + minutes
	time_label.text = minutes + ":" + seconds + "." + milliseconds
