extends BaseUpgrade
class_name RapidFireUpgrade

@export var FIRERATE_INCREASE := 0.75

func on_add(player: Player):
	player.turret.load_time *= FIRERATE_INCREASE

func on_remove(player: Player):
	player.turret.load_time /= FIRERATE_INCREASE

func get_description() -> String:
	description = description.replace("$1", str(int((1-FIRERATE_INCREASE) * 100)))
	description = description.replace("$2", str(int((1-FIRERATE_INCREASE) * 100)))
	return description
