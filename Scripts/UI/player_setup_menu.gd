extends Control

@export var unlock_list: Array[Unlock] = []
@export var player: Player
@export var pause_manager: PauseManager
@export var player_ui: PlayerUI
@export var generator: WFC2DGenerator
@export var wave_spawner: WaveSpawner
@export var difficulties: Array[Difficulty] = []
@export var songs: Array[MusicManager.SONGLIST] = []

var turrets: Array[Unlock] = []
var bodies: Array[Unlock] = []
var copilots: Array[Unlock] = []

var loaded_turrets: Array[PackedScene] = []
var loaded_bodies: Array[PackedScene] = []
var loaded_copilots: Array[PackedScene] = []
var loaded_copilot_art: Array[PackedScene] = []

var selected_turret_index := 0
var selected_body_index := 0
var selected_copilot_index := 0
var selected_difficulty_index := 1

var turret_obj: Node2D
var chassis_obj: Node2D
var copilot_obj: Node2D

var map_complete := false
var play_pressed := false

@onready var turret_left: Button = $HBoxContainer/PartSelectionContainer/TurretSection/LeftT
@onready var turret_label: LabelAutoSizer = $HBoxContainer/PartSelectionContainer/TurretSection/Label
@onready var turret_right: Button = $HBoxContainer/PartSelectionContainer/TurretSection/RightT
@onready var turret_desc: RichLabelAutoSizer = $HBoxContainer/PartSelectionContainer/TurretDescription
@onready var turret_buy: Button = $HBoxContainer/PartPreviewContainer/TurretPreview/TurretUnlock

@onready var body_left: Button = $HBoxContainer/PartSelectionContainer/BodySection/LeftB
@onready var body_label: LabelAutoSizer = $HBoxContainer/PartSelectionContainer/BodySection/Label
@onready var body_right: Button = $HBoxContainer/PartSelectionContainer/BodySection/RightB
@onready var body_desc: RichLabelAutoSizer = $HBoxContainer/PartSelectionContainer/BodyDescription
@onready var body_buy: Button = $HBoxContainer/PartPreviewContainer/ChassisPreview/ChassisUnlock

@onready var copilot_left: Button = $HBoxContainer/PartSelectionContainer/CopilotSection/LeftC
@onready var copilot_label: LabelAutoSizer = $HBoxContainer/PartSelectionContainer/CopilotSection/Label
@onready var copilot_right: Button = $HBoxContainer/PartSelectionContainer/CopilotSection/RightC
@onready var copilot_desc: RichLabelAutoSizer = $HBoxContainer/PartSelectionContainer/CopilotDescription
@onready var copilot_buy: Button = $HBoxContainer/PartPreviewContainer/CopilotPreview/CopilotUnlock

@onready var difficulty_left: Button = $HBoxContainer/DifficultySelectionContainer/DifficultySection/LeftD
@onready var difficulty_label: LabelAutoSizer = $HBoxContainer/DifficultySelectionContainer/DifficultySection/Label
@onready var difficulty_right: Button = $HBoxContainer/DifficultySelectionContainer/DifficultySection/RightD
@onready var difficulty_desc: RichLabelAutoSizer = $HBoxContainer/DifficultySelectionContainer/DifficultyDescription

@onready var play: Button = $HBoxContainer/DifficultySelectionContainer/Play
@onready var random: Button = $HBoxContainer/DifficultySelectionContainer/Randomize
@onready var settings: Button = $LowerRightContainer/SettingsButton
@onready var back_button: Button = $UpperLeftContainer/MainMenuButton
@onready var settings_menu: SettingsMenu = $SettingsMenu

@onready var turret_preview: Control = $HBoxContainer/PartPreviewContainer/TurretPreview
@onready var chassis_preview: Control = $HBoxContainer/PartPreviewContainer/ChassisPreview
@onready var copilot_preview: Control = $HBoxContainer/PartPreviewContainer/CopilotPreview

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var rp_total_text: Label = $HBoxContainer/PartPreviewContainer/Spacer/ResearchPoints
@onready var color_rect: ColorRect = $ColorRect
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var lower_right_container: MarginContainer = $LowerRightContainer
@onready var upper_left_container: MarginContainer = $UpperLeftContainer
@onready var doom_melt: DoomMeltRect = $DoomMelt
@onready var travel_text: LabelAutoSizer = $TravelText
@onready var travel_progress: ProgressBar = $TravelProgressBar

