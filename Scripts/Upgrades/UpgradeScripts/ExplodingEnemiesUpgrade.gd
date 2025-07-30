extends BaseUpgrade
class_name ExplodingEnemiesUpgrade

var explosion_damage := 50.0
var spread := true
var chance_per_copy := 0.2

var explosion_preload = load("res://Scenes/explosion.tscn")

func on_enemy_destroyed(positon: Vector2, player: Player):
	var explosion_level: int = 0
	var total_chance: float = chance_per_copy * float(upgrade_copies_count)
	while total_chance > 0.0:
		if randf_range(0.0, 1.0) <= total_chance:
			explosion_level += 1
		total_chance -= 1.0
	if explosion_level > 0:
		var explosion = explosion_preload.instantiate() as Explosion
		explosion.DAMAGE = explosion_damage * explosion_level
		explosion.scale.x = float(explosion_level)
		explosion.scale.y = float(explosion_level)
		explosion.SPREAD = spread
		explosion.position = positon
		player.call_deferred("add_sibling", explosion)

func filter_upgrades(upgrade: BaseUpgrade):
	return upgrade is ExplodingEnemiesUpgrade

func get_description() -> String:
	description = description.replace("$", str(int(chance_per_copy * 100)))
	return description
