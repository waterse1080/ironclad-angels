extends PlayerTurret
class_name FireTurret

@export var WARMUP_TIME := 0.4

var fire_preload = load("res://Scenes/Player/Projectiles/fire.tscn")
var fire_explosion = load("res://Scenes/Particles/bullet_fire_explosion.tscn")
var base_recharge_rate: float
var warmup_timer := 0.0
var warmup_time := 0.0
var state := 0 # 0 cold/cooling, 1 heating up, 2 firing
#@onready var smoke_particles = $SmokeParticles as SmokeParticles

@onready var ammo_tracker: AmmoTrackerComponent = $AmmoTrackerComponent
@onready var vibration_intensity_setting = preload("res://game_settings/setting_vibration_intensity.tres")

func _ready():
	super._ready()
	warmup_time = WARMUP_TIME
	warmup_timer = WARMUP_TIME
	base_recharge_rate = ammo_tracker.recharge_rate
	ammo_tracker.ammo_updated.connect(update_shot_count)
	

func handle_input(delta):
	calculate_aim(delta)
	load_timer -= delta
	var fire = Input.is_action_pressed("Fire")
	# Play animations
	if fire:
		var will_shoot = ammo_tracker.use_ammo()
		if not will_shoot:
			ammo_tracker.process_reload(delta)
			return
		if state == 0:
			state = 1
			anim_player.stop()
			anim_player.play("HeatUp", -1, base_load_time / load_time)
			#smoke_particles.emitting = false
		if state == 1:
			warmup_timer -= delta
			if warmup_timer <= 0:
				state = 2
				anim_player.stop()
				anim_player.play("Firing", -1, base_load_time / load_time)
	else:
		if state == 1 or state == 2:
			state = 0
			warmup_timer = warmup_time
			anim_player.stop()
			anim_player.play("Cooldown", -1, ammo_tracker.recharge_rate / base_recharge_rate)
	# Detect fire
	if fire and load_timer <= 0:
		aim.play("fire", base_load_time / load_time)
		var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
		Input.start_joy_vibration(0, 0.1 * v_mult, 0.15 * v_mult, 0.1 * base_load_time / load_time)
		player.camera.apply_shake(2.5)
		if bullet_sfx:
			SoundManager.play_sound(bullet_sfx)
		load_timer = load_time
		var newBullet = fire_preload.instantiate()
		newBullet.rotation = rotation
		newBullet.position = spawn_point.global_position
		newBullet.velocity = Vector2.from_angle(rotation - PI / 2).normalized() #+ player.velocity.normalized()/3
		newBullet.DAMAGE = damage
		player.add_sibling(newBullet)
		player.call_deferred("apply_bullet_upgrades", newBullet)
		player.call_deferred("apply_bullet_limits", newBullet)
		call_deferred("split_bullets", newBullet)

		var bullet_explosion = fire_explosion.instantiate()
		bullet_explosion.position = spawn_point.global_position
		bullet_explosion.scale *= 0.5
		player.add_sibling(bullet_explosion)
	ammo_tracker.process_reload(delta)

func update_shot_count(current: float, maximum: float) -> void:
	SignalBus.ammo_updated.emit(
		str(int(maximum-current)) + "/" + str(int(maximum)), maximum-current, maximum, true
		)
