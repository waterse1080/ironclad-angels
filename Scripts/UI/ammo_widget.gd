class_name AmmoWidget
extends BoxContainer

@onready var bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func update_text(text: String, value: float, maximum: float, heat_anim: bool = false) -> void:
	bar.max_value = maximum
	bar.value = value
	label.text = text
	visible = true

	if heat_anim:
		var red = 1.0 - (value / maximum)
		bar.self_modulate = Color(1.0, red, red)
