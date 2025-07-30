class_name UIAnimationComponent
extends Node
# Preset parameters
@export var anim_param: UiAnimationParamResource
# Tween info
@export var from_center: bool = true
@export var hover_scale: Vector2 = Vector2(1, 1)
@export var time: float = 0.1
@export var transition_type: Tween.TransitionType
# Interaction audio
@export var interact: String = "UiInteractSFX"
@export var mouse_entered: String = "UiMouseEnteredSFX"
@export var focus_entered: String = "UiFocusEnteredSFX"
@export var input_accepted: String = "UiInputAcceptedSFX"

var target: Control
var default_scale: Vector2

func _ready() -> void:
	if anim_param:
		apply_presets()
	if target == null:
		target = get_parent()
	connect_signals()
	call_deferred("setup")

func apply_presets() -> void:
	if anim_param.from_center:
		from_center = anim_param.from_center
	if anim_param.hover_scale:
		hover_scale = anim_param.hover_scale
	if anim_param.time:
		time = anim_param.time
	if anim_param.transition_type:
		from_center = anim_param.transition_type

	if anim_param.interact:
		interact = anim_param.interact
	if anim_param.mouse_entered:
		mouse_entered = anim_param.mouse_entered
	if anim_param.focus_entered:
		focus_entered = anim_param.focus_entered
	if anim_param.input_accepted:
		input_accepted = anim_param.input_accepted

func connect_signals() -> void:
	target.mouse_entered.connect(on_hover)
	target.focus_entered.connect(on_hover)
	target.mouse_exited.connect(on_exit)
	target.focus_exited.connect(on_exit)
	if target is Button:
		target.pressed.connect(on_interact)

func setup() -> void:
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func on_hover() -> void:
	add_tween("scale", hover_scale, time)
	if mouse_entered:
		SoundManager.play_sound(mouse_entered)

func on_exit() -> void:
	add_tween("scale", default_scale, time)

func on_interact(_input_event: InputEvent = null) -> void:
	if interact:
		SoundManager.play_sound(interact)

func add_tween(property: String, value, seconds: float) -> Tween:
	var tree = get_tree()
	if tree == null:
		return
	var tween = tree.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(target, property, value, seconds).set_trans(transition_type)
	return tween
