class_name ObjectiveMarkerManager
extends Control

var camera: Camera2D
var objective_markers: Array[ObjectiveMarker] = []
var objective_marker_preload = load("res://Scenes/UI/objective_marker.tscn")

func _ready() -> void:
	if not camera:
		camera = get_tree().get_first_node_in_group("camera")
	SignalBus.add_objective_marker.connect(add_marker)

func _physics_process(delta: float) -> void:
	if not camera:
		return
	var index: int = -1
	var closest_marker: ObjectiveMarker
	var closest_dist: float = 9999999.0
	for marker in objective_markers:
		index += 1
		if marker == null:
			continue
		if marker.target == null:
			call_deferred("remove_marker", index)
			continue
		var target_pos: Vector2 = marker.target.global_position
		var camera_pos: Vector2 = camera.get_screen_center_position()
		var dist = target_pos.distance_to(camera_pos)
		if closest_dist > dist:
			closest_dist = dist
			closest_marker = marker
		var margins: Vector2 = (get_viewport_rect().size - Vector2.ONE * marker.radius)
		var offscreen: bool = (
			target_pos.x < camera_pos.x - margins.x/2 / camera.zoom.x
			or target_pos.x > camera_pos.x + margins.x/2 / camera.zoom.x
			or target_pos.y < camera_pos.y - margins.y/2 / camera.zoom.x
			or target_pos.y > camera_pos.y + margins.y/2 / camera.zoom.x
		)
		target_pos = (target_pos - camera_pos) * camera.zoom.x + get_viewport_rect().size / 2.0;
		var new_target = target_pos
		target_pos.x = clamp(target_pos.x, marker.radius, margins.x);
		target_pos.y = clamp(target_pos.y, marker.radius, margins.y);
		marker.set_global_position(target_pos)
		marker.visible = offscreen
		if offscreen:
			marker.rotation = target_pos.angle_to_point(new_target) - PI / 2
		else:
			marker.rotation = 0.0
	for marker in objective_markers:
		if marker != closest_marker and marker != null:
			marker.visible = false

func add_marker(new_target: Node2D) -> void:
	var new_marker: ObjectiveMarker = objective_marker_preload.instantiate()
	new_marker.set_target(new_target)
	call_deferred("set_up_marker", new_marker)

func remove_marker(index: int) -> void:
	var marker = objective_markers[index]
	marker.queue_free()

func set_up_marker(new_marker: ObjectiveMarker) -> void:
	add_child(new_marker)
	objective_markers.append(new_marker)
