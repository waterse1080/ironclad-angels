class_name PassiveRepairComponent
extends BaseTimedComponent

var health_component: HealthComponent
var heal_amount: float = 10.0

func on_timer_complete() -> void:
	if health_component and health_component != null:
		if health_component.health < health_component.max_health:
			health_component.heal(heal_amount)
