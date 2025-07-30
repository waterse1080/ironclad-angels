class_name RadioPickup
extends Pickup

var bomber_run_preload = load("res://Scenes/bomber_run.tscn")

func on_pickup(player: Player):
	var bomber_run = bomber_run_preload.instantiate() as BomberRun
	bomber_run.global_position = player.global_position
	DamageNumbers.display_number(1, global_position, 0, Color.SEA_GREEN, "+", " bombing run")
	if PICKUP_SFX:
		SoundManager.play_sound(PICKUP_SFX)
	call_deferred("add_sibling", bomber_run)
	call_deferred("queue_free")
