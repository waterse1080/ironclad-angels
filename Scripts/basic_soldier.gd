class_name BasicSoldier
extends CharacterBody2D

@export var voice_pack: VoicePack

var player: Player
var move_target: Node2D
var bullet_damage: float = 10.0
var speed: float = 200.0
var turn_speed: float = 5.0

var can_fire: bool = true

var bullet = load("res://Scenes/Player/Projectiles/mini_bullet.tscn")
var shell = load("res://Scenes/Particles/mini_shell.tscn")

@onready var shell_spawn_point: Marker2D = $ShellSpawnPoint
@onready var bullet_spawn_point: Marker2D = $BulletSpawnPoint
@onready var health_component: HealthComponent = $HealthComponent
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	health_component.health_depleted.connect(_on_health_component_health_depleted)
	if voice_pack and voice_pack.spawn_voices.size() > 0:
		SoundManager.play_sound(voice_pack.spawn_voices.pick_random())

func _physics_process(delta: float) -> void:
	aim_closest(delta)
	move_to_target(delta)
	if can_fire:
		var anim_speed = player.turret.base_load_time / player.turret.load_time
		anim_player.play("fire", -1, anim_speed * randf_range(0.95, 1.05))
		can_fire = false

func _on_health_component_health_depleted():
	# Play Death SFX
	if voice_pack and voice_pack.death_voices.size() > 0:
		var scream_chance = randf_range(0.0, 1.0)
		if scream_chance >= 0.99:
			SoundManager.play_sound("WilhelmScream")
		else:
			SoundManager.play_sound(voice_pack.death_voices.pick_random())
	SignalBus.enemy_destroyed.emit(position)
	#var particles = blood_particles.instantiate() as AlienBloodParticles
	#particles.attatch(self)
	#particles.amount = 40
	#particles.scale = scale
	queue_free()

func move_to_target(delta: float) -> void:
	if move_target and move_target.global_position.distance_to(global_position) > 100.0:
		var our_pos = global_position
		var travel_vec = (move_target.global_position - our_pos).normalized() * speed
		velocity.x = lerpf(velocity.x, travel_vec.x, delta * turn_speed)
		velocity.y = lerpf(velocity.y, travel_vec.y, delta * turn_speed)
		velocity = velocity.normalized() * speed
		move_and_slide()

func aim_closest(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var our_pos = position
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
		if can_fire:
			rotation = target_angle
		rotation = lerpf(rotation, target_angle, delta * 15)

func fire_bullet() -> void:
	var new_bullet: ProtoBullet = bullet.instantiate()
	new_bullet.rotation = rotation
	new_bullet.position = bullet_spawn_point.global_position
	new_bullet.velocity = Vector2.from_angle(rotation - PI / 2).normalized()
	new_bullet.DAMAGE = bullet_damage * player.support_damage_mult
	new_bullet.knockback *= 0.5
	call_deferred("add_sibling", new_bullet)
	player.call_deferred("apply_bullet_upgrades", new_bullet, true)
	player.call_deferred("apply_bullet_limits", new_bullet, true)
	player.turret.call_deferred("split_bullets", new_bullet)

func spawn_shell() -> void:
	var new_shell = shell.instantiate()
	new_shell.emitting = true
	new_shell.position = shell_spawn_point.global_position
	new_shell.angle_min = rotation_degrees * -1
	new_shell.angle_max = rotation_degrees * -1
	new_shell.z_index = 999
	call_deferred("add_sibling", new_shell)
	new_shell.finished.connect(new_shell.queue_free)
	for i in clampi(player.turret.bullet_split_count-1, 0, 10):
		var extra_shell = new_shell.duplicate()
		call_deferred("add_sibling", extra_shell)
		extra_shell.finished.connect(extra_shell.queue_free)

func ready_fire() -> void:
	can_fire = true
