extends BaseUpgrade
class_name MuleKickUpgrade

@export var KNOCKBACK_INCREASE := 0.5
@export var BASE_DMG_INCREASE := 0.2

func on_fire_add(bullet: ProtoBullet, _player: Player, _is_support: bool = false):
	bullet.damage += bullet.DAMAGE * BASE_DMG_INCREASE
	bullet.knockback += bullet.KNOCKBACK_POWER * KNOCKBACK_INCREASE

func get_description() -> String:
	description = description.replace("$1", str(int(BASE_DMG_INCREASE * 100)))
	description = description.replace("$2", str(int(KNOCKBACK_INCREASE * 100)))
	return description
