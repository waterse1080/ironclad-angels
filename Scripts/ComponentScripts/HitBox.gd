extends Area2D
# Used to inflict damage on hurtboxes
class_name HitBox

signal hitbox_triggered

func _on_area_entered(area):
	if area is HurtBox:
		hitbox_triggered.emit(area)
