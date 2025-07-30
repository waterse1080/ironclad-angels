extends PlayerTurret
class_name RapidFireTurret

@onready var EjectL = $"EjectPoint-L"
@onready var EjectR = $"EjectPoint-R"
@onready var BarrelL = $"Barrel-L"
@onready var BarrelR = $"Barrel-R"
@onready var anim_player2 = $AnimationPlayer2
@onready var spawn_point2 = $SpawnPoint2
@onready var ammo_tracker: AmmoTrackerComponent = $AmmoTrackerComponent
@onready var vibration_intensity_setting = preload("res://game_settings/setting_vibration_intensity.tres")

var bullet = load("res://Scenes/Player/Projectiles/mini_bullet.tscn")
var shell = load("res://Scenes/Particles/mini_shell.tscn")
var fire_explosion = load("res://Scenes/Particles/bullet_fire_explosion.tscn")
var fire_left := true

func _ready() -> void:
	super._ready()
	ammo_tracker.ammo_updated.connect(update_shot_count)
	ammo_tracker.reload_updated.connect(update_reload)

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

		aim.play("fire", base_load_time / load_time)
		var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
		Input.start_joy_vibration(0, 0.2 * v_mult, 0.4 * v_mult, 0.2 * base_load_time / load_time)
		player.camera.apply_shake(5.0)
		if bullet_sfx:
			SoundManager.play_sound(bullet_sfx)
		load_timer = load_time
		if fire_left:
			anim_player.stop()
			anim_player.play("Fire-L", -1, base_load_time / load_time)
		else:
			anim_player2.stop()
			anim_player2.play("Fire-R", -1, base_load_time / load_time)
		var newBullet = bullet.instantiate()
		newBullet.rotation = rotation
		var bullet_explosion = fire_explosion.instantiate()
		bullet_explosion.scale *= 0.5
		if fire_left:
			newBullet.position = spawn_point.global_position
			bullet_explosion.position = spawn_point.global_position
		else:
			newBullet.position = spawn_point2.global_position
			bullet_explosion.position = spawn_point2.global_position
		newBullet.velocity = Vector2.from_angle(rotation - PI / 2).normalized()
		newBullet.DAMAGE = damage
		player.add_sibling(newBullet)
		player.add_sibling(bullet_explosion)
		player.call_deferred("apply_bullet_upgrades", newBullet)
		player.call_deferred("apply_bullet_limits", newBullet)
		call_deferred("split_bullets", newBullet)
		play_barrel_anim(fire_left)
		fire_left = !fire_left
	ammo_tracker.process_reload(delta)

func spawnShell(left: bool):
	if shell_sfx:
		SoundManager.play_sound(shell_sfx, 0.9, 1.0)
	var new_shell = shell.instantiate()
	new_shell.emitting = true
	if left:
		new_shell.position = EjectL.global_position
	else:
		new_shell.position = EjectR.global_position
	new_shell.angle_min = rotation_degrees * -1
	new_shell.angle_max = rotation_degrees * -1
	new_shell.z_index = 999
	player.add_sibling(new_shell)
	new_shell.finished.connect(new_shell.queue_free)
	for i in clampi(bullet_split_count-1, 0, 10):
		var extraShell = new_shell.duplicate()
		player.add_sibling(extraShell)
		extraShell.finished.connect(extraShell.queue_free)

func play_barrel_anim(left: bool):
	if left:
		BarrelL.play("default", base_load_time / load_time)
	else:
		BarrelR.play("default", base_load_time / load_time)		

func update_shot_count(current: float, maximum: float) -> void:
	SignalBus.ammo_updated.emit(str(int(current)) + "/" + str(int(maximum)), current, maximum)
