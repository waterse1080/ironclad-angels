class_name ChainLightningUpgrade
extends BaseUpgrade

var lightning_preload = load("res://Scenes/Player/Projectiles/chain_lightning.tscn")
var chance_per_copy: float = 0.1

func on_bullet_hit_target(bullet: ProtoBullet):
	#if bullet is ShellProjectile:
		#return
	var total_chance: float = chance_per_copy * float(upgrade_copies_count)
	if randf_range(0.0, 1.0) > total_chance:
		return

	var origin = bullet.enemy_list.back()
	if origin == null:
		print("Origin missing")
		return
	var origin_parent = origin.get_parent()
	if origin_parent.is_in_group("enemies"):
		origin = origin_parent
	else:
		# Don't trigger off of buildings
		return
	var lightning = lightning_preload.instantiate() as ChainLightning
	bullet.add_sibling(lightning)
	lightning.global_position = origin.global_position
	lightning.ignore_list.append(origin)
	var target = lightning.find_chain_target([origin])
	var bounce_chance = total_chance * lightning.lightning_chance_mult
	lightning.chain_to_target(target, origin, bullet.damage, bounce_chance)

func get_description() -> String:
	description = description.replace("$", str(int(chance_per_copy * 100)))
	return description
