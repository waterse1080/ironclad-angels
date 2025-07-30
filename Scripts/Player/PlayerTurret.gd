class_name PlayerTurret
extends Node2D

@export var body: PlayerBody
@export var player: Player
@export var base_load_time: float
@export var base_damage: float
@export var bullet_sfx: String
@export var shell_sfx: String
@export var missle_scale: float
@export var bullet_spread_angle: float = 10.0

var load_time: float
var load_timer: float = 0.0
var kbm: bool = false
var bullet_split_count: int = 1
var aim_toggle := false
var damage: float

@onready var aim = $Aim as AnimatedSprite2D
@onready var anim_player = $AnimationPlayer as AnimationPlayer
@onready var spawn_point = $SpawnPoint as Node2D

func _ready():
	load_time = base_load_time
	damage = base_damage

func connect_parts(new_body: PlayerBody, new_player: Player):
	body = new_body
	player = new_player

func handle_input(delta):
	calculate_aim(delta)

func calculate_aim(delta: float):
	# Detect if using controller or mouse, rotate top section accordingly
	var mouse_pos = get_global_mouse_position()
	var our_pos = player.get_position()

	var toggle = Input.is_action_just_pressed("ToggleAim")
	var fire = Input.is_action_pressed("Fire")
	if toggle:
		aim_toggle = !aim_toggle

	if aim_toggle:
		var enemies = get_tree().get_nodes_in_group("enemies")
		aim.visible = enemies.size() > 0
		if enemies.size() > 0:
			var closest_enemy = enemies[0]
			for enemy in enemies:
				if enemy.position.distance_to(our_pos) + 10 < closest_enemy.position.distance_to(our_pos):
					closest_enemy = enemy
			var target_angle = (closest_enemy.position - our_pos).angle() + PI / 2
			if rotation > target_angle + PI:
				target_angle += 2 * PI
			elif target_angle > rotation + PI:
				target_angle -= 2 * PI
			rotation = lerpf(rotation, target_angle, delta * 15)
			if fire and load_timer <= 0:
				rotation = target_angle
			aim.global_position = closest_enemy.global_position
	else:
		# Set kbm true on mouse move
		var mouse_vel = Input.get_last_mouse_velocity()
		if mouse_vel.x or mouse_vel.y:
			kbm = true

		if mouse_pos and our_pos and kbm:
			rotation = (mouse_pos - our_pos).angle() + PI / 2
			aim.global_position = mouse_pos

		var aim_direction = Input.get_vector("AimLeft", "AimRight", "AimUp", "AimDown")
		if aim_direction.x or aim_direction.y:
			rotation = aim_direction.angle() + PI / 2
			aim.position = Vector2(0, -300)
			kbm = false

	aim.rotation = -rotation

func split_bullets(projectile: ProtoBullet):
	if bullet_split_count <= 1:
		return

	var bullet_list: Array[ProtoBullet] = [projectile]
	for i in bullet_split_count-1:
		var new_bullet = projectile.duplicate()
		bullet_list.append(new_bullet)
		new_bullet.copy_values(projectile)
		projectile.add_sibling(new_bullet)

	var spread_step := bullet_spread_angle / float(bullet_split_count)
	var spread_start := spread_step/2 - bullet_spread_angle/2
	for i in bullet_split_count:
		var current_bullet = bullet_list[i]
		var current_angle = spread_step * i
		current_bullet.velocity = rotate_velocity(
			current_bullet.velocity,
			deg_to_rad(current_angle + spread_start)
			)
		current_bullet.rotation += deg_to_rad(current_angle + spread_start)

func rotate_velocity(vel: Vector2, angle: float) -> Vector2:
	var new_velocity := Vector2.ZERO
	new_velocity.x = (vel.x * cos(angle) - vel.y * sin(angle))
	new_velocity.y = (vel.x * sin(angle) + vel.y * cos(angle))
	return new_velocity

func update_reload(current: float, maximum: float) -> void:
	SignalBus.ammo_updated.emit("RELOADING", current, maximum)
