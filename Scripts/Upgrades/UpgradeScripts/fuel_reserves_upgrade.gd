class_name FuelReservesUpgrade
extends BaseUpgrade

@export var boost_duration_increase: float = 1.0

func on_add(player: Player) -> void:
	player.body.boost_duration_max += boost_duration_increase

func on_remove(player: Player) -> void:
	player.body.boost_duration_max -= boost_duration_increase

func get_description() -> String:
	description = description.replace("$", str(int(boost_duration_increase)))
	return description
