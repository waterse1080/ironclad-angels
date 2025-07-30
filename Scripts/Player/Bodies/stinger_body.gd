class_name StingerBody
extends PlayerBody

@onready var smoke: SmokeParticles = $BoostSmokeParticles
@onready var smoke2: SmokeParticles = $BoostSmokeParticles2

func connect_parts(new_turret: PlayerTurret, new_player: Player):
	super.connect_parts(new_turret, new_player)
	player.set_collision_mask_value(5, false)

func extra_input(_delta) -> void:
	smoke.emitting = is_boosting
	smoke2.emitting = is_boosting
