class_name Landmine
extends Node2D

var explosion_preload = load("res://Scenes/explosion.tscn")
@onready var hit_box: HitBox = $HitBox

func _ready() -> void:
	hit_box.hitbox_triggered.connect(explode)

func explode(_area: Area2D) -> void:
	var explosion: Explosion = explosion_preload.instantiate()
	explosion.global_position = global_position
	explosion.scale = scale
	call_deferred("add_sibling", explosion)
	call_deferred("queue_free")
