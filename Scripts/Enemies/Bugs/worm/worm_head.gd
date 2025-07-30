class_name WormHead
extends ProtoEnemy

@export var segment_min: int = 30
@export var segment_max: int = 31
@export var spawn_vfx: String = "WormSpawnSFX"

var current_move_target: Vector2 = Vector2.ZERO
var segment_count: int
var segment_list: Array[WormSegment] = []
var followed_by: WormSegment
var can_destroy_terrain: bool = true
var segment_preload = load("res://Scenes/Enemies/Bugs/worm/worm_segment.tscn")
var segment_turret_preload = load("res://Scenes/Enemies/Bugs/worm/worm_segment_turret.tscn")
var segment_launcher_preload = load("res://Scenes/Enemies/Bugs/worm/worm_segment_launcher.tscn")

var sin_tracker: float = randf_range(0.0, PI * 2)
var angle_mult: float = randf_range(0.0, PI / 2)

@onready var connection_point: Marker2D = $ConnectionPoint

func _ready() -> void:
	SignalBus.add_objective_marker.emit(self)
	health_component.max_health *= HEALTH_MOD
	health_component.health *= HEALTH_MOD
	segment_count = randi_range(segment_min, segment_max)
	turn_speed_mult = randf_range(0.5, 0.75)
	table = DropTable.TABLES.BOSS
	z_index = segment_count

	var segment_order = [
		segment_preload,
		segment_turret_preload,
		segment_preload,
		segment_launcher_preload
	]

	player = get_tree().get_first_node_in_group("player")
	if player:
		rotation = (player.global_position - global_position).angle() - PI / 2
	var delay_l: bool = true
	for i in segment_count:
		var new_segment = segment_order[i%segment_order.size()].instantiate() as WormSegment
		new_segment.delay_time = float(i) * 0.1
		new_segment.delay_l = delay_l
		delay_l = !delay_l
		new_segment.rotation = rotation
		var extra_distance = Vector2.from_angle(rotation - PI / 2) * (500 + 500 * i)
		new_segment.position = position + extra_distance
		#new_segment.position = position + Vector2(0, -500 - 500 * i) #TODO: dirty
		new_segment.z_index = segment_count - i
		call_deferred("add_sibling", new_segment)
		segment_list.append(new_segment)
	call_deferred("connect_parts")
	call_deferred("emit_spawn_signal")
	if spawn_vfx:
		SoundManager.play_sound(spawn_vfx)

func connect_parts() -> void:
	var prior_obj = self
	var health_per_segment = health_component.max_health / (segment_count + 1)
	for segment in segment_list:
		segment.set_follow_target(prior_obj)
		segment.main_health_component = health_component
		segment.health_component.max_health = health_per_segment
		segment.health_component.health = health_per_segment
		prior_obj = segment

func emit_spawn_signal() -> void:
	SignalBus.boss_spawned.emit(health_component, "Ant-Wyrm")

func _physics_process(delta):
	# Move towards player
	var our_pos = get_position()
	if player:
		current_move_target = player.global_position
	else:
		current_move_target = Vector2.DOWN.rotated(rotation) + our_pos
	var travel_vec = (current_move_target - our_pos).normalized()

	var target_angle = travel_vec.angle() - PI / 2
	sin_tracker += delta
	if sin_tracker >= (PI * 2):
		sin_tracker -= (PI * 2)
		angle_mult = randf_range(0.0, PI / 2) ## randomize angle every cycle
	var sin = sin(sin_tracker) * angle_mult
	target_angle += sin
	if rotation > target_angle + PI:
		target_angle += 2 * PI
	elif target_angle > rotation + PI:
		target_angle -= 2 * PI
	rotation = lerpf(rotation, target_angle, delta * turn_speed_mult)
	velocity = Vector2.DOWN.rotated(rotation) * SPEED
	move_and_slide()
	if followed_by:
		followed_by.process_follow(delta)

func _on_health_component_health_depleted() -> void:
	for segment in segment_list:
		if segment != null:
			segment._on_health_component_health_depleted()
	super._on_health_component_health_depleted()
