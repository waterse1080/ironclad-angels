class_name LightTankBody
extends PlayerBody

@onready var treads_1: CPUParticles2D = $TreadMarks
@onready var treads_2: CPUParticles2D = $TreadMarks2
@onready var treads_3: CPUParticles2D = $TreadMarks3
@onready var treads_4: CPUParticles2D = $TreadMarks4
@onready var smoke: SmokeParticles = $BoostSmokeParticles
@onready var smoke2: SmokeParticles = $BoostSmokeParticles2

func extra_input(_delta) -> void:
	var modifier = (player.velocity.length() / move_speed) * (move_speed / starting_speed)

	if player.velocity.length() < 1:
		treads_1.emitting = false
	else:
		treads_1.emitting = true

	treads_2.emitting = treads_1.emitting
	treads_3.emitting = treads_1.emitting
	treads_4.emitting = treads_1.emitting
	treads_1.speed_scale = modifier
	treads_2.speed_scale = modifier
	treads_3.speed_scale = modifier
	treads_4.speed_scale = modifier

	smoke.emitting = is_boosting
	smoke2.emitting = is_boosting
	can_destroy_terrain = is_boosting
