class_name PillBugEnemy
extends ProtoEnemy

@export var roll_cooldown: float = 5.0
@export var roll_duration: float = 1.0
@export var roll_speed_mult: float = 2.0
@export var roll_turn_speed_mult: float = 0.1
@export var roll_start_distance: float = 200.0

var cooldown_timer: float = 0.0
var duration_timer: float = 0.0
var is_rolling: bool = false
var roll_ready: bool = true

@onready var walk_hitbox_collider: CollisionShape2D = $HitBox_walk/CollisionShape2D
@onready var walk_hurtbox_collider: CollisionShape2D = $HurtBox_walk/CollisionShape2D
@onready var roll_hitbox_collider: CollisionShape2D = $HitBox_roll/CollisionShape2D
@onready var roll_hurtbox_collider: CollisionShape2D = $HurtBox_roll/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	# Move towards player
	var our_pos = global_position
	var travel_vec = (player.global_position- our_pos).normalized()
	var target_angle = travel_vec.angle() - PI / 2
	if rotation > target_angle + PI:
		target_angle += 2 * PI
	elif target_angle > rotation + PI:
		target_angle -= 2 * PI
	
	var turn_speed = turn_speed_mult
	var speed = SPEED
	if is_rolling:
		turn_speed *= roll_turn_speed_mult
		speed *= roll_speed_mult
	rotation = lerpf(rotation, target_angle, delta * turn_speed)
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not player:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	else:
		velocity = Vector2.DOWN.rotated(rotation) * speed
	velocity = velocity + knockback * 0.5
	move_and_slide()
	knockback = knockback.lerp(Vector2.ZERO, 0.1)

	if is_rolling:
		duration_timer += delta
		if duration_timer >= roll_duration:
			set_roll(false)
			duration_timer = 0.0
	elif not roll_ready:
		cooldown_timer += delta
		if cooldown_timer >= roll_cooldown:
			roll_ready = true
			cooldown_timer = 0.0
	elif player.global_position.distance_to(our_pos) <= roll_start_distance:
		set_roll(true)
		roll_ready = false

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		if ATTACK_HIT_SFX:
			SoundManager.play_sound(ATTACK_HIT_SFX)
		area.damage(DAMAGE, 0)
		if not is_rolling:
			knockback += (area.global_position.direction_to(global_position)).normalized() * SELF_KNOCKBACK
			collision_shape.set_deferred("disabled", true)
			await get_tree().create_timer(0.5).timeout
			collision_shape.set_deferred("disabled", is_rolling)

func set_roll(roll: bool) -> void:
	if is_rolling == roll:
		print("roll state already matches")
		return
	is_rolling = roll
	sprite.play("roll" if is_rolling else "walk")
	walk_hitbox_collider.set_deferred("disabled", is_rolling)
	walk_hurtbox_collider.set_deferred("disabled", is_rolling)
	roll_hitbox_collider.set_deferred("disabled", !is_rolling)
	roll_hurtbox_collider.set_deferred("disabled", !is_rolling)
	collision_shape.set_deferred("disabled", is_rolling)
