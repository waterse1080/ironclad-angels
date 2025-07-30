extends CharacterBody2D
class_name  ProtoEnemy

@export var SPEED = 200.0
@export var DAMAGE := 10.0
@export var HEALTH_MOD := 1.0
@export var SELF_KNOCKBACK := 1000.0
@export var KNOCKBACK_LERP := 0.1
@export var DEATH_SFX: String
@export var ATTACK_HIT_SFX: String
@export var turn_speed_mult: float = 5.0

var player: Player
var knockback := Vector2.ZERO
var blood_particles = load("res://Scenes/Particles/alien_blood_particles.tscn")
var table = DropTable.TABLES.ENEMY

@onready var terrain_detection_component: TerrainDetectionComponent = $TerrainDetectionComponent 
@onready var damage_num_origin = $DamageNumbersOrigin
@onready var health_component: HealthComponent = $HealthComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	health_component.max_health *= HEALTH_MOD
	health_component.health *= HEALTH_MOD
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# Move towards player
	var our_pos = get_position()
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not player:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		return
	var travel_vec = (player.get_position() - our_pos).normalized()
	var target_angle = travel_vec.angle() - PI / 2
	if rotation > target_angle + PI:
		target_angle += 2 * PI
	elif target_angle > rotation + PI:
		target_angle -= 2 * PI
	rotation = lerpf(rotation, target_angle, delta * turn_speed_mult)
	var detection_speed: float = terrain_detection_component.get_speed_mod()
	velocity = Vector2.DOWN.rotated(rotation) * detection_speed * SPEED + knockback
	move_and_slide()
	knockback = knockback.lerp(Vector2.ZERO, KNOCKBACK_LERP)

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		if ATTACK_HIT_SFX:
			SoundManager.play_sound(ATTACK_HIT_SFX)
		area.damage(DAMAGE, 0)
		knockback += (area.global_position.direction_to(global_position)).normalized() * SELF_KNOCKBACK
		collision_shape.set_deferred("disabled", true)
		await get_tree().create_timer(0.5).timeout
		collision_shape.set_deferred("disabled", false)

func _on_health_component_health_depleted():
	DropTable.drop_rand_pickup(
		get_tree(),
		global_position,
		health_component.max_health / 10.0,
		table
	)

	# Play Death SFX
	if DEATH_SFX:
		SoundManager.play_sound(DEATH_SFX)
	SignalBus.enemy_destroyed.emit(position)
	var particles = blood_particles.instantiate() as AlienBloodParticles
	particles.attatch(self)
	particles.amount = 40
	particles.scale = scale
	queue_free()

func _on_health_component_hurt(dmg: float, crit_level: int, blood: bool):
	if crit_level < 0:
		return
	DamageNumbers.display_number(ceili(dmg), damage_num_origin.global_position, crit_level)
	if blood:
		var particles = blood_particles.instantiate() as AlienBloodParticles
		particles.attatch(self)
		particles.scale = scale
