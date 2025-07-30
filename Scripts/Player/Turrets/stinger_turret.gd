class_name StingerTurret
extends PlayerTurret

var bullet = load("res://Scenes/Player/Projectiles/stinger_projectile.tscn")
var fire_explosion = load("res://Scenes/Particles/bullet_hit_explosion.tscn")

@onready var ammo_tracker: AmmoTrackerComponent = $AmmoTrackerComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var vibration_intensity_setting = preload("res://game_settings/setting_vibration_intensity.tres")

func _ready() -> void:
	load_time = base_load_time
	damage = base_damage
	ammo_tracker.ammo_updated.connect(update_needle_count)
	ammo_tracker.reload_started.connect(play_reload)
	ammo_tracker.reload_updated.connect(update_reload)
	ammo_tracker.reload_canceled.connect(update_needle_count)
	ammo_tracker.reload_complete.connect(update_needle_count)

func play_reload(_current: float, _max: float) -> void:
	sprite.frame = sprite.hframes - 1
	await get_tree().create_timer(load_time).timeout
	anim_player.stop()
	anim_player.play("reload", -1, 1.5/ammo_tracker.reload_time)

func update_needle_count(current: float, maximum: float) -> void:
	if ammo_tracker.current_state == ammo_tracker.ReloadState.RELOADING:
		return
	sprite.frame = roundi((1-current/maximum) * 18)
	SignalBus.ammo_updated.emit(str(int(current)) + "/" + str(int(maximum)), current, maximum)

func handle_input(delta):
	calculate_aim(delta)

	load_timer -= delta
	var fire = Input.is_action_pressed("Fire")
	# Detect fire
	if fire and load_timer <= 0:
		var will_shoot = ammo_tracker.use_ammo()
		if will_shoot:
			load_timer = load_time
			anim_player.stop()
			anim_player.play("fire", -1, base_load_time / load_time)

	ammo_tracker.process_reload(delta)

func fire_projectiles() -> void:
	aim.play("fire", base_load_time / load_time)
	var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
	Input.start_joy_vibration(0, 0.2 * v_mult, 0.4 * v_mult, 0.2 * base_load_time / load_time)
	player.camera.apply_shake(2.0)
	if bullet_sfx:
		SoundManager.play_sound(bullet_sfx, 0.95, 1.05)
		SoundManager.play_sound(bullet_sfx, 0.95, 1.05)

	var new_bullet: ProtoBullet = bullet.instantiate()
	new_bullet.rotation = rotation
	new_bullet.position = spawn_point.global_position
	new_bullet.velocity = Vector2.from_angle(rotation - PI / 2).normalized()
	new_bullet.DAMAGE = damage
	player.add_sibling(new_bullet)
	player.call_deferred("apply_bullet_upgrades", new_bullet)
	player.call_deferred("apply_bullet_limits", new_bullet)
	call_deferred("split_bullets", new_bullet)

	var bullet_explosion = fire_explosion.instantiate()
	bullet_explosion.position = spawn_point.global_position
	bullet_explosion.scale *= 0.5
	player.add_sibling(bullet_explosion)
