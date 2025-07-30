class_name WormLeg
extends Node2D

var speed: float = 1.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

func set_delay_time(delay_time) -> void:
	timer.timeout.connect(start_anim)
	timer.start(delay_time)

func _physics_process(_delta: float) -> void:
	animation_player.speed_scale = speed

func start_anim() -> void:
	animation_player.play("walk_loop")
