class_name TrailComponent
extends Line2D

@export var max_points: int = 100

var queue: Array[Vector2]
var target: Node2D

func _ready() -> void:
	if not target:
		target = get_parent()

func _physics_process(delta: float) -> void:
	var pos = target.global_position
	add_point(pos)
	if get_point_count() > max_points:
		remove_point(0)
