class_name Missile
extends CharacterBody2D

# Base Values
@export var LAUNCH_SFX: String
@export var DAMAGE := 10.0
@export var SPREAD := false
@export var SPEED := 400.0
@export var TIME_UNTIL_CLEANUP := 3.0
@export var TURN_SPEED := 10.0

# Active Values
var damage: float
var speed: float

var despawn_timer := 0.0
var target: Node2D

var smoke_particles = load("res://Scenes/Particles/smoke_particles.tscn")
var explosion_preload = load("res://Scenes/explosion.tscn")

func _ready():
	damage = DAMAGE
	speed = SPEED
	self.velocity *= speed

	var particles = smoke_particles.instantiate() as SmokeParticles
	particles.attatch(self)
	particles.scale_amount_max *= scale.x
	particles.emitting = true

	if LAUNCH_SFX:
		SoundManager.play_sound(LAUNCH_SFX)

	find_target()
	SignalBus.missile_spawned.emit(self)

func explode():
	var explosion = explosion_preload.instantiate()
	explosion.position = position
	explosion.scale = scale
	explosion.DAMAGE = DAMAGE
	explosion.SPREAD = SPREAD
	call_deferred("add_sibling", explosion)
	call_deferred("queue_free")

func find_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		target = enemies.pick_random()

func _physics_process(delta):
	if target != null and target.global_position != null:
		var our_pos = self.global_position
		var travel_vec = (target.global_position - our_pos).normalized() * speed
		velocity.x = lerpf(velocity.x, travel_vec.x, delta * TURN_SPEED)
		velocity.y = lerpf(velocity.y, travel_vec.y, delta * TURN_SPEED)
		velocity = velocity.normalized() * speed
	else:
		find_target()

	self.rotation = velocity.angle() + PI / 2
	move_and_slide()
	despawn_timer += delta
	if despawn_timer >= TIME_UNTIL_CLEANUP:
		explode()

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		# Play SFX
		#if IMPACT_SFX:
			#SoundManager.play_sound(IMPACT_SFX)
		explode()
