class_name UpgradeDisplayWidget
extends Control

signal upgrade_selected

@export var upgrade: BaseUpgrade

var icon_texture: AtlasTexture

@onready var button: TextureButton = $TextureButton

func _ready() -> void:
	icon_texture = button.texture_normal.duplicate()
	button.pressed.connect(_on_select_button_pressed)

func set_upgrade(new_upgrade: BaseUpgrade):
	upgrade = new_upgrade
	var rect = Rect2i(upgrade.icon_row_column * 16, Vector2i(16, 16))
	icon_texture.region = rect
	button.texture_normal = icon_texture
	button.texture_pressed = icon_texture
	button.texture_hover = icon_texture
	button.texture_disabled = icon_texture
	button.texture_focused = icon_texture

func _on_select_button_pressed():
	upgrade_selected.emit(self)