@onready var main_menu = load("res://Scenes/main_menu.tscn")
@onready var unlock_mat = load("res://Assets/Materials/UNLOCK_MAT.tres")

@onready var buttons: Array[Button] = [
		turret_left,
		turret_right,
		body_left,
		body_right,
		copilot_left,
		copilot_right,
		difficulty_left,
		difficulty_right,
		play,
		random,
		settings,
		back_button
	]

func _ready() -> void:
	get_tree().set_deferred("paused", true)
	play.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var index = AudioServer.get_bus_index("Music")
	#AudioServer.set_bus_effect_enabled(index, 0, true)
	MusicManager.play_music(MusicManager.SONGLIST.MISSION_PREP)
	pause_manager.CAN_TOGGLE_PAUSE = false

	for unlock in unlock_list:
		var loaded_scene = ResourceLoader.load(unlock.unlock_node_path)
		if unlock.unlock_type == Unlock.unlock_types.TURRET:
			turrets.append(unlock)
			loaded_turrets.append(loaded_scene)
		elif unlock.unlock_type == Unlock.unlock_types.BODY:
			bodies.append(unlock)
			loaded_bodies.append(loaded_scene)
		elif unlock.unlock_type == Unlock.unlock_types.COPILOT:
			copilots.append(unlock)
			var copilot_art = ResourceLoader.load(loaded_scene.instantiate().selection_asset_path)
			loaded_copilots.append(loaded_scene)
			loaded_copilot_art.append(copilot_art)

	turret_left.pressed.connect(prev_turret)
	turret_right.pressed.connect(next_turret)
	turret_buy.pressed.connect(buy_turret)
	body_left.pressed.connect(prev_body)
	body_right.pressed.connect(next_body)
	body_buy.pressed.connect(buy_body)
	copilot_left.pressed.connect(prev_copilot)
	copilot_right.pressed.connect(next_copilot)
	copilot_buy.pressed.connect(buy_copilot)
	difficulty_left.pressed.connect(prev_difficulty)
	difficulty_right.pressed.connect(next_difficulty)

	play.pressed.connect(on_play_pressed)
	random.pressed.connect(randomize)
	settings.pressed.connect(on_settings_button_pressed)
	back_button.pressed.connect(return_to_main_menu)
	generator.done.connect(on_map_complete)
	settings_menu.visibility_changed.connect(settings_vis_changed)

	get_last_part_indexes()
	get_last_difficulty_index()
	update_rp_text()
	call_deferred("change_turret", 0)
	call_deferred("change_body", 0)
	call_deferred("change_copilot", 0)
	call_deferred("change_difficulty", 0)
	if RunDataManager.run_is_active:
		call_deferred("contine_run")

func prev_turret():
	change_turret(-1)
func next_turret():
	change_turret(1)
func prev_body():
	change_body(-1)
func next_body():
	change_body(1)
func prev_copilot():
	change_copilot(-1)
func next_copilot():
	change_copilot(1)
func prev_difficulty():
	change_difficulty(-1)
func next_difficulty():
	change_difficulty(1)
func buy_turret() -> void:
	turret_right.grab_focus()
	var unlock = turrets[selected_turret_index]
	buy_unlock(unlock)
	change_turret(0)
func buy_body() -> void:
	body_right.grab_focus()
	var unlock = bodies[selected_body_index]
	buy_unlock(unlock)
	change_body(0)
func buy_copilot() -> void:
	copilot_right.grab_focus()
	var unlock = copilots[selected_copilot_index]
	buy_unlock(unlock)
	change_copilot(0)

func _process(delta: float) -> void:
	travel_progress.value = generator.get_progress() * 100

func randomize() -> void:
	selected_turret_index = get_owned_part_indexes(turrets).pick_random()
	selected_body_index = get_owned_part_indexes(bodies).pick_random()
	selected_copilot_index = get_owned_part_indexes(copilots).pick_random()

	change_turret(0)
	change_body(0)
	change_copilot(0)

func on_map_complete() -> void:
	map_complete = true
	if play_pressed:
		start_game()

