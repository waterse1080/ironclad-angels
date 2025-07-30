class_name ReactiveArmorComponent
extends Node

var player: Player
var explosion_damage: float = 100.0
var explosion_size: float = 1.5
var explosion_preload = load("res://Scenes/explosion.tscn")

func _ready() -> void:
	player.body.health_component.hurt.connect(on_hurt)

func on_hurt(_dmg: float, _crit_level: int, _blood: bool) -> void:
	var explosion: Explosion = explosion_preload.instantiate()
	explosion.scale.x *= explosion_size
	explosion.scale.y *= explosion_size
	explosion.DAMAGE = explosion_damage
	explosion.SPREAD = true
	explosion.global_position = player.global_position
	player.call_deferred("add_sibling", explosion)
