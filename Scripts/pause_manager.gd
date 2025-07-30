extends Node
class_name PauseManager

@export var CAN_TOGGLE_PAUSE := true
@export var PAUSE_MENU: PauseMenu

func _ready():
	get_tree().paused = false
	if PAUSE_MENU:
		PAUSE_MENU.resume_pressed.connect(resume)
		PAUSE_MENU.visible = false
	#TODO listen for upgrade menu to avoid overlapping pauses

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if CAN_TOGGLE_PAUSE and not PAUSE_MENU.settings_menu.visible:
			toggle_pause()

func toggle_pause():
	if get_tree().paused:
		resume()
	else:
		pause()

func pause(show_menu := true):
	if CAN_TOGGLE_PAUSE:
		get_tree().set_deferred("paused", true)	
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if show_menu and PAUSE_MENU != null:
			PAUSE_MENU.visible = true
			PAUSE_MENU.resume_button.grab_focus()
			var player: Player = get_tree().get_first_node_in_group("player")
			if player:
				PAUSE_MENU.upgrade_list.update_upgrades(player.upgrades)
		var index = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_effect_enabled(index, 0, true)

func resume():
	if CAN_TOGGLE_PAUSE:
		get_tree().set_deferred("paused", false)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if PAUSE_MENU != null:
			PAUSE_MENU.visible = false
		var index = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_effect_enabled(index, 0, false)
