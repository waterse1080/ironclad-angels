class_name FubarUpgrade
extends BaseUpgrade

var dmg_mult: float = 3.0
var new_max_health = 1.0

func on_add(player: Player) -> void:
	player.body.health_component.change_max_health(new_max_health)
	player.body.health_component.can_change_max_health = false
	player.turret.damage *= dmg_mult

func on_remove(player: Player) -> void:
	player.body.health_component.can_change_max_health = true
	player.turret.damage /= dmg_mult
