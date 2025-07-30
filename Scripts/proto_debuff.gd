extends Node2D
class_name ProtoDebuff

var hurt_box: HurtBox

func on_add(area: HurtBox):
	hurt_box = area

func _exit_tree():
	pass
