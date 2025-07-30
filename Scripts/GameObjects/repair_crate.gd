class_name RepairCrate
extends DestructibleObject

var health_pickup_preload = load("res://Scenes/Pickups/health_pickup.tscn")

func destroy() -> void:
	var hp = health_pickup_preload.instantiate()
	hp.position = self.global_position
	get_tree().root.call_deferred("add_child", hp)
	super.destroy()
