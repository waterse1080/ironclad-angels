class_name IceDebuff
extends ProtoDebuff

@export var shatter_percent: float = 0.15
@export var boss_shatter_percent: float = 0.05
@export var duration: float = 5.0

var duration_timer := 0.0
var enemy: ProtoEnemy
var speed: float
var is_boss: bool = false

func _physics_process(delta):
	duration_timer += delta
	var percent = boss_shatter_percent if is_boss else shatter_percent
	if not hurt_box:
		return
	if not hurt_box.health_component:
		return
	var hc = hurt_box.health_component
	if hc.health / hc.max_health <= percent:
		hc.damage(hc.health, 0, false)

	if enemy:
		rotation = -enemy.rotation

	if duration_timer >= duration:
		call_deferred("queue_free")

func add_to_target(hit_target, area: HurtBox) -> void:
	for child in hit_target.get_children():
		if child is IceDebuff:
			child.duration_timer = 0.0
			queue_free()
	if hit_target is ProtoEnemy:
		enemy = hit_target
		is_boss = hit_target.is_in_group("bosses")
		if not is_boss:
			speed = enemy.SPEED
			enemy.SPEED = 0.0
	elif hit_target is DestructibleObject:
		scale = Vector2(0.2, 0.2)

	on_add(area)
	hit_target.add_child(self)

func _exit_tree():
	if enemy and not is_boss:
		enemy.SPEED = speed
