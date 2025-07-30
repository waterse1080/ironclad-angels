class_name PassiveRepairUpgrade
extends BaseUpgrade

@export var heal_time: float = 1.0
@export var heal_amount: float = 5.0

var repair_component_preload = load("res://Scenes/Components/passive_repair_component.tscn")

var repair_component: PassiveRepairComponent

func on_add(player: Player) -> void:
	if repair_component == null:
		repair_component = repair_component_preload.instantiate()
		repair_component.heal_amount = heal_amount
		repair_component.base_timer_duration = heal_time
		repair_component.health_component = player.body.health_component
		player.call_deferred("add_child", repair_component)
	else:
		repair_component.heal_amount += heal_amount

func on_remove(player: Player) -> void:
	pass

func get_description() -> String:
	description = description.replace("$1", str(int(heal_amount)))
	description = description.replace("$2", str(int(heal_time)))
	return description
