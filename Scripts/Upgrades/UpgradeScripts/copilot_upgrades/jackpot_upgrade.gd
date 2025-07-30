class_name JackpotCopilot
extends BaseUpgrade

var dmg_mult_max: float = 2.0
var crit_mult_max: float = 1.0

func on_fire_add(bullet: ProtoBullet, _player: Player, _is_support: bool = false) -> void:
	bullet.crit_chance += randf_range(-crit_mult_max, crit_mult_max)

func on_fire_mult(bullet: ProtoBullet, _player: Player, _is_support: bool = false) -> void:
	var dmg_mult = randf_range(1.0, 2.0)
	if randi_range(-2, 1) >= 0:
		bullet.damage *= dmg_mult
	else:
		bullet.damage /= dmg_mult
