extends CharacterBody2D
class_name ProtoBullet

signal bullet_destroyed
signal hurtbox_damaged

# Base Values
@export var DAMAGE := 10.0
@export var PIERCE_COUNT := 1
@export var CRIT_CHANCE := 0.05
@export var CRIT_MULT := 2.0
@export var SPEED := 200.0
@export var SPREAD := true
@export var IMPACT_SFX: String
@export var TIME_UNTIL_CLEANUP := 1.0
@export var KNOCKBACK_POWER := 500.0
@export var hit_scale_mult: float = 5.0

# Active Values
var damage: float
var pierce_count: int
var crit_chance: float
var crit_mult: float
var speed: float
var knockback: float

var despawn_timer := 0.0
var enemy_list: Array[HurtBox] = []
var is_copy := false

var tracking_keys: Dictionary = {}

var hit_explosion = load("res://Scenes/Particles/bullet_hit_explosion.tscn")

@onready var collision_shape = $HitBox/CollisionShape2D as CollisionShape2D

func _ready():
	if is_copy:
		return
	damage = DAMAGE
	pierce_count = PIERCE_COUNT
	crit_chance = CRIT_CHANCE
	crit_mult = CRIT_MULT
	speed = SPEED
	knockback = KNOCKBACK_POWER
	self.velocity *= speed
	SignalBus.bullet_spawned.emit(self)
	_on_ready()

func _on_ready() -> void:
	pass

func copy_values(other: ProtoBullet):
	is_copy = true
	damage = other.damage
	pierce_count = other.pierce_count
	crit_chance = other.crit_chance
	crit_mult = other.crit_mult
	speed = other.speed
	knockback = other.knockback
	tracking_keys = other.tracking_keys.duplicate(true)
	self.velocity = other.velocity
	self.position = other.global_position
	self.rotation = other.rotation
	SignalBus.bullet_spawned.emit(self)
	_on_ready()

func _physics_process(delta):
	move_and_slide()
	despawn_timer += delta
	if despawn_timer >= TIME_UNTIL_CLEANUP:
		call_deferred("queue_free")

# Get crit/damage. Multiply several times if crit chance is high enough
func determineCrit():
	var dmg := damage
	var chance := crit_chance
	var crit_level := 0
	var rand = randf_range(0, 1)
	while chance >= rand:
		chance -= 1
		crit_level += 1
	if crit_level > 0:
		dmg *= (crit_mult * crit_level)
	return {"dmg": dmg, "crit_level": crit_level}

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		# Ignore duplicate hits
		if enemy_list.find(area) == -1:
			# Apply damage
			var critInfo = determineCrit()
			area.damage(critInfo.dmg, critInfo.crit_level)
			if "knockback" in area.get_parent():
				area.get_parent().knockback = velocity.normalized() * knockback # maybe change to +=
			enemy_list.append(area)
			hurtbox_damaged.emit(area)
			SignalBus.enemy_hurt.emit(critInfo.dmg, critInfo.crit_level, SPREAD, area)
			SignalBus.bullet_hit_target.emit(self)
			# Play SFX
			if IMPACT_SFX:
				SoundManager.play_sound(IMPACT_SFX)
			# Destroy
			play_hit_effect()
			if enemy_list.size() >= pierce_count:
				bullet_destroyed.emit()
				self.queue_free()

func play_hit_effect() -> void:
	var bullet_explosion = hit_explosion.instantiate()
	bullet_explosion.global_position = global_position
	bullet_explosion.scale = scale * hit_scale_mult
	add_sibling(bullet_explosion)
