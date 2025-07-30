class_name SceneTileMapLayer
extends TileMapLayer

#from u/LaenFinehack on 
#https://www.reddit.com/r/godot/comments/10ql0ch/godot_4_does_tilemap_have_a_way_to_retrieve_the/

signal child_registered
#var scene_coords: Dictionary[Vector2i, Node] = {}
var scene_coords: Dictionary = {}

func _enter_tree():
	child_entered_tree.connect(_register_child)
	child_exiting_tree.connect(_unregister_child)

func _register_child(child):
	await child.ready
	var coords = local_to_map(to_local(child.global_position))
	scene_coords[coords] = child
	child.set_meta("tile_coords", coords)
	child_registered.emit(coords)

func _unregister_child(child):
	scene_coords.erase(child.get_meta("tile_coords"))

func get_cell_scene(coords: Vector2i) -> Node:
	return scene_coords.get(coords, null)
