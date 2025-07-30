extends Area2D
class_name TerrainDetectionComponent

enum terrain_types {
	GROUND = 0,
	ROAD = 1,
	ROUGH = 2,
	BUILDING = 3,
}

@export var terrain_speed_mods: Array[float] = [
	1, # Ground
	1.25, # Road
	0.75, # Rough
	1.0 # Building
]

var current_terrain_type: terrain_types = terrain_types.GROUND

func _ready() -> void:
	body_shape_entered.connect(on_body_shape_entered)
	area_entered.connect(on_area_entered)

func get_speed_mod() -> float:
	return terrain_speed_mods[current_terrain_type]

func on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int):
	if body is TileMapLayer:
		var current_tilemap: TileMapLayer = body
		var collided_tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)
		var tile_data = current_tilemap.get_cell_tile_data(collided_tile_coords)
		var terrain_type = tile_data.get_custom_data_by_layer_id(0)
		if terrain_type != current_terrain_type:
			current_terrain_type = terrain_type

func on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent == null:
		return
	if area is HurtBox and parent is DestructibleObject:
		if current_terrain_type != 3:
			current_terrain_type = 3
