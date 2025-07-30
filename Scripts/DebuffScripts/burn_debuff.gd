extends ProtoDebuff
class_name BurnDebuff

@export var DAMAGE_PER_TICK := 2.0
@export var TICK_TIME := 0.5
@export var DURATION := 5.0
@export var boss_dmg_mult: float = 0.5

var timer := 0.0
var duration_timer := 0.0

func _physics_process(delta):
	timer += delta
	duration_timer += delta
	if timer >= TICK_TIME and hurt_box:
		timer = 0.0
		var parent = hurt_box.get_parent()
		if parent and parent.is_in_group("bosses"):
			hurt_box.health_component.damage(DAMAGE_PER_TICK * boss_dmg_mult, 0, false)
		else:
			hurt_box.health_component.damage(DAMAGE_PER_TICK, 0, false)
	if duration_timer >= DURATION:
		call_deferred("queue_free")

func add_to_target(hit_target, area: HurtBox) -> void:
	for child in hit_target.get_children():
		if child is BurnDebuff:
			child.DAMAGE_PER_TICK += DAMAGE_PER_TICK
			child.duration_timer = 0.0
			if child.DURATION < DURATION:
				child.DURATION = DURATION
			if child.TICK_TIME > TICK_TIME:
				child.DURATION = DURATION
			queue_free()

	on_add(area)
	hit_target.add_child(self)
