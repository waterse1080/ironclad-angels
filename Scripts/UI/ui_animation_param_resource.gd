class_name UiAnimationParamResource
extends Resource
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
