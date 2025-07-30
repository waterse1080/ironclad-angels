class_name XpPickup
extends Pickup

@export var xp := 10

func on_pickup(player: Player):
	var display_xp = player.level_tracker_component.collect_xp(xp)
	DamageNumbers.display_number(display_xp, self.global_position, 0, Color.GOLD, "+", " xp")
	super.on_pickup(player)
