class_name RocketMechTurret
extends PlayerTurret

@export var missile_spawn_points: Array[Marker2D]

var spawn_index: int = 0
var fire_explosion = load("res://Scenes/Particles/bullet_fire_explosion.tscn")
var rocket_projectile = load("res://Scenes/Player/Projectiles/rocket_projectile.tscn")

@onready var ammo_tracker: AmmoTrackerComponent = $AmmoTrackerComponent
@onready var vibration_intensity_setting = preload("res://game_settings/setting_vibration_intensity.tres")

func _ready() -> void:
	load_time = base_load_time
	damage = base_damage
	ammo_tracker.reload_started.connect(play_reload)
	ammo_tracker.reload_updated.connect(update_reload)
	ammo_tracker.ammo_updated.connect(update_shot_count)

func play_reload(_current: float, _max: float) -> void:
	anim_player.stop()
	anim_player.play("reload", -1, 0.5/ammo_tracker.reload_time)

func handle_input(delta):
	calculate_aim(delta)
	load_timer -= delta
	var fire = Input.is_action_pressed("Fire")
	# Detect fire
	if fire and load_timer <= 0:
		var will_shoot = ammo_tracker.use_ammo()
		if not will_shoot:
			ammo_tracker.process_reload(delta)
			return

		var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
		Input.start_joy_vibration(0, 0.5 * v_mult, 0.7 * v_mult, 0.2 * base_load_time / load_time)
		player.camera.apply_shake(5.0)

		if bullet_sfx:
			SoundManager.play_sound(bullet_sfx)

		load_timer = load_time
		var new_rocket = rocket_projectile.instantiate()
		new_rocket.rotation = rotation
		new_rocket.position = missile_spawn_points[spawn_index].global_position
		spawn_index += 1
		if spawn_index >= missile_spawn_points.size():
			spawn_index = 0
		new_rocket.velocity = Vector2.from_angle(rotation - PI / 2).normalized()
		new_rocket.DAMAGE = damage
		player.add_sibling(new_rocket)
		player.call_deferred("apply_bullet_upgrades", new_rocket)
		player.call_deferred("apply_bullet_limits", new_rocket)
		call_deferred("split_bullets", new_rocket)

		var bullet_explosion = fire_explosion.instantiate()
		bullet_explosion.position = new_rocket.position
		player.add_sibling(bullet_explosion)
	ammo_tracker.process_reload(delta)

func update_shot_count(current: float, maximum: float) -> void:
	SignalBus.ammo_updated.emit(str(int(current)) + "/" + str(int(maximum)), current, maximum)
