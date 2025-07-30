class_name LandmineBoostComponent
extends Node

@export var place_sfx: String = "LandminePlaceSFX"
@export var time_to_ready: float = 0.0
@export var player: Player

var landmine_ready: bool = true
var landmine_ready_timer: float = 1.0

var landmine_preload = load("res://Scenes/Player/Projectiles/landmine.tscn")

func _process(delta: float) -> void:
	if not landmine_ready:
		landmine_ready_timer += delta
		if landmine_ready_timer >= time_to_ready:
			landmine_ready = true
			landmine_ready_timer = 0.0
	if player and player.body:
		if player.body.is_boosting and landmine_ready:
			spawn_landmine()
			landmine_ready = false
	else:
		print("Player or body missing from landmine boost component")

func spawn_landmine() -> void:
	var landmine: Landmine = landmine_preload.instantiate()
	landmine.global_position = player.global_position
	if place_sfx:
		SoundManager.play_sound(place_sfx)
	player.call_deferred("add_sibling", landmine)
