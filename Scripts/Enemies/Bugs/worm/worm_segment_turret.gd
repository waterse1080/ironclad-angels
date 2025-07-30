class_name WormSegmentTurret
extends WormSegment

@export var projectile_damage: float = 100.0
@export var projectile_cooldown := 5.0
@export var projectile_sfx: String

var projectile_preload = load("res://Scenes/Enemies/Bugs/enemy_bug_projectile.tscn")
var cooldown_timer: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var turret: Sprite2D = $Turret
@onready var spawn_point: Marker2D = $Turret/ProjectileSpawnPoint

func _ready() -> void:
	super._ready()
	cooldown_timer -= delay_time

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	var travel_vec = (player.global_position - global_position).normalized()
	var target_angle = (Vector2.DOWN.rotated(rotation).angle_to(travel_vec))
	turret.rotation = target_angle

	cooldown_timer += delta
	if cooldown_timer >= projectile_cooldown:
		cooldown_timer = randf_range(-1.0, 0.0)
		fire_projectile()

func fire_projectile() -> void:
	if player == null:
		return
	var our_pos = get_position()
	var travel_vec = (player.get_position() - our_pos).normalized()
	var projectile: EnemyProjectile = projectile_preload.instantiate()
	projectile.velocity = travel_vec
	projectile.position = spawn_point.global_position
	projectile.rotation = travel_vec.angle() - PI/2
	projectile.DAMAGE = projectile_damage
	call_deferred("add_sibling", projectile)
	projectile.call_deferred("play_anim", "boss")

	# Play SFX
	if projectile_sfx:
		SoundManager.play_sound(projectile_sfx)

	animation_player.stop()
	animation_player.play("fire")
