class_name TweenComponent
extends Node2D

var target: Node2D
var speed: float = 7.5
var bounce: bool = true
var bounce_time: float = 0.1
var bounce_timer: float = 0.0

func _physics_process(delta: float) -> void:
	var parent = get_parent()
	if is_instance_valid(target) and is_instance_valid(parent):
		if not bounce or bounce_timer >= bounce_time:
			parent.global_position.x = lerpf(parent.global_position.x, target.global_position.x, speed * delta)
			parent.global_position.y = lerpf(parent.global_position.y, target.global_position.y, speed * delta)
		else:
			bounce_timer += delta
			var temp_target = parent.global_position + (parent.global_position - target.global_position).normalized() * 100
			parent.global_position.x = lerpf(parent.global_position.x, temp_target.x, speed * delta)
			parent.global_position.y = lerpf(parent.global_position.y, temp_target.y, speed * delta)
		if target.global_position.distance_to(parent.global_position) <= 10.0:
			set_deferred("target", null)
