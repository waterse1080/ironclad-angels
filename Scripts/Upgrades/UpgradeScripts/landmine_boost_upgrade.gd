class_name LandmineBoostUpgrade
extends BaseUpgrade

@export var ready_timer: float = 1.0
@export var timer_mult: float = 0.75

var landmine_component: LandmineBoostComponent
var landmine_component_preload = load("res://Scenes/Components/landmine_boost_component.tscn")

func on_add(player: Player) -> void:
	if landmine_component == null:
		landmine_component = landmine_component_preload.instantiate()
		landmine_component.time_to_ready = ready_timer
		landmine_component.player = player
		player.call_deferred("add_child", landmine_component)
	else:
		landmine_component.time_to_ready *= timer_mult

func on_remove() -> void:
	pass

func get_description() -> String:
	description = description.replace("$1", str(int(ready_timer)))
	description = description.replace("$2", str(int((1.0 - timer_mult)*100)))
	return description
