class_name ExtendedMagUpgrade
extends BaseUpgrade

@export var percent_mag_increase: float = 0.5
@export var percent_damage_increase: float = 0.2

func on_add(player: Player):
	var ammo_found = false
	for child in player.turret.get_children():
		if child is AmmoTrackerComponent:
			ammo_found = true
			child.max_ammo += child.starting_max_ammo * percent_mag_increase
			child.add_ammo(child.starting_max_ammo * percent_mag_increase)
	if not ammo_found:
		player.turret.damage += player.turret.base_damage * percent_damage_increase

func on_remove(player: Player):
	var ammo_found = false
	for child in player.turret.get_children():
		if child is AmmoTrackerComponent:
			ammo_found = true
			child.max_ammo -= child.starting_max_ammo * percent_mag_increase
			child.add_ammo(0.0)
	if not ammo_found:
		player.turret.damage -= player.turret.base_damage * percent_damage_increase

func get_description() -> String:
	description = description.replace("$1", str(int(percent_mag_increase * 100)))
	description = description.replace("$2", str(int(percent_damage_increase * 100)))
	return description
