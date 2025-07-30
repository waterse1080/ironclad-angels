class_name AnalysisUpgrade
extends BaseUpgrade

@export var xp_mult: float = 0.20

func on_add(player: Player) -> void:
	player.level_tracker_component.xp_mult += xp_mult

func on_remove(player: Player) -> void:
	player.level_tracker_component.xp_mult -= xp_mult

func get_description() -> String:
	return description.replace("$", str(int(xp_mult * 100)))
