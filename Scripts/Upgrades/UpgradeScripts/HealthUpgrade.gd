extends BaseUpgrade
class_name HealthUpgrade

@export var health_increase := 25.0

func on_add(player: Player):
	var hc = player.body.health_component
	hc.change_max_health(player.body.health_component.max_health + health_increase)
	hc.heal(health_increase)

func on_remove(player: Player):
	var hc = player.body.health_component
	hc.change_max_health(player.body.health_component.max_health - health_increase)

func get_description() -> String:
	description = description.replace("$", str(int(health_increase)))
	return description
