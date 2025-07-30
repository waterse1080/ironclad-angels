extends Camera2D
class_name PlayerCamera

@export var randomStrength := 30.0
@export var shakeFade := 5.0

@onready var screenshake_intensity_setting = preload("res://game_settings/setting_screenshake_intensity.tres")

var rng = RandomNumberGenerator.new()
var shake_strength := 0.0

func apply_shake(shakeAmt := randomStrength):
	shake_strength = shakeAmt * GGS.get_value(screenshake_intensity_setting) / 50.0
	#print(GGS.get_value(screenshake_intensity_setting))

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
