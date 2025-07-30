class_name MainMenu
extends Node2D

@export var speed: float = 2.0

var parallax_parts: Array[Parallax2D] = []

@onready var parallax_parent: Node2D = $CanvasLayer/ParallaxControl/ParallaxBG

@onready var play_button: Button = $CanvasLayer/Panel/MarginContainer/VBoxContainer/PlayButton
@onready var tutorial_button: Button = $CanvasLayer/Panel/MarginContainer/VBoxContainer/HowToPlayButton
@onready var scoreboard_button: Button = $CanvasLayer/Panel/MarginContainer/VBoxContainer/ScoreboardButton
@onready var settings_button: Button = $CanvasLayer/Panel/MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CanvasLayer/Panel/MarginContainer/VBoxContainer/QuitButton

@onready var itch_button: Button = $CanvasLayer/Socials/Itch
@onready var bluesky_button: Button = $CanvasLayer/Socials/Bluesky

@onready var main_menu_container: Panel = $CanvasLayer/Panel
@onready var settings_menu: SettingsMenu = $CanvasLayer/SettingsMenu
@onready var how_to_play_screen: HowToPlayScreen = $CanvasLayer/HowToPlayScreen
@onready var version_label: LabelAutoSizer = $CanvasLayer/VersionLabel

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var update_text: RichLabelAutoSizer = $CanvasLayer/UpdateText

func _ready() -> void:
	for child in parallax_parent.get_children():
		parallax_parts.append(child)
	play_button.pressed.connect(play_game)
	tutorial_button.pressed.connect(open_tutorial)
	scoreboard_button.pressed.connect(open_scoreboard)
	settings_button.pressed.connect(open_settings)
	quit_button.pressed.connect(quit)

	itch_button.pressed.connect(web_nav_itch)
	bluesky_button.pressed.connect(web_nav_bluesky)

	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_effect_enabled(index, 0, false)

	if MusicManager.current_song != MusicManager.SONGLIST.MAIN_MENU:
		MusicManager.play_music(MusicManager.SONGLIST.MAIN_MENU)

	play_button.grab_focus()
	settings_menu.visibility_changed.connect(settings_vis_changed)
	how_to_play_screen.visibility_changed.connect(how_to_play_vis_changed)

	version_label.text = ProjectSettings.get_setting("application/config/version")
	http_request.request_completed.connect(_on_request_completed)
	match OS.get_name():
		"Windows":
			http_request.request("https://itch.io/api/1/x/wharf/latest?target=eliot-waters/ironclad-angels&channel_name=windows")
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			http_request.request("https://itch.io/api/1/x/wharf/latest?target=eliot-waters/ironclad-angels&channel_name=linux")

func settings_vis_changed() -> void:
	main_menu_container.visible = not settings_menu.visible
	if not settings_menu.visible:
		play_button.grab_focus()

func how_to_play_vis_changed() -> void:
	main_menu_container.visible = not how_to_play_screen.visible
	if not how_to_play_screen.visible:
		play_button.grab_focus()

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	for pp in parallax_parts:
		#pp.scroll_offset = -mouse_pos * pp.scroll_scale
		var scroll_pos = -mouse_pos * pp.scroll_scale
		pp.scroll_offset.x = lerpf(pp.scroll_offset.x, scroll_pos.x, speed * delta)
		pp.scroll_offset.y = lerpf(pp.scroll_offset.y, scroll_pos.y, speed * delta)

func play_game() -> void:
	play_button.disabled = true
	tutorial_button.disabled = true
	scoreboard_button.disabled = true
	settings_button.disabled = true
	quit_button.disabled = true
	SceneManager.change_scene("res://Scenes/game_scene.tscn", {
		"pattern": "squares",
		"invert_on_leave": true
	})

func open_tutorial() -> void:
	how_to_play_screen.visible = true
	how_to_play_screen.gain_focus()

func open_scoreboard() -> void:
	pass

func open_settings() -> void:
	settings_menu.visible = true
	settings_menu.gain_focus()

func web_nav_itch() -> void:
	OS.shell_open("https://eliot-waters.itch.io/ironclad-angels")

func web_nav_bluesky() -> void:
	OS.shell_open("https://bsky.app/profile/eliotw.bsky.social")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json["latest"] == "<null>":
		print("Failed to get latest")
		return
	update_text.text = update_text.text.replace("$", json["latest"])
	if ProjectSettings.get_setting("application/config/version") != json["latest"]:
		update_text.visible = true

func quit() -> void:
	get_tree().quit()
