extends BaseUpgrade
class_name BuzzSawUpgrade

@export var distance := 200.0
@export var damage := 10.0
@export var orbit_speed := 2.0

var orbit_controller = load("res://Scenes/Components/orbit_controller.tscn")
var buzzsaw_drone = load("res://Scenes/Player/Projectiles/buzzsaw_drone.tscn")

var controller: OrbitController

func on_add(player: Player):
	if controller == null:
		controller = orbit_controller.instantiate()
		controller.orbit_id = "BuzzsawDroneController"
		#controller.position = player.position
		controller.orbit_distance = distance
		controller.orbit_speed = orbit_speed
		player.add_child(controller)
	var saw: BuzzsawDrone = buzzsaw_drone.instantiate()
	saw.base_damage = damage
	saw.player = player
	controller.add_orbit_obj(saw)

func on_remove(_player: Player):
	pass #TODO if needed

func get_description() -> String:
	description = description.replace("$", str(int(damage)))
	return description
