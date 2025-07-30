class_name GameOverMenu
extends Control

@export var pause_manager: PauseManager
@export var wave_spawner: WaveSpawner
@export var player_ui: PlayerUI

@onready var retry_button: Button = $ButtonContainer/RetryButton
@onready var quit_button: Button = $ButtonContainer/QuitButton
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var game_over_label: LabelAutoSizer = $MainText
@onready var research_points_label: LabelAutoSizer = $PointsEarned
@onready var upgrade_list: UpgradeDisplayList = $UpgradeDisplayList

var cam: Camera2D

func _ready() -> void:
	SignalBus.game_over.connect(tween_in)
	retry_button.pressed.connect(retry)
	quit_button.pressed.connect(quit)

func tween_in(new_cam: Camera2D, player_level: int, upgrades: Array[BaseUpgrade]) -> void:
	anim_player.play("tween_in")
	get_tree().set_deferred("paused", true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_manager.CAN_TOGGLE_PAUSE = false
	#var index = AudioServer.get_bus_index("Music")
	#AudioServer.set_bus_effect_enabled(index, 0, true)
	MusicManager.play_music(MusicManager.SONGLIST.GAME_OVER)
	cam = new_cam
	upgrade_list.update_upgrades(upgrades)

	#TODO TEMP
	var points_earned: int = ceili(float(player_ui.score) * wave_spawner.DIFFICULTY.rp_mult)
	SaveDataManager.save_data.research_points += points_earned
	research_points_label.text = "Research Points: " + str(points_earned)

	#TODO TEMP
	RunDataManager.set_run_end_info(
		"LLL",
		player_ui.score,
		player_level,
		0, #cludge, should be collected xp but is only needed for continuing runs
		wave_spawner.DANGER_LEVEL,
		player_ui.game_time,
		upgrades
		)
	RunDataManager.save_run()
	RunDataManager.run_is_active = false

func mission_complete() -> void:
	game_over_label.text = "MISSION COMPLETE!"
	retry_button.text = "PLAY AGAIN"
	anim_player.play("tween_in")
	get_tree().set_deferred("paused", true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_manager.CAN_TOGGLE_PAUSE = false
	MusicManager.play_music(MusicManager.SONGLIST.MISSION_COMPLETE)
	var player: Player = get_tree().get_first_node_in_group("player")
	upgrade_list.update_upgrades(player.upgrades)

	#TODO TEMP
	var points_earned: int = ceili(float(1000 + player_ui.score) * wave_spawner.DIFFICULTY.rp_mult)
	SaveDataManager.save_data.research_points += points_earned
	research_points_label.text = "Research Points: " + str(points_earned)

	#TODO TEMP
	RunDataManager.set_run_end_info(
		"WWW",
		player_ui.score,
		player.level_tracker_component.current_level,
		player.level_tracker_component.current_xp,
		wave_spawner.DANGER_LEVEL,
		player_ui.game_time,
		player.upgrades
		)
	RunDataManager.save_run()
	RunDataManager.run_is_active = false

func retry() -> void:
	var player = player_ui.player
	if is_instance_valid(player):
		for upgrade in player.upgrades:
			upgrade.upgrade_copies_count = 0
	var tree = get_tree()
	if tree:
		if cam != null:
			cam.call_deferred("queue_free")
		SignalBus.level_cleanup.emit()
		SceneManager.call_deferred("reload_scene", {
			"pattern": "squares",
			"invert_on_leave": true
		})

func quit() -> void:
	var tree = get_tree()
	if tree:
		tree.quit()

func enable_buttons() -> void:
	retry_button.disabled = false
	quit_button.disabled = false

func gain_focus() -> void:
	retry_button.grab_focus()
