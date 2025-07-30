class_name FallingBomb
extends Node2D

@export var explosion_damage: float = 100.0
@export var explosion_scale: float = 1.0
@export var explosion_texture: Texture2D = load(
	"res://Assets/Images/SpriteSheets/Animations/explosion-3.png"
	)
@export var boss: bool = true

var explosion_preload = load("res://Scenes/explosion.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(spawn_explosion)

func spawn_explosion(_anim_name: String) -> void:
	var our_pos = get_position()
	var explosion: Explosion = explosion_preload.instantiate()
	explosion.global_position = global_position
	explosion.DAMAGE = explosion_damage
	explosion.scale *= explosion_scale
	if boss:
		explosion.active_masks.append(1)
		explosion.inactive_masks.append(3)
		explosion.explosion_texture = explosion_texture
	call_deferred("add_sibling", explosion)
	call_deferred("queue_free")
