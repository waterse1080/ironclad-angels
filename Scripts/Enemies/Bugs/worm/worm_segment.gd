class_name WormSegment
extends ProtoEnemy

var follow_target: Node2D
var followed_by: WormSegment
var main_health_component: HealthComponent
var can_destroy_terrain: bool = true
var delay_time: float = 0.0
var delay_l: bool = true

@onready var connection_point_self: Marker2D = $ConnectionPoint1
@onready var connection_point: Marker2D = $ConnectionPoint2
@onready var leg_l: WormLeg = $WormLegL
@onready var leg_r: WormLeg = $WormLegR

func _ready() -> void:
	super._ready()
	if delay_l:
		leg_l.set_delay_time(delay_time + 0.25)
		leg_r.set_delay_time(delay_time)
	else:
		leg_l.set_delay_time(delay_time)
		leg_r.set_delay_time(delay_time + 0.25)

#func _physics_process(_delta):
	#if follow_target == null:
		#return
	#var vec_1 = Vector2.RIGHT.rotated(rotation)
	#var vec_2 = Vector2.RIGHT.rotated(follow_target.rotation)
	#var angle_dif = vec_1.angle_to(vec_2)
	#leg_l.speed = rotation/(rotation - angle_dif)
	#leg_r.speed = (rotation - angle_dif)/rotation

func set_follow_target(new_target: Node2D) -> void:
	follow_target = new_target
	follow_target.followed_by = self

func on_death_pass_follow() -> void:
	if followed_by:
		followed_by.set_follow_target(follow_target)
	elif follow_target:
		follow_target.followed_by = null
	else:
		push_error("MISSING BOTH FOLLOW TARGETS")

func process_follow(delta) -> void:
	if follow_target == null:
		return
	if follow_target.connection_point == null:
		return
	if connection_point_self == null:
		return

	var travel_vec = (follow_target.connection_point.global_position - global_position).normalized()
	var target_angle = travel_vec.angle() - PI / 2
	if rotation > target_angle + PI:
		target_angle += 2 * PI
	elif target_angle > rotation + PI:
		target_angle -= 2 * PI
	rotation = target_angle

	position = position + (follow_target.connection_point.global_position - connection_point_self.global_position)

	extra_process(delta)
	if followed_by:
		followed_by.process_follow(delta)

func extra_process(_delta) -> void:
	pass

func _on_health_component_health_depleted() -> void:
	on_death_pass_follow()
	#super._on_health_component_health_depleted()
	## Remove death signal and drop table
	if DEATH_SFX:
		SoundManager.play_sound(DEATH_SFX)
	var particles = blood_particles.instantiate() as AlienBloodParticles
	particles.attatch(self)
	particles.amount = 40
	particles.scale = scale
	queue_free()

func _on_health_component_hurt(dmg: float, crit_level: int, blood: bool) -> void:
	main_health_component.damage(dmg, -1, false)
	super._on_health_component_hurt(dmg, crit_level, blood)
