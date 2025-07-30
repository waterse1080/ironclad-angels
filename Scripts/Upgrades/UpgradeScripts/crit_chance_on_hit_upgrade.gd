class_name CritChanceOnHit
extends BaseUpgrade

@export var extra_crit_chance: float = 0.2

func on_bullet_hit_target(bullet: ProtoBullet):
	if bullet != null:
		bullet.crit_chance += extra_crit_chance

func get_description() -> String:
	return description.replace("$", str(int(extra_crit_chance * 100)))
