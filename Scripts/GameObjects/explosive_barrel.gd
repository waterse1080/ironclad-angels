class_name ExplosiveBarrel
extends DestructibleObject

var explosion_preload = load("res://Scenes/explosion.tscn")

func destroy() -> void:
	var explosion: Explosion = explosion_preload.instantiate()
	#explosion.active_masks.append(1)
	explosion.position = global_position
	explosion.SPREAD = false
	SoundManager.play_sound(destruction_sfx.pick_random())
	get_tree().root.call_deferred("add_child", explosion)

	map.set_cell(tile_location, 0, rubble_tile)
	call_deferred("queue_free")
