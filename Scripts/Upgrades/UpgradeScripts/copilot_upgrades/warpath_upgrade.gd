class_name WarpathUpgrade
extends BaseUpgrade

@export var xp_mult: float = 0.5
@export var choice_mod: int = 2

func on_add(player: Player) -> void:
	player.level_tracker_component.xp_mult += xp_mult
	SignalBus.change_choice_count.emit(choice_mod)

func on_remove(player: Player) -> void:
	player.level_tracker_component.xp_mult -= xp_mult
	SignalBus.change_choice_count.emit(-choice_mod)
