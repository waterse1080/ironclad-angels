class_name ReactiveArmorUpgrade
extends BaseUpgrade

@export var explosion_damage: float = 100.0
@export var explosion_size: float = 1.5
@export var additional_size: float = 0.5

var armor_component_preload = load("res://Scenes/Components/reactive_armor_component.tscn")

var armor_component: ReactiveArmorComponent

func on_add(player: Player) -> void:
	if armor_component == null:
		armor_component = armor_component_preload.instantiate()
		armor_component.explosion_damage = explosion_damage
		armor_component.explosion_size = explosion_size
		armor_component.player = player
		player.call_deferred("add_child", armor_component)
	else:
		armor_component.explosion_damage += explosion_damage
		armor_component.explosion_size += additional_size

func on_remove(player: Player) -> void:
	pass
