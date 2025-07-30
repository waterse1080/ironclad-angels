class_name UpgradeMenu
extends Control

signal upgrades_done
signal upgrades_rerolled

@export var upgrade_widgets: Array[UpgradeWidget] = []
@export var upgrade_list: Array[BaseUpgrade] = []
@export var rerolls: int = 3
@export var pause_manager: PauseManager

var upgrades_to_select := 0
var upgrade_choice_mod := 0
var player: Player

@onready var reroll_button = $ButtonContainer/RerollButton as Button
@onready var skip_button = $ButtonContainer/SkipButton as Button
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var select_label: Label = $HBoxContainer/UpgradeSelectCount

func _ready() -> void:
	SignalBus.level_up.connect(select_upgrades)
	SignalBus.upgrade_selected.connect(selection_made)
	SignalBus.change_choice_count.connect(change_choice_count)
	SignalBus.add_reroll.connect(add_reroll)
	for upgrade in upgrade_list:
		upgrade.upgrade_copies_count = 0
	self.visible = false
	set_neighbors()
	player = get_tree().get_first_node_in_group("player")

	if RunDataManager.run_is_active:
		rerolls = RunDataManager.current_rerolls

func add_reroll(mod: int) -> void:
	rerolls += mod
	update_reroll_button()

func update_reroll_button() -> void:
	reroll_button.disabled = (rerolls <= 0)
	reroll_button.text = "REROLL: " + str(rerolls)

func change_choice_count(mod: int) -> void:
	upgrade_choice_mod += mod
	for index in upgrade_widgets.size() - 1: #makes sure last one stays visible
		upgrade_widgets[index].visible = upgrade_choice_mod <= index

func select_upgrades(upgrade_count: int) -> void:
	upgrades_to_select = upgrade_count
	select_label.text = str(upgrades_to_select)
	reroll_upgrades()
	toggle_menu(true)

func set_neighbors() -> void:
	upgrade_widgets[0].button.focus_neighbor_bottom = NodePath(reroll_button.get_path())
	upgrade_widgets[1].button.focus_neighbor_bottom = NodePath(reroll_button.get_path())
	upgrade_widgets[2].button.focus_neighbor_bottom = NodePath(reroll_button.get_path())

func first_vis_grab_focus() -> void:
	for widget in upgrade_widgets:
		if widget.visible:
			widget.button.grab_focus()
			return

func toggle_buttons(interactable: bool) -> void:
	for widget in upgrade_widgets:
		widget.button.disabled = not interactable
	reroll_button.disabled = not interactable
	update_reroll_button()
	skip_button.disabled = not interactable

func toggle_menu(vis: bool) -> void:
	if vis:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var index = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_effect_enabled(index, 0, true)
		#MusicManager.play_music(MusicManager.SONGLIST.UPGRADE_MENU)
		for i in upgrade_widgets.size():
			var widget = upgrade_widgets[i]
			if widget.visible:
				if i > 0:
					var prior_widget = upgrade_widgets[i-1]
					if prior_widget.visible:
						widget.button.focus_neighbor_left = NodePath(prior_widget.button.get_path())
				if i < upgrade_widgets.size()-1:
					var next_widget = upgrade_widgets[i+1]
					if next_widget.visible:
						widget.button.focus_neighbor_right = NodePath(next_widget.button.get_path())
		pause_manager.CAN_TOGGLE_PAUSE = false

		anim_player.play("tween_in")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		var index = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_effect_enabled(index, 0, false)
		#MusicManager.play_previous_song()
		pause_manager.CAN_TOGGLE_PAUSE = true

	self.visible = vis
	get_tree().paused = vis

func reroll_upgrades(upgrade_skips: Array[BaseUpgrade] = []) -> void:
	var possible_upgrades = upgrade_list.duplicate()
	for upgrade in upgrade_list:
		if not upgrade.is_available(player):
			print("Upgrade not available: " + upgrade.name)
			var index = possible_upgrades.find(upgrade)
			if index != -1:
				possible_upgrades.remove_at(index)
	for upgrade in upgrade_skips:
		var index = possible_upgrades.find(upgrade)
		if index != -1:
			possible_upgrades.remove_at(index)
	for upgrade in upgrade_widgets:
		var new_upgrade = possible_upgrades.pick_random()
		upgrade.set_upgrade(new_upgrade)
		var owned: int = 0
		for owned_upgrade in player.upgrades:
			if new_upgrade == owned_upgrade:
				owned += 1
		
		upgrade.button.text = "EQUIP: " + str(owned)
		
		var index = possible_upgrades.find(new_upgrade)
		possible_upgrades.remove_at(index)
	upgrades_rerolled.emit()

func selection_made(_upgrade: BaseUpgrade = null) -> void:
	upgrades_to_select -= 1
	select_label.text = str(upgrades_to_select)
	if upgrades_to_select <= 0:
		upgrades_done.emit()
		SignalBus.upgrades_done.emit()
		anim_player.play("tween_out")
	else:
		call_deferred("reroll_upgrades")

func _on_skip_button_pressed() -> void:
	selection_made()

func _on_reroll_button_pressed() -> void:
	if rerolls <= 0:
		return
	var skips: Array[BaseUpgrade] = []
	for widget in upgrade_widgets:
		skips.append(widget.upgrade)
	reroll_upgrades(skips)
	rerolls -= 1
	update_reroll_button()
