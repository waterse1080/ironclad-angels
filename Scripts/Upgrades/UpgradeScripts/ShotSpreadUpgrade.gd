extends BaseUpgrade
class_name ShotSpreadUpgrade

@export var SHOT_COUNT := 1
@export var SHOT_SPREAD := 5.0
@export var DAMAGE_MULT := 1.0

func on_add(player: Player):
	player.turret.bullet_split_count += SHOT_COUNT
	player.turret.bullet_spread_angle += SHOT_SPREAD
	#for child in player.turret.get_children():
		#if child is AmmoTrackerComponent:
			#child.current_ammo_per_shot += child.ammo_per_shot

func on_fire_mult(bullet: ProtoBullet, _player: Player, _is_support: bool = false):
	bullet.damage *= DAMAGE_MULT

func on_remove(player: Player):
	player.turret.bullet_split_count -= SHOT_COUNT
	player.turret.bullet_spread_angle -= SHOT_SPREAD
	#for child in player.turret.get_children():
		#if child is AmmoTrackerComponent:
			#child.current_ammo_per_shot -= child.ammo_per_shot

func get_description() -> String:
	description = description.replace("$1", str(int(SHOT_COUNT)))
	description = description.replace("$2", str(int((1.0-DAMAGE_MULT) * 100)))
	return description
