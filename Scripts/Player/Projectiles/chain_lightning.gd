class_name ChainLightning
extends Node2D

@export var lightning_sfx: Array[String] = [
	"LightningSFX1",
	"LightningSFX2",
	"LightningSFX3",
	"LightningSFX4",
	"LightningSFX5",
	"LightningSFX6",
	]

var tracking_target: Node2D
var tracking_origin: Node2D
var target_point: Vector2
var ignore_list: Array[Node2D] = []
var lifetime: float = 0.25
var despawn_timer: float = 0.0
var height: float = 320.0
var lightning_chance_mult: float = 0.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	despawn_timer += delta
	if despawn_timer >= lifetime:
		call_deferred("queue_free")
		return

	if tracking_origin != null:
		global_position = tracking_origin.global_position
	if tracking_target != null:
		target_point = tracking_target.global_position
	if target_point != null:
		rotation = global_position.angle_to_point(target_point)
		var dist: float = global_position.distance_to(target_point)
		sprite.scale.y = (dist / height) * 5.0
		sprite.scale.x = 5.0

func chain_to_target(target: Node2D, origin: Node2D, damage: float, chain_chance: float) -> void:
	SoundManager.play_sound(lightning_sfx.pick_random())
	tracking_target = target
	tracking_origin = origin
	if target == null:
		target = find_chain_target(ignore_list)
		if target == null:
			return
	var health_component: HealthComponent = target.find_child("HealthComponent")
	if health_component:
		health_component.damage(damage, 0)
	#else:
		#print("Health component not found")
	if randf_range(0.0, 1.0) <= chain_chance:
		chain_chance *= lightning_chance_mult
		ignore_list.append(target)
		var new_target = find_chain_target(ignore_list)
		if new_target == null:
			return

		var clone: ChainLightning = duplicate()
		add_sibling(clone)
		clone.ignore_list = ignore_list.duplicate()
		clone.global_position = target.global_position
		clone.chain_to_target(new_target, target, damage, chain_chance)

func find_chain_target(exclude_list: Array[Node2D]) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies") # May not work on first creation
	if enemies.size() == 0:
		#print("No enemies to chain to")
		return null

	var valid_enemies: Array[ProtoEnemy] = []
	for enemy in enemies:
		var valid = true
		for exluded in exclude_list:
			if is_instance_valid(exluded) and is_instance_valid(enemy) and exluded == enemy:
				valid = false
		if valid:
			valid_enemies.append(enemy)
	if valid_enemies.size() == 0:
		#print("No valid chain targets")
		return null

	var closest_enemy: ProtoEnemy = valid_enemies.pick_random()
	var closest_dist = closest_enemy.global_position.distance_to(global_position)
	for enemy in valid_enemies:
		var dist = enemy.global_position.distance_to(global_position)
		if dist < closest_dist:
			closest_enemy = enemy
			closest_dist = dist

	return closest_enemy
