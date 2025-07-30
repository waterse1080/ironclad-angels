class_name UpgradeWidget
extends Control

signal upgrade_selected

@export var upgrade: BaseUpgrade

var icon_texture: AtlasTexture

@onready var name_label: LabelAutoSizer = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var description: RichLabelAutoSizer = $Panel/MarginContainer/VBoxContainer/Description
@onready var button: Button = $Panel/MarginContainer/VBoxContainer/SelectButton

func _ready() -> void:
	icon_texture = button.icon.duplicate()

func set_upgrade(new_upgrade: BaseUpgrade):
	upgrade = new_upgrade
	name_label.text = upgrade.name
	description.text = upgrade.get_description()
	var rect = Rect2i(upgrade.icon_row_column * 16, Vector2i(16, 16))
	icon_texture.region = rect
	button.icon = icon_texture

func _on_select_button_pressed():
	upgrade_selected.emit(upgrade)
	SignalBus.upgrade_selected.emit(upgrade)
