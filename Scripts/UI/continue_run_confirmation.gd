class_name ContinueRunConfirmation
extends Control

@export var pause_manager: PauseManager
@export var wave_spawner: WaveSpawner
@export var player_ui: PlayerUI
@export var game_over_menu: GameOverMenu
@export var upgrade_menu: UpgradeMenu

@onready var continue_btn: Button = $HBoxContainer/Continue
@onready var end_run_btn: Button = $HBoxContainer/EndRun
@onready var loop_text: LabelAutoSizer = $LoopText

func _ready() -> void:
	SignalBus.area_cleared.connect(on_objectives_complete)
	continue_btn.pressed.connect(on_continue)
	end_run_btn.pressed.connect(on_end_run)
	visible = false

func on_objectives_complete() -> void:
	#TODO animate, remove animation from game over menu
	var player: Player = get_tree().get_first_node_in_group("player")
	for pickup in get_tree().get_nodes_in_group("pickup"):
		if pickup.has_node("TweenComponent"):
			if pickup is not XpPickup:
				continue
			else:
				pickup.tween_component.bounce = false
				pickup.tween_component.target = player
				pickup.trail.process_mode = Node.PROCESS_MODE_INHERIT
	var timer = get_tree().create_timer(2.0, false)
	await timer.timeout

	visible = true
	continue_btn.grab_focus()
	loop_text.text = "AREAS CLEARED: " + str(RunDataManager.current_loop + 1)
	get_tree().set_deferred("paused", true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_manager.CAN_TOGGLE_PAUSE = false

	RunDataManager.current_rerolls = upgrade_menu.rerolls
	RunDataManager.set_run_end_info(
		"-->",
		player_ui.score,
		player.level_tracker_component.current_level,
		player.level_tracker_component.current_xp,
		wave_spawner.DANGER_LEVEL,
		player_ui.game_time,
		player.upgrades
		)

func on_continue() -> void:
	game_over_menu.retry()
	RunDataManager.current_loop += 1

func on_end_run() -> void:
	game_over_menu.mission_complete()
	visible = false
