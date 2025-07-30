extends Node2D
class_name OrbitController

@export var orbit_id: String
@export var orbit_obj_list: Array[Node2D]
@export var orbit_distance := 200.0
@export var orbit_speed := 10.0

func _ready() -> void:
	set_orbit_positions()

func _physics_process(delta: float) -> void:
	rotation += (delta * orbit_speed)
	for obj in orbit_obj_list:
		obj.rotation = -rotation

func add_orbit_obj(obj: Node2D) -> void:
	add_child(obj)
	orbit_obj_list.append(obj)
	set_orbit_positions()

func remove_orbit_obj(_obj: Node2D) -> void:
	pass #TODO if needed later

func set_orbit_positions() -> void:
	var count = orbit_obj_list.size()
	var angle = 2 * PI / count
	for i in count:
		var obj = orbit_obj_list[i]
		obj.position = Vector2.from_angle(angle * i) * orbit_distance
