class_name IceDebuffUpgrade
extends BaseUpgrade

@export var shatter_percent: float = 0.15
@export var boss_shatter_percent: float = 0.05
@export var duration: float = 5.0
@export var freeze_chance: float = 0.2

var ice_debuff = load("res://Scenes/Debuffs/ice_debuff.tscn")

func enemy_hurt(_damage: int, _crit_level: int, spread_effects: bool, area: HurtBox):
	if spread_effects and randf_range(0.0, 1.0) <= freeze_chance * upgrade_copies_count:
		add_debuff(area)

func add_debuff(area: HurtBox):
	var health_component = area.health_component
	var hit_target = health_component.get_parent()
	for child in hit_target.get_children():
		if child is IceDebuff:
			child.duration_timer = 0.0
			return
	var new_ice: IceDebuff = ice_debuff.instantiate()
	# Apply values
	new_ice.shatter_percent = shatter_percent
	new_ice.boss_shatter_percent = boss_shatter_percent
	new_ice.duration = duration
	new_ice.add_to_target(hit_target, area)

func get_description() -> String:
	description = description.replace("$1", str(int(freeze_chance * 100)))
	description = description.replace("$2", str(int(duration)))
	description = description.replace("$3", str(int(shatter_percent * 100)))
	description = description.replace("$4", str(int(boss_shatter_percent * 100)))
	return description
