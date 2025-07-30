class_name ShotgunTurret
extends PlayerTurret

var bullet = load("res://Scenes/Player/Projectiles/shotgun_pellet.tscn")
var shell = load("res://Scenes/Player/Projectiles/shell_projectile.tscn")
var fire_explosion = load("res://Scenes/Particles/bullet_fire_explosion.tscn")

@onready var eject_l: Node2D = $"Eject_L"
@onready var eject_r: Node2D = $"Eject_R"
@onready var spawn_point_2: Node2D = $SpawnPoint2
@onready var vibration_intensity_setting = preload("res://game_settings/setting_vibration_intensity.tres")

func _ready() -> void:
	load_time = base_load_time
	damage = base_damage
	bullet_split_count += 2

func handle_input(delta):
	calculate_aim(delta)
	load_timer -= delta
	var fire = Input.is_action_pressed("Fire")
	# Detect fire
	if fire and load_timer <= 0:
		load_timer = load_time
		anim_player.stop()
		anim_player.play("fire", -1, base_load_time / load_time)

func play_unload_sound() -> void:
	SoundManager.play_sound("ShotgunUnloadSFX", 0.95, 1.05)

func play_load_sound() -> void:
	SoundManager.play_sound("ShotgunLoadSFX", 0.95, 1.05)

func fire_bullets() -> void:
	aim.play("fire", base_load_time / load_time)
	var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
	Input.start_joy_vibration(0, 0.2 * v_mult, 0.4 * v_mult, 0.2 * base_load_time / load_time)
	player.camera.apply_shake(7.5)
	if bullet_sfx:
		SoundManager.play_sound(bullet_sfx, 0.95, 1.05)
		SoundManager.play_sound(bullet_sfx, 0.95, 1.05)

	var new_bullet_l: ProtoBullet = bullet.instantiate()
	var new_bullet_r: ProtoBullet = bullet.instantiate()
	new_bullet_l.rotation = rotation
	new_bullet_r.rotation = rotation
	new_bullet_l.position = spawn_point.global_position
	new_bullet_r.position = spawn_point_2.global_position
	new_bullet_l.velocity = Vector2.from_angle(rotation - PI / 2).normalized()
	new_bullet_r.velocity = Vector2.from_angle(rotation - PI / 2).normalized()
	new_bullet_l.DAMAGE = damage
	new_bullet_r.DAMAGE = damage
	player.add_sibling(new_bullet_l)
	player.add_sibling(new_bullet_r)
	player.call_deferred("apply_bullet_upgrades", new_bullet_l)
	player.call_deferred("apply_bullet_upgrades", new_bullet_r)
	player.call_deferred("apply_bullet_limits", new_bullet_l)
	player.call_deferred("apply_bullet_limits", new_bullet_r)
	call_deferred("split_bullets", new_bullet_l)
	call_deferred("split_bullets", new_bullet_r)

	var bullet_explosion_l = fire_explosion.instantiate()
	var bullet_explosion_r = fire_explosion.instantiate()
	bullet_explosion_l.position = spawn_point.global_position
	bullet_explosion_r.position = spawn_point_2.global_position
	player.add_sibling(bullet_explosion_l)
	player.add_sibling(bullet_explosion_r)

func eject_shells() -> void:
	var new_bullet_l: ShellProjectile = shell.instantiate()
	var new_bullet_r: ShellProjectile = shell.instantiate()
	var rand_l = randf_range(0.05, 0.15)
	var rand_r = randf_range(0.05, 0.15)
	new_bullet_l.rotation = rotation + rand_l
	new_bullet_r.rotation = rotation - rand_r
	new_bullet_l.position = eject_l.global_position
	new_bullet_r.position = eject_r.global_position
	var player_speed = normalize_player_velocity()
	new_bullet_l.velocity = Vector2.from_angle(rotation + PI / 2 + rand_l).normalized() + player_speed
	new_bullet_r.velocity = Vector2.from_angle(rotation + PI / 2 - rand_r).normalized() + player_speed
	#new_bullet_l.DAMAGE = damage
	#new_bullet_r.DAMAGE = damage
	player.add_sibling(new_bullet_l)
	player.add_sibling(new_bullet_r)
	player.call_deferred("apply_bullet_upgrades", new_bullet_l)
	player.call_deferred("apply_bullet_upgrades", new_bullet_r)
	player.call_deferred("apply_bullet_limits", new_bullet_l)
	player.call_deferred("apply_bullet_limits", new_bullet_r)
	#call_deferred("split_bullets", new_bullet_l)
	#call_deferred("split_bullets", new_bullet_r)

func normalize_player_velocity() -> Vector2:
	var div = 500.0
	var x = player.velocity.x / div
	var y = player.velocity.y / div

	if x > 1:
		x = 1
	elif x < -1:
		x = -1

	if y > 1:
		y = 1
	elif y < -1:
		y = -1

	return Vector2(x, y)
