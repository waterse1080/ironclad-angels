class_name NitroBoostUpgrade
extends BaseUpgrade

@export var boost_speed_increase: float = 50.0

func on_add(player: Player) -> void:
	player.body.boost_speed += boost_speed_increase

func on_remove(player: Player) -> void:
	player.body.boost_speed -= boost_speed_increase

func get_description() -> String:
	description = description.replace("$", str(int(boost_speed_increase)))
	return description
