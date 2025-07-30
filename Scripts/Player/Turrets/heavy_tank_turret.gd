class_name HeavyTankTurret
extends PlayerTurret

enum FireState { COOLDOWN, READY, CHARGE }
@export var max_charge_mult: float = 3
@export var current_charge_percent: float = 0
var current_state: FireState = FireState.READY
var bullet = load("res://Scenes/Projectiles/proto_bullet.tscn")
var fire_explosion = load("res://Scenes/Particles/bullet_hit_explosion.tscn")
@onready var vibration_intensity_setting = preload(
	"res://game_settings/setting_vibration_intensity.tres"
	)

func handle_input(delta) -> void:
	calculate_aim(delta)
	load_timer -= delta

	# Change State
	if load_timer <= 0 and current_state == FireState.COOLDOWN:
		current_state = FireState.READY

	# Detect fire
	var fire_pressed = Input.is_action_pressed("Fire")
	if fire_pressed and load_timer <= 0 and current_state == FireState.READY:
		aim.play("fire", base_load_time / load_time)
		anim_player.stop()
		anim_player.play("charge", -1, base_load_time / load_time)
		current_state = FireState.CHARGE
	elif not fire_pressed and current_state == FireState.CHARGE:
		fire()

func play_charge_noise() -> void:
	SoundManager.play_sound(
		"RailgunChargeSFX",
		0.45 + current_charge_percent,
		0.55 + current_charge_percent
	)

func fire() -> void:
	# SFX/VFX
	var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
	Input.start_joy_vibration(0, 0.5 * v_mult, 0.7 * v_mult, 0.2 * base_load_time / load_time)
	player.camera.apply_shake(20.0 * current_charge_percent)
	if bullet_sfx:
		SoundManager.play_sound(bullet_sfx)
	SoundManager.stop_sound("RailgunChargeSFX")

	# Calculate charged damage
	var damage_mult = current_charge_percent * max_charge_mult

	# Change status
	load_timer = load_time
	current_state = FireState.COOLDOWN
	anim_player.stop()
	anim_player.play("fire")
	current_charge_percent = 0

	# Create projectile
	var new_bullet: ProtoBullet = bullet.instantiate()
	new_bullet.rotation = rotation
	new_bullet.position = spawn_point.global_position
	new_bullet.velocity = Vector2.from_angle(rotation - PI / 2).normalized() * damage_mult
	new_bullet.DAMAGE = damage * damage_mult
	new_bullet.PIERCE_COUNT += floori(damage_mult)
	player.add_sibling(new_bullet)
	player.call_deferred("apply_bullet_upgrades", new_bullet)
	player.call_deferred("apply_bullet_limits", new_bullet)
	call_deferred("split_bullets", new_bullet)

	var bullet_explosion = fire_explosion.instantiate()
	bullet_explosion.position = spawn_point.global_position
	player.add_sibling(bullet_explosion)
