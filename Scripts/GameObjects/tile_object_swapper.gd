class_name TileObjectSwapper
extends Node

@export var map_gen: WFC2DGenerator
@export var map: SceneTileMapLayer
@export var bg_map: TileMapLayer
@export var objective_count: int = 4
@export var objective_object_atlas: Vector2i = Vector2i(1, 4)

var bg_tile_coords: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(0, 1),
	Vector2i(1, 1),
]

# [coords, tile_data]
var tile_data_list: Dictionary = {}
# [coords, atlas_coords]
var tile_atlas_coord_list: Dictionary = {}

func _ready() -> void:
	map_gen.done.connect(on_map_gen_done)
	map.child_registered.connect(on_map_child_registered)
	swap_bg_tiles()

func swap_bg_tiles() -> void:
	var atlas_index = RunDataManager.current_loop % bg_tile_coords.size()
	var atlas_coords = bg_tile_coords[atlas_index]
	print(atlas_coords)
	for tile_pos in bg_map.get_used_cells():
		bg_map.set_cell(tile_pos, 2, atlas_coords)

func on_map_gen_done() -> void:
	var empty_tiles: Array[Vector2i] = []
	for tile_pos in map.get_used_cells():
		var tile_data = map.get_cell_tile_data(tile_pos)
		var obj_index = tile_data.get_custom_data_by_layer_id(2)
		if obj_index[0] != 0:
			tile_data_list[tile_pos] = tile_data
			tile_atlas_coord_list[tile_pos] = map.get_cell_atlas_coords(tile_pos)
			map.set_cell(tile_pos, obj_index[0], Vector2i(0, 0), obj_index[1])
		elif map_gen.rect.has_point(tile_pos) and map.get_cell_atlas_coords(tile_pos) == Vector2i(0, 0):
			empty_tiles.append(tile_pos)
	for i in objective_count + RunDataManager.current_loop:
		# Spawn in objectives at random locations
		if empty_tiles.size() < 1:
			print("Ran out of empty space, no more objectives...")
			return
		var rand_pos = empty_tiles.pick_random()
		var tile_data = map.get_cell_tile_data(rand_pos)
		tile_data_list[rand_pos] = tile_data
		tile_atlas_coord_list[rand_pos] = map.get_cell_atlas_coords(rand_pos)
		map.set_cell(rand_pos, objective_object_atlas[0], Vector2i(0, 0), objective_object_atlas[1])

func on_map_child_registered(coords: Vector2i) -> void:
	var tile_data = tile_data_list[coords]
	var tile_atlas_coords = tile_atlas_coord_list[coords]
	var tile_scene: DestructibleObject = map.get_cell_scene(coords)
	tile_scene.tile_location = coords
	tile_scene.rubble_tile = tile_data.get_custom_data_by_layer_id(1)
	tile_scene.map = map
	tile_scene.set_hitbox(tile_data)
	tile_scene.set_sprite(map.tile_set, tile_atlas_coords)
