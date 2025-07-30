class_name DestructibleObject
extends Node2D

@export var destruction_sfx: Array[String] = [
	"BuildingDestroySFX",
	"BuildingDestroySFX2",
	"BuildingDestroySFX3"
	]
@export var shake_dist_min: float = 200.0
@export var shake_dist_max: float = 1000.0

var rubble_tile: Vector2i = Vector2i(0, 0)
var tile_location: Vector2i = Vector2i(0, 0)
var map: SceneTileMapLayer
var dmg_particles = load("res://Scenes/Particles/building_damage_particles.tscn")

@onready var hurt_box = $HurtBox as HurtBox
@onready var static_body = $StaticBody2D as StaticBody2D
@onready var static_collider = $StaticBody2D/CollisionPolygon2D as CollisionPolygon2D
@onready var sprite = $Sprite2D as Sprite2D
@onready var health_component = $HealthComponent as HealthComponent
@onready var damage_num_origin = $DamageNumbersOrigin as Node2D
@onready var vibration_intensity_setting = preload(
	"res://game_settings/setting_vibration_intensity.tres"
	)
@onready var shaker: ShakerComponent2D = $Sprite2D/ShakerComponent2D

func _ready() -> void:
	health_component.health_depleted.connect(destroy)
	health_component.hurt.connect(on_health_component_hurt)
	hurt_box.body_shape_entered.connect(on_body_shape_entered)
	hurt_box.area_entered.connect(on_area_entered)
	shaker.process_mode = Node.PROCESS_MODE_DISABLED

func set_sprite(tileset: TileSet, location: Vector2i) -> void:
	#print(tileset.get_source(0))
	#sprite.texture = tileset.get_source(0) #may not work as intended
	#sprite.region_enabled = true
	var size: Vector2i = tileset.tile_size
	sprite.region_rect = Rect2(location[0] * size[0], location[1] * size[1], size[0], size[1])

# get the polygon data directly from the tile
func set_hitbox(tile_data: TileData) -> void:
	var polygon = tile_data.get_collision_polygon_points(0, 0)
	if polygon.size() > 0:
		static_collider.set_polygon(polygon)

func destroy() -> void:
	SoundManager.play_sound(destruction_sfx.pick_random())
	var cameras = get_tree().get_nodes_in_group("camera")
	var players = get_tree().get_nodes_in_group("player")
	var dist := 0.0
	for player in players:
		dist = global_position.distance_to(player.global_position)
		if dist > shake_dist_max:
			dist = shake_dist_max
		elif dist < shake_dist_min:
			dist = shake_dist_min
	var mult = (shake_dist_max - dist) / (shake_dist_max - shake_dist_min)
	for camera in cameras:
		if camera and camera.has_method("apply_shake"):
				camera.apply_shake(5.0 * mult)
	var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
	Input.start_joy_vibration(0, 0.5 * v_mult * mult, 0.7 * v_mult * mult, 0.2)
	map.set_cell(tile_location, 0, rubble_tile)
	var particles = dmg_particles.instantiate() as PersistentParticleTrail
	particles.global_position = global_position
	get_tree().root.add_child(particles)
	call_deferred("queue_free")

func on_health_component_hurt(dmg: float, crit_level: int, _blood: bool):
	DamageNumbers.display_number(ceili(dmg), damage_num_origin.global_position, crit_level)
	shaker.process_mode = Node.PROCESS_MODE_INHERIT
	shaker.force_stop_shake()
	shaker.play_shake()

func on_body_shape_entered(
	_body_rid: RID,
	body: Node2D,
	_body_shape_index: int,
	_local_shape_index: int
	) -> void:
	if body is Player and body.body.can_destroy_terrain:
		static_collider.set_deferred("disabled", true)
		destroy()

func on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is not PlayerBody:
		return
	if area is HurtBox and parent.can_destroy_terrain:
		static_collider.set_deferred("disabled", true)
		destroy()
