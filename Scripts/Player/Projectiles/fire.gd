extends ProtoBullet
class_name Fire

@onready var anim_player = $AnimationPlayer as AnimationPlayer
@onready var hitbox = $HitBox as HitBox

@export var TICK_TIME := 0.5
@export var DURATION := 5.0

var burn_debuff = load("res://Scenes/Debuffs/burn_debuff.tscn")

func call_queue_free():
	call_deferred("queue_free")

func _physics_process(delta):
	move_and_slide()
	despawn_timer += delta
	if despawn_timer >= TIME_UNTIL_CLEANUP:
		anim_player.stop()
		anim_player.play("Despawn")
		despawn_timer = -999

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		# Ignore duplicate hits
		if enemy_list.find(area) == -1:
			# Apply damage
			var critInfo = determineCrit()
			area.damage(critInfo.dmg, critInfo.crit_level, false)
			enemy_list.append(area)
			hurtbox_damaged.emit(area)
			SignalBus.enemy_hurt.emit(critInfo.dmg, critInfo.crit_level, SPREAD, area)
			SignalBus.bullet_hit_target.emit(self)
			# Play SFX
			if IMPACT_SFX:
				SoundManager.play_sound(IMPACT_SFX)
			var health_component = area.health_component
			var hit_target = health_component.get_parent()
			var new_burn = burn_debuff.instantiate()
			new_burn.DAMAGE_PER_TICK = damage * 0.5
			new_burn.TICK_TIME = TICK_TIME
			new_burn.DURATION = DURATION
			new_burn.add_to_target(hit_target, area)
