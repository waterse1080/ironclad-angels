class_name PlayerBody
extends Node2D

signal update_boost
signal update_boost_timer

@export var turret: PlayerTurret
@export var player: Player
@export var hurt_sfx: String = "PlayerDamageSFX"
@export var boost_sfx: String = "PlayerBoostSFX"
@export var boost_sfx_delay: float = 0.3
@export var acceleration := 10.0
@export var decceleration := 10.0
@export var move_speed := 300.0
@export var ability_cooldown_time: float = 5.0
@export var can_destroy_terrain: bool = true
@export var boost_speed: float = 150.0
@export var boost_duration_max: float = 3.0

var ability_cooldown: float = 0.0
var starting_speed: float = 0.0
var boost_duration: float = 0.0
var boost_sfx_timer: float = boost_sfx_delay
var can_boost: bool = true
var is_boosting: bool = false

@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_num_origin = $DamageNumbersOrigin
@onready var pickup_collider: PickupBox = $PickupBox
@onready var hurtbox: HurtBox = $HurtBox
@onready var hurtbox_collider: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var terrain_detection_component: TerrainDetectionComponent = $TerrainDetectionComponent
@onready var boost_cooldown_timer: Timer = $BoostCooldownTimer
@onready var dmg_smoke: SmokeParticles = $DamageSmokeParticles
@onready var dmg_fire: BurnParticles = $DamageBurnParticles

@onready var vibration_intensity_setting = preload("res://game_settings/setting_vibration_intensity.tres")

func _ready():
	health_component.health_depleted.connect(_on_health_component_health_depleted)
	health_component.hurt.connect(_on_health_component_hurt)
	health_component.healed.connect(_on_health_component_healed)
	hurtbox.body_shape_entered.connect(on_body_shape_entered)
	boost_cooldown_timer.timeout.connect(on_boost_cooldown_finished)
	starting_speed = move_speed
	extra_ready()

func extra_ready() -> void:
	pass

func on_boost_toggle() -> void:
	pass

func on_boost_cooldown_finished() -> void:
	can_boost = true
	boost_duration = 0.0
	update_boost.emit()

func connect_parts(new_turret: PlayerTurret, new_player: Player):
	turret = new_turret
	player = new_player
	pickup_collider.player = new_player

func handle_input(delta):
	# Handle boost input
	handle_boost_input(delta)
	var current_speed = move_speed
	var current_acceleration = acceleration
	boost_sfx_timer += delta
	if is_boosting:
		current_speed += boost_speed
		current_acceleration += acceleration
		if boost_sfx_timer >= boost_sfx_delay:
			boost_sfx_timer = 0.0
			SoundManager.play_sound(boost_sfx)

	# Get the input direction and handle the movement/deceleration.
	var move_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	var terrain_mult = terrain_detection_component.get_speed_mod()
	var new_velocity = move_direction.normalized() * current_speed * terrain_mult

	if new_velocity.x:
		player.velocity.x = lerp(player.velocity.x, new_velocity.x, current_acceleration * delta)
	else:
		player.velocity.x = lerp(player.velocity.x, new_velocity.x, decceleration * delta)

	if new_velocity.y:
		player.velocity.y = lerp(player.velocity.y, new_velocity.y, current_acceleration * delta)
	else:
		player.velocity.y = lerp(player.velocity.y, new_velocity.y, decceleration * delta)

	# rotate lower section
	if move_direction.x or move_direction.y:
		rotation = player.velocity.angle() + PI / 2
	extra_input(delta)

func handle_boost_input(delta: float) -> void:
	if can_boost:
		var boost_input = Input.is_action_pressed("Boost")
		var old_duration = boost_duration

		if boost_input:
			if not is_boosting:
				is_boosting = true
				on_boost_toggle()
			boost_duration += delta
		else:
			if is_boosting:
				is_boosting = false
				on_boost_toggle()
			boost_duration -= delta

		boost_duration = clampf(boost_duration, 0.0, boost_duration_max)

		if boost_duration != old_duration:
			update_boost.emit()
		if boost_duration >= boost_duration_max:
			is_boosting = false
			can_boost = false
			on_boost_toggle()
			boost_cooldown_timer.start()
	else:
		update_boost_timer.emit()

func extra_input(_delta) -> void:
	pass

func use_ability() -> void:
	pass

func game_over():
	var new_cam = player.camera.duplicate()
	new_cam.global_position = player.camera.global_position
	get_tree().root.call_deferred("add_child", new_cam)
	SignalBus.game_over.emit(new_cam, player.level_tracker_component.current_level, player.upgrades)
	for upgrade in player.upgrades:
		upgrade.upgrade_copies_count = 0

func on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int):
	# TODO: change this to a component like tile detection
	if not can_destroy_terrain:
		return

	if body is TileMapLayer:
		var current_tilemap: TileMapLayer = body
		var collided_tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)
		var tile_data = current_tilemap.get_cell_tile_data(collided_tile_coords)
		var terrain_type = tile_data.get_custom_data_by_layer_id(0)
		if terrain_type == 3:
			var rubble_location = tile_data.get_custom_data_by_layer_id(1)
			current_tilemap.set_cell(collided_tile_coords, 0, rubble_location)
			var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
			Input.start_joy_vibration(0, 0.5 * v_mult, 0.7 * v_mult, 0.2)
			player.camera.apply_shake(5.0)
			SoundManager.play_sound("BuildingDestroySFX")

func _on_health_component_health_depleted():
	call_deferred("game_over")
	player.call_deferred("queue_free")

func _on_health_component_hurt(dmg: float, crit_level: int, _blood: bool):
	update_dmg_particles()
	player.camera.apply_shake()
	player.anim_player.play("hit")
	if hurt_sfx:
		SoundManager.play_sound(hurt_sfx)
	DamageNumbers.display_number(
		ceili(dmg),
		damage_num_origin.global_position,
		crit_level,
		Color.RED,
		"-"
		)
	var v_mult = GGS.get_value(vibration_intensity_setting) / 100.0
	Input.start_joy_vibration(0, 0.7 * v_mult, 0.9 * v_mult, 0.4)
	print(hurtbox_collider.disabled)
	disable_hurtbox()

func _on_health_component_healed(healing):
	update_dmg_particles()
	DamageNumbers.display_number(
		ceili(healing),
		damage_num_origin.global_position,
		0,
		Color.LIME_GREEN,
		"+"
		)

func update_dmg_particles() -> void:
	var health_percent = health_component.health / health_component.max_health
	dmg_smoke.emitting = health_percent <= 0.5
	dmg_fire.emitting = health_percent <= 0.25

func disable_hurtbox() -> void:
	hurtbox_collider.set_deferred("disabled", true)

func enable_hurtbox() -> void:
	hurtbox_collider.set_deferred("disabled", false)
