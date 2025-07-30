class_name RocketProjectile
extends ProtoBullet

var explosion_preload = load("res://Scenes/explosion.tscn")

@onready var hit_box: HitBox = $HitBox
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var trail: TrailComponent = $TrailComponent

func _physics_process(delta):
	move_and_slide()
	despawn_timer += delta
	if despawn_timer >= TIME_UNTIL_CLEANUP:
		call_deferred("explode")

func play_fly_anim() -> void:
	anim_player.stop()
	anim_player.play("flying")
	trail.visible = true

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		# Ignore duplicate hits
		if enemy_list.find(area) == -1:
			# Apply damage
			var critInfo = determineCrit()
			area.damage(critInfo.dmg, critInfo.crit_level)
			if "knockback" in area.get_parent():
				area.get_parent().knockback = velocity.normalized() * knockback # maybe change to +=
			enemy_list.append(area)
			hurtbox_damaged.emit(area)
			SignalBus.enemy_hurt.emit(critInfo.dmg, critInfo.crit_level, SPREAD, area)
			SignalBus.bullet_hit_target.emit(self)
			# Play SFX
			if IMPACT_SFX:
				SoundManager.play_sound(IMPACT_SFX)
			# Destroy
			play_hit_effect()
			if enemy_list.size() >= pierce_count:
				bullet_destroyed.emit()
				explode()

func explode():
	var explosion = explosion_preload.instantiate()
	explosion.position = position
	explosion.scale = scale
	explosion.DAMAGE = damage * 2.0
	explosion.SPREAD = true
	explosion.active_masks.append(1)
	call_deferred("add_sibling", explosion)
	call_deferred("queue_free")
