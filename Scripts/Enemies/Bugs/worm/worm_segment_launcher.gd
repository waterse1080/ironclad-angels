class_name WormSegmentLauncher
extends WormSegment

@export var projectile_damage: float = 100.0
@export var projectile_cooldown := 5.0
@export var projectile_sfx: String
@export var bomb_range: float = 200.0

var bomb_preload = load("res://Scenes/falling_bomb.tscn")
var cooldown_timer: float = 0.0

func _ready() -> void:
	super._ready()
	cooldown_timer -= delay_time

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	cooldown_timer += delta
	if cooldown_timer >= projectile_cooldown:
		cooldown_timer = 0
		fire_projectile()

func fire_projectile() -> void:
	if player == null:
		return
	var our_pos = get_position()
	var travel_vec = (player.get_position() - our_pos).normalized()
	var bomb: FallingBomb = bomb_preload.instantiate()
	var range_mod = Vector2(
		randf_range(-bomb_range, bomb_range),
		randf_range(-bomb_range, bomb_range)
	)
	bomb.global_position = player.global_position + range_mod
	bomb.explosion_damage = projectile_damage
	call_deferred("add_sibling", bomb)

	# Play SFX
	if projectile_sfx:
		SoundManager.play_sound(projectile_sfx)
