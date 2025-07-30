class_name Explosion
extends Node2D

signal hurtbox_damaged

@export var explosion_sfx: Array[String] = [
	"MissileExplosionSFX",
	"MissileExplosionSFX2",
	"MissileExplosionSFX3",
	]
@export var DAMAGE := 100.0
@export var SPREAD := false
@export var SHAKE := 5.0
@export var explosion_texture: Texture2D
@export var shake_dist_min: float = 200.0
@export var shake_dist_max: float = 1000.0
@export var boss_dmg_mult: float = 1

var enemy_list: Array[HurtBox] = []
var active_masks: Array[int] = []
var inactive_masks: Array[int] = []

@onready var hitbox = $HitBox as HitBox
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	SoundManager.play_sound(explosion_sfx.pick_random())
	for mask in active_masks:
		hitbox.set_collision_mask_value(mask, true)
	for mask in inactive_masks:
		hitbox.set_collision_mask_value(mask, false)
	var cameras = get_tree().get_nodes_in_group("camera")
	var players = get_tree().get_nodes_in_group("player")
	var dist := 0.0
	for player in players:
		dist = position.distance_to(player.position)
		if dist > shake_dist_max:
			dist = shake_dist_max
		elif dist < shake_dist_min:
			dist = shake_dist_min
	var mult = (shake_dist_max - dist) / (shake_dist_max - shake_dist_min)

	for camera in cameras:
		if camera and camera.has_method("apply_shake"):
				camera.apply_shake(SHAKE * mult)

	if explosion_texture:
		sprite.texture = explosion_texture

	sprite.flip_h = randi_range(0, 1)
	sprite.flip_v = randi_range(0, 1)
	sprite.rotation_degrees = 90 * randi_range(0, 3)

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		# Ignore duplicate hits
		if enemy_list.find(area) == -1:
			# Apply damage
			var parent = area.get_parent()
			if parent and parent.is_in_group("bosses"):
				area.damage(DAMAGE * boss_dmg_mult, 0)
			else:
				area.damage(DAMAGE, 0)
			enemy_list.append(area)
			hurtbox_damaged.emit(area)
			SignalBus.enemy_hurt.emit(DAMAGE, 0, SPREAD, area)
