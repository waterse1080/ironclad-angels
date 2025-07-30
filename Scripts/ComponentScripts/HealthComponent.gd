extends Node
class_name HealthComponent

@export var max_health := 10.0
var can_change_max_health := true
var health: float
var alive := true
signal health_depleted
signal hurt
signal healed

func _ready() -> void:
	health = max_health

func change_max_health(new_max: float) -> void:
	if not can_change_max_health:
		return
	max_health = new_max
	if health > max_health:
		health = max_health

func damage(dmg: float, crit_level: int, blood: bool = true) -> void:
	health -= dmg
	hurt.emit(dmg, crit_level, blood)
	if health <= 0 and alive:
		health_depleted.emit()
		alive = false

func heal(heal_amt: float) -> void:
	if not alive:
		return
	health += heal_amt
	healed.emit(heal_amt)
	if health > max_health:
		health = max_health
