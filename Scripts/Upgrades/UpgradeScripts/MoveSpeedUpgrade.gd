extends BaseUpgrade
class_name MoveSpeedUpgrade

@export var SPEED_INCREASE := 50.0

func on_add(player: Player):
	player.body.move_speed += SPEED_INCREASE

func on_remove(player: Player):
	player.body.move_speed -= SPEED_INCREASE

func get_description() -> String:
	description = description.replace("$", str(int(SPEED_INCREASE)))
	return description
