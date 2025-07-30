class_name SettingsMenu
extends Control

@onready var quit_button: Button = $NinePatchRect/MarginContainer/VBoxContainer/QuitButton
@onready var resolution: OptionButton = $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/WindowedResolutionOptionList/Btn
@onready var fullscreen: CheckButton = $NinePatchRect/MarginContainer/VBoxContainer/FullscreenSwitch/Btn
@onready var crt: CheckButton = $NinePatchRect/MarginContainer/VBoxContainer/CRTSwitch/Btn
@onready var crt_res: OptionButton = $NinePatchRect/MarginContainer/VBoxContainer/CRTResolutionContainer/CRTResolutionOptionList/Btn

func _ready() -> void:
	quit_button.pressed.connect(hide_settings)
	fullscreen.toggled.connect(toggle_resolution)
	crt.toggled.connect(toggle_crt_resolution)
	resolution.disabled = fullscreen.button_pressed
	crt_res.disabled = not crt.button_pressed

func _process(delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		call_deferred("hide_settings")

func gain_focus() -> void:
	quit_button.grab_focus()
	
	for child in get_all_children(self):
		if child.has_method("init_value"):
			child.init_value()

func hide_settings() -> void:
	visible = false

func toggle_resolution(value: bool) -> void:
	resolution.disabled = value

func toggle_crt_resolution(value: bool) -> void:
	crt_res.disabled = not value

func get_all_children(in_node, arr := []):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child, arr)
	return arr
