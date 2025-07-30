class_name CRTRect
extends ColorRect

@onready var crt_toggle_setting = preload("res://game_settings/setting_toggle_crt.tres")
@onready var crt_mult_setting = preload("res://game_settings/setting_select_crt_multiplier.tres")


func _ready() -> void:
	GGS.setting_applied.connect(get_setting_signal)
	var crt_toggle = GGS.get_value(crt_toggle_setting)
	var crt_index = GGS.get_value(crt_mult_setting)
	if crt_toggle == null:
		print("ERROR: crt_toggle null, setting to true")
		crt_toggle = true
	if crt_index == null or crt_index > crt_mult_setting.scales.size() - 1:
		print("ERROR: crt_index out of scope, setting to 0: " + str(crt_index))
		crt_index = 0
	visible = crt_toggle
	get_tree().get_root().size_changed.connect(resize)
	resize()

func resize() -> void:
	var crt_index = GGS.get_value(crt_mult_setting)
	if crt_index == null or crt_index > crt_mult_setting.scales.size() - 1:
		print("ERROR: crt_index out of scope, setting to 0: " + str(crt_index))
		crt_index = 0
	var full_res = DisplayServer.screen_get_size()
	var mult = crt_mult_setting.scales[crt_index]
	#print(mult)
	material.set_shader_parameter("resolution", full_res / mult)

func get_setting_signal(key: String, value) -> void:
	if key == "toggle_crt" and value is bool:
		visible = value
	elif key == "select_crt_multiplier":
		resize()
