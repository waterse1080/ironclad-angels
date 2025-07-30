class_name PauseMenu
extends Control

@onready var resume_button: Button = $Panel/MarginContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/MarginContainer/VBoxContainer/SettingsButton
@onready var tutorial_button: Button = $Panel/MarginContainer/VBoxContainer/TutorialButton
@onready var restart_button: Button = $Panel/MarginContainer/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $Panel/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $Panel/MarginContainer/VBoxContainer/QuitButton

@onready var settings_menu: SettingsMenu = $SettingsMenu
@onready var how_to_play_screen: HowToPlayScreen = $HowToPlayScreen
@onready var panel: Panel = $Panel
@onready var upgrade_list: UpgradeDisplayList = $UpgradeDisplayList

signal resume_pressed

func _ready() -> void:
	settings_menu.visibility_changed.connect(settings_vis_changed)
	how_to_play_screen.visibility_changed.connect(how_to_play_vis_changed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func settings_vis_changed() -> void:
	panel.visible = not settings_menu.visible
	upgrade_list.visible = panel.visible
	if not settings_menu.visible:
		resume_button.grab_focus()

func how_to_play_vis_changed() -> void:
	panel.visible = not how_to_play_screen.visible
	upgrade_list.visible = panel.visible
	if not how_to_play_screen.visible:
		resume_button.grab_focus()

func _on_resume_button_pressed():
	resume_pressed.emit()

func _on_settings_button_pressed() -> void:
	settings_menu.visible = true
	settings_menu.gain_focus()

func _on_tutorial_button_pressed() -> void:
	how_to_play_screen.visible = true
	how_to_play_screen.gain_focus()

func _on_restart_button_pressed():
	reset_upgrades()
	RunDataManager.run_is_active = false
	SceneManager.reload_scene({
		"pattern": "squares",
		"invert_on_leave": true
	})

func _on_main_menu_button_pressed():
	reset_upgrades()
	RunDataManager.run_is_active = false
	SceneManager.change_scene("res://Scenes/main_menu.tscn", {
		"pattern": "squares",
		"invert_on_leave": true
	})

func reset_upgrades() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		for upgrade in player.upgrades:
			upgrade.upgrade_copies_count = 0

func _on_quit_button_pressed():
	get_tree().quit()
