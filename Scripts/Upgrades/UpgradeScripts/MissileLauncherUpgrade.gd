extends BaseUpgrade
class_name MissleLauncherUpgrade

var missle_preload = load("res://Scenes/Player/Projectiles/missile.tscn")
var chance_per_copy: float = 0.15

func on_fire(bullet: ProtoBullet, player: Player, is_support: bool = false):
	if bullet is ShellProjectile or is_support:
		return
	var missiles_to_fire: int = 0
	var total_chance: float = chance_per_copy * float(upgrade_copies_count)
	while total_chance > 0.0:
		if randf_range(0.0, 1.0) <= total_chance:
			missiles_to_fire += 1
		total_chance -= 1.0
	#if missiles_to_fire > 0:
		#print("Firing " + str(missiles_to_fire) + " missiles")
	for i in missiles_to_fire:
		var missle = missle_preload.instantiate() as Missile
		missle.position = player.position
		missle.velocity = Vector2.from_angle(randf_range(0, 2 * PI))
		missle.SPREAD = true
		missle.DAMAGE = player.turret.damage
		missle.apply_scale(Vector2(player.turret.missle_scale, player.turret.missle_scale))
		player.call_deferred("add_sibling", missle)

func get_description() -> String:
	description = description.replace("$", str(int(chance_per_copy * 100)))
	return description
