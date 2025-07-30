extends PlayerTurret
class_name DefenderMechTurret

var bullet = load("res://Scenes/Player/Projectiles/sword_slash.tscn")
var slash_count := 0
@onready var vibration_intensity_setting = preload("res://game_settings/setting_vibration_intensity.tres")
@onready var torso = $BodyParent/TorsoParent/Torso
@onready var head = $BodyParent/Head

func handle_input(delta):
	calculate_aim(delta)
	load_timer -= delta
	var fire = Input.is_action_pressed("Fire")
	# Detect fire
	
	if fire and load_timer <= 0:
		slash_count += 1
		if slash_count > 2:
			slash_count = 1
		aim.play("fire", base_load_time / load_time)
		var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
		Input.start_joy_vibration(0, 0.5 * v_mult, 0.7 * v_mult, 0.2 * base_load_time / load_time)
		player.camera.apply_shake(5.0)
		if bullet_sfx:
			SoundManager.play_sound(bullet_sfx)
		load_timer = load_time
		anim_player.stop()
		anim_player.play("slash_" + str(slash_count))
		var newBullet = bullet.instantiate()
		newBullet.rotation = rotation
		newBullet.position = spawn_point.global_position
		newBullet.velocity = Vector2.from_angle(rotation - PI / 2).normalized()
		newBullet.DAMAGE = damage
		player.add_sibling(newBullet)
		player.call_deferred("apply_bullet_upgrades", newBullet)
		player.call_deferred("apply_bullet_limits", newBullet)
		call_deferred("split_bullets", newBullet)
	
	if body.is_boosting:
		torso.frame = 1
		head.frame = 1
	else:
		torso.frame = 0
		head.frame = 0
