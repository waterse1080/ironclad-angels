class_name Player
extends CharacterBody2D

@export var turret: PlayerTurret
@export var body: PlayerBody
@export var copilot: PlayerCopilot
@export var upgrades: Array[BaseUpgrade]

var game_started := false
var support_damage_mult := 1.0

@onready var level_tracker_component = $LevelTrackerComponent as LevelTrackerComponent
@onready var camera = $Camera2D as PlayerCamera
@onready var anim_player = $AnimationPlayer as AnimationPlayer
@onready var collider: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	SignalBus.upgrade_selected.connect(add_upgrade)
	SignalBus.bullet_spawned.connect(bullet_spawned)
	SignalBus.bullet_hit_target.connect(bullet_hit_target)
	SignalBus.enemy_hurt.connect(enemy_hurt)
	SignalBus.enemy_destroyed.connect(enemy_destroyed)
	level_tracker_component.xp_collected.connect(xp_collected)

func connect_parts(
	new_turret: PlayerTurret,
	new_body: PlayerBody,
	new_copilot: PlayerCopilot
	) -> void:

	turret = new_turret
	body = new_body
	copilot = new_copilot
	turret.connect_parts(body, self)
	body.connect_parts(turret, self)
	copilot.connect_parts(turret, self, body)

	game_started = true
	call_deferred("apply_initial_upgrades")

func apply_initial_upgrades() -> void:
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_add"):
			upgrade.on_add(self)
		upgrade.adjust_copies_count(1)

func _physics_process(delta) -> void:
	if not game_started:
		return
	handle_input(delta)
	move_and_slide()

func handle_input(delta) -> void:
	body.handle_input(delta)
	turret.handle_input(delta)

func bullet_spawned(projectile: ProtoBullet) -> void:
	var seen_uprgades = []
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_bullet_spawn") and seen_uprgades.find(upgrade) == -1:
			upgrade.on_bullet_spawn(projectile)
			seen_uprgades.append(upgrade)

func bullet_hit_target(projectile: ProtoBullet) -> void:
	var seen_uprgades = []
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_bullet_hit_target") and seen_uprgades.find(upgrade) == -1:
			upgrade.on_bullet_hit_target(projectile)
			seen_uprgades.append(upgrade)

func enemy_hurt(damage: int, crit_level: int, spread_effects: bool, area: HurtBox) -> void:
	var seen_uprgades = []
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("enemy_hurt") and seen_uprgades.find(upgrade) == -1:
			upgrade.enemy_hurt(damage, crit_level, spread_effects, area)
			seen_uprgades.append(upgrade)

func enemy_destroyed(pos: Vector2) -> void:
	var seen_uprgades = []
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_enemy_destroyed") and seen_uprgades.find(upgrade) == -1:
			upgrade.on_enemy_destroyed(pos, self)
			seen_uprgades.append(upgrade)

func xp_collected() -> void:
	var seen_uprgades = []
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_xp_collected") and seen_uprgades.find(upgrade) == -1:
			upgrade.on_xp_collected(self)
			seen_uprgades.append(upgrade)

func add_upgrade(upgrade: BaseUpgrade) -> void:
	#TODO: Add a "unique" check for upgrades
	#if upgrades.find(upgrade) != -1:
		#return
	if upgrade.has_method("on_add"):
		upgrade.on_add(self)
	upgrades.append(upgrade)
	upgrade.adjust_copies_count(1)

func remove_upgrade(upgrade: BaseUpgrade) -> void:
	var index = upgrades.find(upgrade)
	if index == -1:
		return
	if upgrade.has_method("on_remove"):
		upgrade.on_remove(self)
	upgrades.remove_at(index)
	upgrade.adjust_copies_count(-1)

func apply_bullet_upgrades(projectile: ProtoBullet, is_support: bool = false) -> void:
	var seen_uprgades = []
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_fire") and seen_uprgades.find(upgrade) == -1:
			upgrade.on_fire(projectile, self, is_support)
			seen_uprgades.append(upgrade)
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_fire_add"):
			upgrade.on_fire_add(projectile, self, is_support)
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_fire_mult"):
			upgrade.on_fire_mult(projectile, self, is_support)

func apply_bullet_limits(projectile: ProtoBullet, is_support: bool = false) -> void:
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_fire_limit_add"):
			upgrade.on_fire_limit_add(projectile, self, is_support)
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_fire_limit_mult"):
			upgrade.on_fire_limit_mult(projectile, self, is_support)
	for upgrade in upgrades:
		if upgrade != null and upgrade.has_method("on_fire_limit_set"):
			upgrade.on_fire_limit_set(projectile, self, is_support)

func enable_hurtbox() -> void:
	body.enable_hurtbox()
