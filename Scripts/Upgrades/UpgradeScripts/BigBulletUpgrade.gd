class_name BigBulletUpgrade
extends BaseUpgrade

@export var SCALE := 0.25
@export var BASE_DMG_INCREASE := 0.25 
@export var SPEED_MULT := 0.8

func on_fire_add(bullet: ProtoBullet, _player: Player, _is_support: bool = false):
	bullet.damage += bullet.DAMAGE * BASE_DMG_INCREASE
	bullet.scale.x += SCALE
	bullet.scale.y += SCALE

func on_fire_mult(bullet: ProtoBullet, _player: Player, _is_support: bool = false):
	bullet.velocity = bullet.velocity * SPEED_MULT

func get_description() -> String:
	description = description.replace("$1", str(int(SCALE * 100)))
	description = description.replace("$2", str(int(BASE_DMG_INCREASE * 100)))
	description = description.replace("$3", str(int((1.0 - SPEED_MULT) * 100)))
	return description
