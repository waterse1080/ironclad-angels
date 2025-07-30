class_name ShellProjectile
extends ProtoBullet

@onready var anim_player = $AnimationPlayer as AnimationPlayer
@onready var hitbox = $HitBox as HitBox

func _ready() -> void:
	super._ready()
	anim_player.play("eject", -1, randf_range(0.85, 1.15))
