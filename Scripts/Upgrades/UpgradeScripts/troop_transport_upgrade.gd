class_name TroopTransportUpgrade
extends BaseUpgrade

@export var spawn_time: float = 1.0
@export var troop_count_max: int = 5

var troop_spawner_preload = load("res://Scenes/Components/troop_spawner_component.tscn")
var troop_spawner: TroopSpawnerComponent

func on_add(player: Player) -> void:
	if troop_spawner == null:
		troop_spawner = troop_spawner_preload.instantiate()
		troop_spawner.base_timer_duration = spawn_time
		troop_spawner.player = player
		troop_spawner.troop_count_max = troop_count_max
		player.call_deferred("add_child", troop_spawner)
	else:
		troop_spawner.troop_count_max += troop_count_max

func on_remove(_player: Player) -> void:
	pass

func get_description() -> String:
	description = description.replace("$1", str(int(spawn_time)))
	description = description.replace("$2", str(int(troop_count_max)))
	return description
