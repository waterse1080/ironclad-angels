class_name NaniteSwarmUpgrade
extends BaseUpgrade

@export var damage: float = 10.0
@export var scale_per_upgrade: float = 0.5
@export var time_between_damage: float = 0.5

var nanite_swarm_controller_preload = load("res://Scenes/Components/nanite_swarm_controller_component.tscn")
var nanite_swarm_controller: NaniteSwarmControllerComponent

func on_add(player: Player) -> void:
	if nanite_swarm_controller == null:
		nanite_swarm_controller = nanite_swarm_controller_preload.instantiate()
		nanite_swarm_controller.player = player
		nanite_swarm_controller.damage = damage
		nanite_swarm_controller.base_timer_duration = time_between_damage
		player.call_deferred("add_child", nanite_swarm_controller)
	else:
		nanite_swarm_controller.call_deferred("modify_damage", damage)
		nanite_swarm_controller.call_deferred("modify_scale", scale_per_upgrade)

func on_remove(_player: Player) -> void:
	pass

func get_description() -> String:
	description = description.replace("$1", str(int(damage)))
	description = description.replace("$2", str(time_between_damage))
	return description
