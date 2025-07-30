class_name SwordSlash
extends ProtoBullet

var animation_player: AnimationPlayer

func _on_ready() -> void:
	animation_player = $AnimationPlayer
	animation_player.animation_finished.connect(on_spawn_anim_finish)

func on_spawn_anim_finish(anim_name: String) -> void:
	if anim_name == "spawn":
		animation_player.play("loop")

# TODO
func play_hit_effect() -> void:
	pass
	#var bullet_explosion = hit_explosion.instantiate()
	#bullet_explosion.global_position = global_position
	#bullet_explosion.scale = scale * hit_scale_mult
	#add_sibling(bullet_explosion)
