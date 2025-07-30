class_name FastBulletUpgrade
extends BaseUpgrade

@export var speed_mult: float = 1.35
@export var pierce_increase: int = 1

func on_fire_add(bullet: ProtoBullet, _player: Player, _is_support: bool = false):
	bullet.pierce_count += pierce_increase

func on_fire_mult(bullet: ProtoBullet, _player: Player, _is_support: bool = false):
	bullet.velocity = bullet.velocity * speed_mult
	bullet.speed = bullet.speed * speed_mult # for stinger to reference

func get_description() -> String:
	description = description.replace("$1", str(int((speed_mult - 1.0) * 100)))
	description = description.replace("$2", str(int(pierce_increase)))
	return description
