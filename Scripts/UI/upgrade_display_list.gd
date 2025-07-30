class_name UpgradeDisplayList
extends Control

var widget_preload = load("res://Scenes/UI/upgrade_display_widget.tscn")

@onready var grid: GridContainer = $ScrollContainer/MarginContainer/GridContainer
@onready var desc_widget: UpgradeWidget = $UpgradeWidget
@onready var scroll: ScrollContainer = $ScrollContainer

func update_upgrades(upgrades: Array[BaseUpgrade]) -> void:
	desc_widget.visible = false
	for child in grid.get_children():
		child.queue_free()
	for upgrade in upgrades:
		if upgrade.icon_row_column.x == -1 or upgrade.icon_row_column.y == -1:
			continue
		var widget: UpgradeDisplayWidget = widget_preload.instantiate()
		widget.call_deferred("set_upgrade", upgrade)
		grid.add_child(widget)
		widget.upgrade_selected.connect(display_desc)
		widget.button.focus_exited.connect(hide_display)
		widget.button.mouse_exited.connect(hide_display)

func display_desc(upgrade: UpgradeDisplayWidget) -> void:
	desc_widget.set_upgrade(upgrade.upgrade)
	desc_widget.global_position = upgrade.global_position
	if desc_widget.position.y > 500:
		desc_widget.position = Vector2(desc_widget.position.x, 500)
	elif desc_widget.position.y < 0:
		desc_widget.position = Vector2(desc_widget.position.x, 0)
	desc_widget.visible = true

func hide_display() -> void:
	desc_widget.visible = false
