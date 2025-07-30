class_name NaniteSwarmControllerComponent
extends BaseTimedComponent

var player: Player
var damage: float = 10.0
var nanite_swarm_2d_preload = load("res://Scenes/Components/nanite_swarm_2d_component.tscn")
var nanite_2d: NaniteSwarm2DComponent

func _ready() -> void:
	nanite_2d = nanite_swarm_2d_preload.instantiate()
	nanite_2d.global_position = player.global_position
	nanite_2d.player = player
	nanite_2d.damage = damage
	nanite_2d.show_behind_parent = true
	player.call_deferred("add_child", nanite_2d)
	nanite_2d.set_deferred("global_position", player.global_position)
	call_deferred("start_timer")

func on_timer_complete() -> void:
	if nanite_2d:
		nanite_2d.disable_hitbox()

func modify_damage(mod: float) -> void:
	damage += mod
	nanite_2d.damage = damage

func modify_scale(mod: float) -> void:
	nanite_2d.scale.x += mod
	nanite_2d.scale.y += mod

func remove() -> void:
	nanite_2d.call_deferred("queue_free")
