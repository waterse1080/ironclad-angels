class_name WeightedChamberUpgrade
extends BaseUpgrade

@export var bonus_crit_chance: float = 0.05
var next_shot_bonus: float = 0.0

func on_xp_collected(_player: Player) -> void:
	next_shot_bonus += bonus_crit_chance * upgrade_copies_count

func on_fire_add(bullet: ProtoBullet, _player: Player, is_support: bool = false) -> void:
	if is_support:
		return
	bullet.crit_chance += next_shot_bonus
	next_shot_bonus = 0.0

func get_description() -> String:
	description = description.replace("$", str(int(bonus_crit_chance * 100)))
	return description
