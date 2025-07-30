extends BaseUpgrade
class_name BounceBulletUpgrade

@export var BOUNCE_COUNT := 1
@export var BOUNCE_DAMAGE_MULT := 0.8
@export var RICOCHET_SFX: String

func on_fire_add(bullet: ProtoBullet, _player: Player, _is_support: bool = false):
	bullet.tracking_keys["bounce_count"] = BOUNCE_COUNT * upgrade_copies_count
	bullet.pierce_count += BOUNCE_COUNT * upgrade_copies_count

func on_bullet_hit_target(bullet: ProtoBullet):
	if bullet != null and bullet.tracking_keys.has("bounce_count"):
		if bullet.tracking_keys["bounce_count"] > 0:
			bullet.tracking_keys["bounce_count"] -= 1
			var enemy = find_target(bullet)
			if enemy == null:
				return
			
			var aim_vec: Vector2 = (enemy.position - bullet.position).normalized()
			bullet.velocity = aim_vec * bullet.velocity.length()
			bullet.rotation = aim_vec.angle() + PI / 2
			bullet.despawn_timer = 0.0
			bullet.damage *= BOUNCE_DAMAGE_MULT
			
			# Play SFX
			if RICOCHET_SFX:
				SoundManager.play_sound(RICOCHET_SFX)
			if bullet is ShellProjectile:
				bullet.anim_player.stop()
				bullet.anim_player.play("eject", -1, randf_range(0.85, 1.15))

func find_target(bullet: ProtoBullet):
	var enemies = bullet.get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		return null
	
	var valid_enemies: Array[ProtoEnemy] = []
	for enemy in enemies:
		var valid = true
		for hitbox in bullet.enemy_list:
			if is_instance_valid(hitbox) and is_instance_valid(enemy) and hitbox.is_ancestor_of(enemy):
				valid = false
			if valid:
				valid_enemies.append(enemy)
	if valid_enemies.size() == 0:
		return null
	
	return valid_enemies.pick_random()

func get_description() -> String:
	description = description.replace("$1", str(BOUNCE_COUNT))
	description = description.replace("$2", str(ceili((1.0-BOUNCE_DAMAGE_MULT) * 100.0)))
	return description
