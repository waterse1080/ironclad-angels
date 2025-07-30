class_name BaseTimedComponent
extends Node

signal timer_finished

var base_timer_duration: float = 1.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	call_deferred("start_timer")

func start_timer() -> void:
	timer.wait_time = base_timer_duration
	timer.timeout.connect(timeout)
	timer.start()

func timeout() -> void:
	on_timer_complete()
	timer_finished.emit()

## Used by children
func on_timer_complete() -> void:
	pass
