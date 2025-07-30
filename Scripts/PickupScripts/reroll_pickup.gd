class_name RerollPickup
extends Pickup

var count: int = 1

func on_pickup(_player: Player):
	SignalBus.add_reroll.emit(count)
	DamageNumbers.display_number(1, global_position, 0, Color.DEEP_SKY_BLUE, "+", " reroll")
	if PICKUP_SFX:
		SoundManager.play_sound(PICKUP_SFX)
	call_deferred("queue_free")
