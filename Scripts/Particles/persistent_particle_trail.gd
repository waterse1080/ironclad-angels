class_name PersistentParticleTrail
extends CPUParticles2D

var follow_obj: Node2D
var delete_timer := 0.0
var delete_flag := false

func _ready() -> void:
	if one_shot:
		emitting = true
	SignalBus.level_cleanup.connect(queue_free)

func _physics_process(delta):
	if follow_obj != null and follow_obj.position != null:
		position = follow_obj.position
	elif delete_flag:
		emitting = false
		delete_timer += delta
		if delete_timer >= lifetime:
			call_deferred("queue_free")

func attatch(obj: Node2D):
	obj.call_deferred("add_sibling", self)
	follow_obj = obj
	position = follow_obj.position
	obj.tree_exiting.connect(stop_follow)
	emitting = false

func stop_follow():
	delete_flag = true
