extends ProtoEnemy
class_name FireflyBugEnemy

var explosion_preload = load("res://Scenes/explosion.tscn")

func spawn_explosion():
	# Play Death SFX
	if DEATH_SFX:
		SoundManager.play_sound(DEATH_SFX)
	SignalBus.enemy_destroyed.emit(position)
	
	var explosion: Explosion = explosion_preload.instantiate()
	explosion.active_masks.append(1)
	explosion.position = position
	explosion.scale = scale
	explosion.DAMAGE = DAMAGE
	explosion.SPREAD = false
	call_deferred("add_sibling", explosion)
	call_deferred("queue_free")

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		if ATTACK_HIT_SFX:
			SoundManager.play_sound(ATTACK_HIT_SFX)
		#area.damage(DAMAGE, 0)
		spawn_explosion()

func _on_health_component_health_depleted():
	DropTable.drop_rand_pickup(
		get_tree(),
		self.global_position,
		self.health_component.max_health / 10.0
	)
	spawn_explosion()
