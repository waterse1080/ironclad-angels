extends BaseUpgrade
class_name CritBulletUpgrade

@export var CRIT_CHANCE_INCREASE := 0.33
@export var CRIT_MULT_INCREASE := 0.5

func on_fire_add(bullet: ProtoBullet, _player: Player, _is_support: bool = false):
	bullet.crit_chance += CRIT_CHANCE_INCREASE
	bullet.crit_mult += CRIT_MULT_INCREASE

func get_description() -> String:
	description = description.replace("$1", str(int(CRIT_CHANCE_INCREASE * 100)))
	description = description.replace("$2", str(int(CRIT_MULT_INCREASE * 100)))
	return description
