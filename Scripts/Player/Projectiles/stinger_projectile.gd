class_name StingerProjectile
extends ProtoBullet

@export var turn_speed: float = 15.0
var tracker_preload = load("res://Scenes/Player/Projectiles/stinger_explosion_tracker.tscn")
var _target: Node2D

@onready var TargetDetectionArea: Area2D = $TargetDetectionArea

func _on_ready() -> void:
	if not TargetDetectionArea:
		await self.ready
	TargetDetectionArea.area_entered.connect(_target_detect)

func _target_detect(area) -> void:
	if _target:
		return
	if area is not HurtBox:
		return
	if enemy_list.find(area) != -1:
		return
	_target = area

func _physics_process(delta):
	if _target != null and _target.position != null:
		var ourPos = self.global_position
		var travelVec = (_target.global_position - ourPos).normalized() * speed
		velocity.x = lerpf(velocity.x, travelVec.x, delta * turn_speed)
		velocity.y = lerpf(velocity.y, travelVec.y, delta * turn_speed)
		velocity = velocity.normalized() * speed
		self.rotation = velocity.angle() + PI / 2

	move_and_slide()
	despawn_timer += delta
	if despawn_timer >= TIME_UNTIL_CLEANUP:
		call_deferred("queue_free")

func _on_hit_box_hitbox_triggered(area):
	if area is not HurtBox:
		return
	# Ignore duplicate hits
	if enemy_list.find(area) != -1:
		return
	if area == _target:
		_target = null
	# Apply damage
	var critInfo = determineCrit()
	area.damage(critInfo.dmg, critInfo.crit_level)
	if "knockback" in area.get_parent():
		area.get_parent().knockback = velocity.normalized() * knockback # maybe change to +=
	enemy_list.append(area)
	hurtbox_damaged.emit(area)
	SignalBus.enemy_hurt.emit(critInfo.dmg, critInfo.crit_level, SPREAD, area)
	SignalBus.bullet_hit_target.emit(self)
	# Add/tick tracker
	var tracker: StingerExplosionTracker
	for child in area.get_children():
		if child is StingerExplosionTracker:
			tracker = child
	if tracker:
		tracker.add_hit(damage)
	else:
		tracker = tracker_preload.instantiate()
		tracker.total_damage = damage
		tracker.connect_to_parent(area)
		area.call_deferred("add_child", tracker)
	# Play SFX
	if IMPACT_SFX:
		SoundManager.play_sound(IMPACT_SFX)
	play_hit_effect()
	# Destroy
	if enemy_list.size() >= pierce_count:
		bullet_destroyed.emit()
		self.queue_free()
