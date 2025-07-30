extends Area2D
class_name HurtBox
# Used with a connected health component when taking damage
@export var health_component: HealthComponent

func damage(attack: float, crit_level: int, blood: bool = true):
	if health_component:
		health_component.damage(attack, crit_level, blood)
