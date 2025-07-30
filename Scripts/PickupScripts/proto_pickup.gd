extends Area2D
class_name Pickup

@export var PICKUP_SFX: String
@export var TIME_UNTIL_CLEANUP: float = 120.0

@onready var tween_component: TweenComponent = $TweenComponent
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var trail: TrailComponent = $TrailComponent

var despawn_timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect(_on_area_entered)
	body_shape_entered.connect(_on_body_shape_entered)
	SignalBus.level_cleanup.connect(queue_free)
	trail.process_mode = Node.PROCESS_MODE_DISABLED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(delta):
	despawn_timer += delta
	if despawn_timer >= TIME_UNTIL_CLEANUP:
		call_deferred("queue_free")

func on_pickup(_player: Player):
	if PICKUP_SFX:
		SoundManager.play_sound(PICKUP_SFX)
	self.queue_free()

func _on_area_entered(area):
	if area is PickupBox and area.player != null:
		tween_component.target = area.player
		trail.process_mode = Node.PROCESS_MODE_INHERIT
		animator.play("RESET")

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is Player:
		on_pickup(body)