func get_owned_part_indexes(array: Array[Unlock]) -> Array[int]:
	var unlocked_part_indexes: Array[int] = []
	for part_index in array.size():
		if SaveDataManager.is_part_unlocked(array[part_index]):
			unlocked_part_indexes.append(part_index)
	return unlocked_part_indexes

func on_play_pressed() -> void:
	play_pressed = true
	for button in buttons:
		button.disabled = true
	SaveDataManager.set_last_used_parts([
		turrets[selected_turret_index],
		bodies[selected_body_index],
		copilots[selected_copilot_index],
		])
	SaveDataManager.set_last_difficulty(difficulties[selected_difficulty_index])
	SaveDataManager.save()
	if map_complete:
		start_game()
	else:
		anim_player.play("Loading")

func on_settings_button_pressed():
	settings_menu.visible = true
	settings_menu.gain_focus()

func settings_vis_changed() -> void:
	h_box_container.visible = not settings_menu.visible
	if not settings_menu.visible:
		play.grab_focus()

func change_turret(dir := 1) -> void:
	selected_turret_index += dir
	if selected_turret_index > turrets.size() - 1:
		selected_turret_index = 0
	elif selected_turret_index < 0:
		selected_turret_index = turrets.size() - 1
	turret_label.text = turrets[selected_turret_index].display_name
	turret_desc.text = turrets[selected_turret_index].description
	if turret_obj:
		turret_obj.queue_free()
	turret_obj = loaded_turrets[selected_turret_index].instantiate()
	turret_obj.position = turret_preview.size/2
	turret_preview.add_child(turret_obj)
	var unlocked = SaveDataManager.is_part_unlocked(turrets[selected_turret_index])
	turret_buy.visible = not unlocked
	if not unlocked:
		turret_obj.use_parent_material = false
		turret_obj.material = unlock_mat
		turret_buy.text = "RP: " + str(int(turrets[selected_turret_index].unlock_price))
		turret_buy.disabled = turrets[selected_turret_index].unlock_price > SaveDataManager.save_data.research_points
	update_play_button()

func change_body(dir := 1) -> void:
	selected_body_index += dir
	if selected_body_index > bodies.size() - 1:
		selected_body_index = 0
	elif selected_body_index < 0:
		selected_body_index = bodies.size() - 1
	body_label.text = bodies[selected_body_index].display_name
	body_desc.text = bodies[selected_body_index].description
	if chassis_obj:
		chassis_obj.queue_free()
	chassis_obj = loaded_bodies[selected_body_index].instantiate()
	chassis_obj.position = chassis_preview.size/2
	chassis_preview.add_child(chassis_obj)
	var unlocked = SaveDataManager.is_part_unlocked(bodies[selected_body_index])
	body_buy.visible = not unlocked
	if not unlocked:
		chassis_obj.use_parent_material = false
		chassis_obj.material = unlock_mat
		body_buy.text = "RP: " + str(int(bodies[selected_body_index].unlock_price))
		body_buy.disabled = bodies[selected_body_index].unlock_price > SaveDataManager.save_data.research_points
	update_play_button()

func change_copilot(dir := 1) -> void:
	selected_copilot_index += dir
	if selected_copilot_index > copilots.size() - 1:
		selected_copilot_index = 0
	elif selected_copilot_index < 0:
		selected_copilot_index = copilots.size() - 1
	copilot_label.text = copilots[selected_copilot_index].display_name
	copilot_desc.text = copilots[selected_copilot_index].description
	if copilot_obj:
		copilot_obj.queue_free()
	copilot_obj = loaded_copilot_art[selected_copilot_index].instantiate()
	copilot_obj.position = copilot_preview.size/2
	copilot_preview.add_child(copilot_obj)
	var unlocked = SaveDataManager.is_part_unlocked(copilots[selected_copilot_index])
	copilot_buy.visible = not unlocked
	if not unlocked:
		copilot_obj.use_parent_material = false
		copilot_obj.material = unlock_mat
		copilot_buy.text = "RP: " + str(int(copilots[selected_copilot_index].unlock_price))
		copilot_buy.disabled = copilots[selected_copilot_index].unlock_price > SaveDataManager.save_data.research_points
	update_play_button()

