class_name HealthPickup
extends Pickup

@export var HEAL := 25

func on_pickup(player: Player):
	if player.body.health_component != null and player.body.health_component.health < player.body.health_component.max_health:
		player.body.health_component.heal(HEAL)
		super.on_pickup(player)

func _on_area_entered(area):
	if area is PickupBox and area.player != null and area.player.body.health_component.health < area.player.body.health_component.max_health:
		tween_component.target = area.player
		trail.process_mode = Node.PROCESS_MODE_INHERIT
