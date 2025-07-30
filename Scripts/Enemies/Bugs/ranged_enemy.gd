extends ProtoEnemy
class_name RangedEnemy

@export var FIRE_COOLDOWN := 5.0
@export var FIRE_SFX: String
@export var STOP_DISTANCE := 300.0

var projectile_preload = load("res://Scenes/Enemies/Bugs/enemy_bug_projectile.tscn")
var cooldown_timer := randf_range(-1.0, 0.0)

@onready var spawn_point = $ProjectileOrigin
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health_component.max_health *= HEALTH_MOD
	health_component.health *= HEALTH_MOD
	sprite.animation_finished.connect(fire_projectile)
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# Move towards player
	var ourPos = get_position()
	var travel_vec = (player.get_position() - ourPos).normalized()
	var target_angle = travel_vec.angle() - PI / 2
	if rotation > target_angle + PI:
		target_angle += 2 * PI
	elif target_angle > rotation + PI:
		target_angle -= 2 * PI
	rotation = lerpf(rotation, target_angle, delta * turn_speed_mult)
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not player:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	elif player.get_position().distance_to(ourPos) <= STOP_DISTANCE:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		velocity = Vector2.DOWN.rotated(rotation) * SPEED
	velocity = velocity + knockback * 0.5
	move_and_slide()
	knockback = knockback.lerp(Vector2.ZERO, 0.1)

	cooldown_timer += delta
	if cooldown_timer >= FIRE_COOLDOWN:
		cooldown_timer = randf_range(-1.0, 0.0)
		sprite.play("fire")

func fire_projectile() -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	var our_pos = get_position()
	var travel_vec = (player.get_position() - our_pos).normalized()
	var projectile = projectile_preload.instantiate()
	projectile.velocity = travel_vec
	projectile.position = spawn_point.global_position
	projectile.rotation = rotation
	projectile.DAMAGE = DAMAGE
	projectile.scale.x = scale.x
	projectile.scale.y = scale.y
	call_deferred("add_sibling", projectile)

	# Play SFX
	if FIRE_SFX:
		SoundManager.play_sound(FIRE_SFX)

	# Add knockback
	knockback += Vector2.from_angle(rotation - PI/2).normalized() * 250

	sprite.play("default")
