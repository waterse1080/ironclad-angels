extends PlayerBody
class_name DefenderMechBody

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var footrpints_L: CPUParticles2D = $Legs_Parent/Foot_L/Footprints_L
@onready var footrpints_R: CPUParticles2D = $Legs_Parent/Foot_R/Footprints_R
var walking := false

func connect_parts(new_turret: PlayerTurret, new_player: Player):
	super.connect_parts(new_turret, new_player)
	player.collider.shape.radius = 20

func handle_input(delta):
	super.handle_input(delta)
	
	var moveDirection = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	
	if not walking and moveDirection.length() > 0.1:
		anim_player.play("walking_v2")
		walking = true
	elif walking and moveDirection.length() <= 0.1:
		anim_player.play("RESET")
		walking = false
	var current_speed = move_speed
	if is_boosting:
		current_speed += boost_speed
	anim_player.speed_scale = current_speed / starting_speed
	can_destroy_terrain = is_boosting

func extra_input(delta) -> void:
	var modifier = (player.velocity.length() / move_speed) * (move_speed / starting_speed)
	footrpints_L.speed_scale = modifier
	footrpints_R.speed_scale = modifier
