class_name BaseUpgrade
extends Resource
# Order matters, add new enums at the bottom, double check all upgrade tags if removing any
enum UpgradeTag {
	DAMAGE,
	CRIT,
	PROJECTILE_SCALE,
	PROJECTILE_SPEED,
	BOUNCE,
	PIERCE,
	MAGAZINE_SIZE,
	KNOCKBACK,
	RATE_OF_FIRE,
	RELOAD_SPEED,
	PROJECTILE_COUNT,
	BOOST,
	HEALTH,
	SPEED,
	PICKUP_RANGE,
	XP,
	FIRE,
	SUPPORT,
	DRONE,
	LIGHTNING,
	MISSILE,
	EXPLOSION,
	INFANTRY,
	DEBUFF,
	ICE,
}

@export_multiline var name : String = ""
@export_multiline var description : String = ""
@export var icon_row_column: Vector2i = Vector2i.ZERO
@export var upgrade_tags: Array[UpgradeTag] = []
@export var required_tags: Array[UpgradeTag] = []
@export var max_upgrade_count: int = -1 # Exotic/limited upgrades
var upgrade_copies_count: int = 0

func adjust_copies_count(mod: int) -> void:
	upgrade_copies_count += mod
	print(name + ": " + str(upgrade_copies_count))

func is_available(player: Player) -> bool:
	var available = true
	# Check tags
	if required_tags.size() > 0:
		for tag in required_tags:
			var tag_found = false
			for upgrade in player.upgrades:
				for u_tag in upgrade.upgrade_tags:
					if u_tag == tag:
						tag_found = true
			if not tag_found:
				return false
	# Check max upgrade count
	if max_upgrade_count > -1 and upgrade_copies_count >= max_upgrade_count:
		return false
	return true

func get_description() -> String:
	return description
