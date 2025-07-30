class_name BomberRun
extends Node2D

@export var bomber_run_sfx: String = "BomberRunSFX"

var explosion_points: Array[Node2D] = []
var explosion_preload = load("res://Scenes/explosion.tscn")

@onready var explosive_points_parent: Node2D = $Sprite2D/ExplosivePointsParent

func _ready() -> void:
	for child in explosive_points_parent.get_children():
		if child.is_in_group("explosive_spawn_point"):
			explosion_points.append(child)
	rotation_degrees = randf_range(0.0, 360.0)
	if bomber_run_sfx:
		SoundManager.play_sound(bomber_run_sfx)

func spawn_bombs() -> void:
	for point in explosion_points:
		var explosion = explosion_preload.instantiate() as Explosion
		explosion.global_position = point.global_position
		explosion.DAMAGE = 50.0
		explosion.boss_dmg_mult = 0.1
		explosion.SPREAD = false
		call_deferred("add_sibling", explosion)

func anim_end() -> void:
	call_deferred("queue_free")
