extends BaseUpgrade
class_name PickupRangeUpgrade

@export var SIZE_INCREASE: float = 0.75

func on_add(player: Player):
	player.body.pickup_collider.scale.x += SIZE_INCREASE
	player.body.pickup_collider.scale.y += SIZE_INCREASE

func on_remove(player: Player):
	player.body.pickup_collider.scale.x -= SIZE_INCREASE
	player.body.pickup_collider.scale.y -= SIZE_INCREASE

func get_description() -> String:
	description = description.replace("$", str(int(SIZE_INCREASE * 100)))
	return description
