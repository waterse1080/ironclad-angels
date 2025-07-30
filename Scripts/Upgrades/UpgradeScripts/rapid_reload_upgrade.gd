class_name RapidReloadUpgrade
extends BaseUpgrade

@export var reload_speed_multiplier: float = 0.9
@export var fire_rate_multiplier: float = 0.9

func on_add(player: Player):
	var ammo_found = false
	for child in player.turret.get_children():
		if child is AmmoTrackerComponent:
			ammo_found = true
			child.reload_time *= reload_speed_multiplier
			child.recharge_rate /= reload_speed_multiplier
			child.recharge_cooldown *= reload_speed_multiplier
	if not ammo_found:
		player.turret.load_time *= fire_rate_multiplier

func on_remove(player: Player):
	var ammo_found = false
	for child in player.turret.get_children():
		if child is AmmoTrackerComponent:
			ammo_found = true
			child.reload_time /= reload_speed_multiplier
			child.recharge_rate *= reload_speed_multiplier
			child.recharge_cooldown /= reload_speed_multiplier
	if not ammo_found:
		player.turret.load_time /= fire_rate_multiplier

func get_description() -> String:
	description = description.replace("$1", str(int((1-reload_speed_multiplier) * 100)))
	description = description.replace("$2", str(int((1-fire_rate_multiplier) * 100)))
	return description
