extends Node

var rnd = RandomNumberGenerator.new()
var font_style = load("res://Assets/Fonts/BoreBlasters16/Bore Blasters 16.ttf")
#var font_style = load("res://Assets/Fonts/Not Jam Sci Mono 10/NotJamSciMono10.ttf")
var display_pool: Array[Label] = []

func get_label() -> Label:
	var label: Label = display_pool.pop_back()
	if label == null:
		label = Label.new()
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		label.label_settings = LabelSettings.new()
		label.label_settings.outline_color = Color.BLACK
		label.label_settings.outline_size = 4
		label.label_settings.font = font_style
		call_deferred("add_child", label)
	else:
		label.modulate.a = 1
		label.scale = Vector2i.ONE
	label.z_index = 999
	return label

func send_label_to_pool(label: Label) -> void:
	display_pool.append(label)

# TODO clean up argument entry to use dictionary
func display_number(
	value: int,
	position: Vector2,
	crit_level:= 0,
	color_override := Color.BLACK,
	insert_front:= "",
	insert_back:= "",
	size:= 24
	):
	var number = get_label()
	number.global_position = position
	number.text = insert_front + str(value) + insert_back

	var color = Color.WHITE_SMOKE
	# Change color for crits
	if value > 0 and crit_level > 0:
		if crit_level == 1:
			color = Color.YELLOW
		elif crit_level == 2:
			color = Color.DARK_ORANGE
		elif crit_level == 3:
			color = Color.RED
		elif crit_level >= 4:
			color = Color.DARK_VIOLET

		for i in crit_level:
			number.text += "!"
		number.z_index += crit_level

	# Override color if given
	if color_override != Color.BLACK:
		color = color_override
	number.label_settings.font_color = color

	if number.label_settings.font_size != size:
		number.label_settings.font_size = size
	call_deferred("tween_number", number)

func tween_number(number: Label) -> void:
	number.pivot_offset = Vector2(number.size/2)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - rnd.randi_range(20, 40), 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:x", number.position.x + rnd.randi_range(-30, 30), 0.75
	).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	tween.tween_property(
		number, "modulate:a", 0, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	send_label_to_pool(number)
