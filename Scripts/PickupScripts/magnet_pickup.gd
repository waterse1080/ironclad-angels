class_name MagnetPickup
extends Pickup

func on_pickup(player: Player):
	for pickup in get_tree().get_nodes_in_group("pickup"):
		if pickup.has_node("TweenComponent"):
			if pickup is HealthPickup and player.body.health_component.health == player.body.health_component.max_health:
				continue
			else:
				pickup.tween_component.bounce = false
				pickup.tween_component.target = player
				pickup.trail.process_mode = Node.PROCESS_MODE_INHERIT
	super.on_pickup(player)
