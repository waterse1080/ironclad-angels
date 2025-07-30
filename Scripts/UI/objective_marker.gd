class_name ObjectiveMarker
extends Control

@export var target: Node2D
@export var radius: float = 100.0

func set_target(new_target: Node2D) -> void:
	target = new_target
