extends Button
class_name AnimatedButton

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	focus_entered.connect(gain_focus)
	mouse_entered.connect(gain_focus)
	focus_exited.connect(lose_focus)
	mouse_exited.connect(lose_focus)

func gain_focus():
	anim_player.play("FocusGained")

func lose_focus():
	anim_player.play("FocusLost")
