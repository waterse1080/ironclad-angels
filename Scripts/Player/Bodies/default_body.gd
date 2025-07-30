class_name DefaultBody
extends PlayerBody

@export var move_fps: float = 10.0
var current_frame: float = 0.0
@onready var tank_lower: Sprite2D = $TankLower
@onready var treads_1: CPUParticles2D = $TreadMarks
@onready var treads_2: CPUParticles2D = $TreadMarks2
@onready var smoke: SmokeParticles = $BoostSmokeParticles

func extra_input(delta) -> void:
	var modifier = (player.velocity.length() / move_speed) * (move_speed / starting_speed)
	current_frame += delta * move_fps * modifier
	if floori(current_frame) > tank_lower.hframes - 1:
		current_frame = 0
	tank_lower.frame = floori(current_frame)
	if player.velocity.length() < 1:
		treads_1.emitting = false
	else:
		treads_1.emitting = true
	treads_2.emitting = treads_1.emitting
	treads_1.speed_scale = modifier
	treads_2.speed_scale = modifier
	smoke.emitting = is_boosting