func change_difficulty(dir := 1) -> void:
	selected_difficulty_index += dir
	if selected_difficulty_index > difficulties.size() - 1:
		selected_difficulty_index = 0
	elif selected_difficulty_index < 0:
		selected_difficulty_index = difficulties.size() - 1
	difficulty_label.text = difficulties[selected_difficulty_index].NAME
	difficulty_desc.text = difficulties[selected_difficulty_index].DESCRIPTION

func update_play_button() -> void:
	var turret_unlocked = SaveDataManager.is_part_unlocked(turrets[selected_turret_index])
	var body_unlocked = SaveDataManager.is_part_unlocked(bodies[selected_body_index])
	var copilot_unlocked = SaveDataManager.is_part_unlocked(copilots[selected_copilot_index])
	play.disabled = not (turret_unlocked and body_unlocked and copilot_unlocked)

func start_game() -> void:
	var body: PlayerBody = loaded_bodies[selected_body_index].instantiate()
	var turret = loaded_turrets[selected_turret_index].instantiate()
	var copilot = loaded_copilots[selected_copilot_index].instantiate()
	player.add_child(body)
	player.add_child(turret)
	player.add_child(copilot)
	player.connect_parts(turret, body, copilot)

	wave_spawner.DIFFICULTY = difficulties[selected_difficulty_index]
	body.health_component.max_health *= wave_spawner.DIFFICULTY.HP_MOD
	body.health_component.health *= wave_spawner.DIFFICULTY.HP_MOD

	doom_melt.generate_offsets()
	doom_melt.transition()
	color_rect.visible = false
	h_box_container.visible = false
	lower_right_container.visible = false
	upper_left_container.visible = false
	travel_text.visible = false
	travel_progress.visible = false
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	turret_obj.queue_free()
	chassis_obj.queue_free()

	if not RunDataManager.run_is_active:
		RunDataManager.new_run()
		var parts: Array[Unlock] = [
			turrets[selected_turret_index],
			bodies[selected_body_index],
			copilots[selected_copilot_index]
			]
		RunDataManager.set_run_start_info(parts, wave_spawner.DIFFICULTY)
		RunDataManager.run_is_active = true

	pause_manager.CAN_TOGGLE_PAUSE = true
	player_ui.start_tracking()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_effect_enabled(index, 0, false)
	var song_choice = RunDataManager.current_loop % songs.size()
	MusicManager.play_music(songs[song_choice])
	pause_manager.CAN_TOGGLE_PAUSE = true
	get_tree().set_deferred("paused", false)

func return_to_main_menu() -> void:
	for button in buttons:
		button.disabled = true
	SceneManager.change_scene("res://Scenes/main_menu.tscn", {
		"pattern": "squares",
		"invert_on_leave": true
	})

func get_last_part_indexes() -> void:
	var last_parts = SaveDataManager.get_last_used_parts()
	for part in last_parts:
		if part.unlock_type == Unlock.unlock_types.TURRET:
			for index in turrets.size():
				if turrets[index].display_name == part.display_name:
					selected_turret_index = index
		if part.unlock_type == Unlock.unlock_types.BODY:
			for index in bodies.size():
				if bodies[index].display_name == part.display_name:
					selected_body_index = index
		if part.unlock_type == Unlock.unlock_types.COPILOT:
			for index in copilots.size():
				if copilots[index].display_name == part.display_name:
					selected_copilot_index = index

func buy_unlock(unlock: Unlock) -> void:
	if not SaveDataManager.modify_research_points(-unlock.unlock_price):
		return
	SaveDataManager.unlock_parts([unlock])
	SaveDataManager.save()
	update_rp_text()

func update_rp_text() -> void:
	#SaveDataManager.modify_research_points(9999, true)
	rp_total_text.text = "RP: " + str(SaveDataManager.save_data.research_points)

func get_last_difficulty_index() -> void:
	var last_difficulty = SaveDataManager.get_last_difficulty()
	if last_difficulty != null:
		for index in difficulties.size():
			if difficulties[index].NAME == last_difficulty.NAME:
				selected_difficulty_index = index

func contine_run() -> void:
	h_box_container.set_deferred("visible", false)
	lower_right_container.set_deferred("visible", false)
	upper_left_container.set_deferred("visible", false)
	travel_text.visible = true
	travel_progress.visible = true

	var run: RunData = RunDataManager.current_run
	player.upgrades = run.upgrades.duplicate(true)

	#TODO more
	on_play_pressed()
