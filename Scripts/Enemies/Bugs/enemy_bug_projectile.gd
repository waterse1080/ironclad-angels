extends CharacterBody2D
class_name EnemyProjectile

# Base Values
@export var DAMAGE := 10.0
@export var SPEED := 200.0
@export var IMPACT_SFX: String
@export var TIME_UNTIL_CLEANUP := 1.0

var despawn_timer := 0.0

@onready var collision_shape = $HitBox/CollisionShape2D as CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	velocity *= SPEED

func _physics_process(delta):
	move_and_slide()
	despawn_timer += delta
	if despawn_timer >= TIME_UNTIL_CLEANUP:
		call_deferred("queue_free")

func play_anim(anim: String) -> void:
	sprite.play(anim)

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		area.damage(DAMAGE, 0)
		# Play SFX
		if IMPACT_SFX:
			SoundManager.play_sound(IMPACT_SFX)
		# Destroy
		queue_free()
