extends PlayerTurret
class_name DefaultTurret

var bullet = load("res://Scenes/Projectiles/proto_bullet.tscn")
var shell = load("res://Scenes/Particles/proto_shell.tscn")
var fire_explosion = load("res://Scenes/Particles/bullet_fire_explosion.tscn")

@onready var fake_shell = $Shell as Sprite2D
@onready var ammo_tracker: AmmoTrackerComponent = $AmmoTrackerComponent
@onready var sprite: Sprite2D = $Top
@onready var vibration_intensity_setting = preload("res://game_settings/setting_vibration_intensity.tres")

func _ready() -> void:
	load_time = base_load_time
	damage = base_damage
	ammo_tracker.ammo_updated.connect(update_shot_count)
	ammo_tracker.reload_updated.connect(update_reload)

func handle_input(delta):
	calculate_aim(delta)
	$ProtoShell.rotation = -rotation
	load_timer -= delta
	var fire = Input.is_action_pressed("Fire")
	# Detect fire
	if fire and load_timer <= 0:
		var will_shoot = ammo_tracker.use_ammo()
		if not will_shoot:
			ammo_tracker.process_reload(delta)
			return
		aim.play("fire", base_load_time / load_time)
		var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
		Input.start_joy_vibration(0, 0.5 * v_mult, 0.7 * v_mult, 0.2 * base_load_time / load_time)
		player.camera.apply_shake(5.0)
		if bullet_sfx:
			SoundManager.play_sound(bullet_sfx)
		if shell_sfx:
			SoundManager.play_sound(shell_sfx, 0.95, 1.05)
		load_timer = load_time
		anim_player.stop()
		anim_player.play("Fire", -1, base_load_time / load_time)
		var newBullet = bullet.instantiate()
		newBullet.rotation = rotation
		newBullet.position = spawn_point.global_position
		newBullet.velocity = Vector2.from_angle(rotation - PI / 2).normalized()
		newBullet.DAMAGE = damage
		player.add_sibling(newBullet)
		player.call_deferred("apply_bullet_upgrades", newBullet)
		player.call_deferred("apply_bullet_limits", newBullet)
		call_deferred("split_bullets", newBullet)

		var bullet_explosion = fire_explosion.instantiate()
		bullet_explosion.position = spawn_point.global_position
		player.add_sibling(bullet_explosion)
	ammo_tracker.process_reload(delta)

func spawnShell():
	var new_shell = shell.instantiate()
	new_shell.emitting = true
	new_shell.position = fake_shell.global_position
	new_shell.angle_min = rotation_degrees * -1
	new_shell.angle_max = rotation_degrees * -1
	new_shell.z_index = 999
	player.add_sibling(new_shell)
	new_shell.finished.connect(new_shell.queue_free)
	for i in clampi(bullet_split_count-1, 0, 10):
		var extraShell = new_shell.duplicate()
		player.add_sibling(extraShell)
		extraShell.finished.connect(extraShell.queue_free)

func update_shot_count(current: float, maximum: float) -> void:
	var frame_count = sprite.hframes - 1
	var current_frame = ceili((1.0 - current/maximum) * frame_count)
	if current_frame > frame_count:
		current_frame = frame_count
	sprite.frame = current_frame
	SignalBus.ammo_updated.emit(str(int(current)) + "/" + str(int(maximum)), current, maximum)
