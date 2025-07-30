class_name AmmoTrackerComponent
extends Node

signal ammo_updated
signal reload_started
signal reload_updated
signal reload_canceled
signal reload_complete

enum ReloadState {READY, RELOADING}
enum ReloadType {STANDARD, RECHARGE, SINGLETON}

@export var starting_max_ammo: float = 10.0
@export var ammo_per_shot: float = 1.0
@export var reload_time: float = 1.0 # seconds
@export var reload_start_sfx: String
@export var reload_end_sfx: String
@export var recharge_rate: float = 0.0 # per second
@export var recharge_cooldown: float = 0.25 # seconds
@export var reload_type: ReloadType = ReloadType.STANDARD

var max_ammo: float
var current_ammo: float
var current_ammo_per_shot: float
var current_state: ReloadState = ReloadState.READY
var reload_timer: float = 0.0
var recharge_cooldown_timer: float = 0.0

func _ready() -> void:
	max_ammo = starting_max_ammo
	current_ammo = starting_max_ammo
	current_ammo_per_shot = ammo_per_shot
	await get_tree().create_timer(0.25).timeout
	ammo_updated.emit(current_ammo, max_ammo)

func process_reload(delta: float) -> void:
	if current_state == ReloadState.READY and current_ammo <= 0.0:
		start_reload()
	elif Input.is_action_pressed("Reload") and current_ammo < max_ammo:
		start_reload()
	
	if recharge_rate > 0.0:
		recharge_cooldown_timer -= delta
		if recharge_cooldown_timer <= 0.0:
			add_ammo(recharge_rate * delta)

	if current_state == ReloadState.RELOADING:
		reload_timer += delta
		if reload_timer >= reload_time:
			add_ammo(max_ammo)
			current_state = ReloadState.READY
			if reload_end_sfx:
				SoundManager.play_sound(reload_end_sfx)
			reload_complete.emit(current_ammo, max_ammo)
			reload_timer = 0.0
		else:
			reload_updated.emit(reload_timer, reload_time)

func use_ammo(shot_count: float = 1.0) -> bool:
	if current_ammo <= 0.0:
		return false
	if current_state == ReloadState.RELOADING:
		cancel_reload()
	current_ammo -= shot_count * current_ammo_per_shot
	if current_ammo <= 0.0:
		current_ammo = 0.0
		start_reload()
	ammo_updated.emit(current_ammo, max_ammo)
	recharge_cooldown_timer = recharge_cooldown
	return true

func add_ammo(amt: float) -> void:
	current_ammo += amt
	if current_ammo > max_ammo:
		current_ammo = max_ammo
	ammo_updated.emit(current_ammo, max_ammo)

func start_reload() -> void:
	if reload_type == ReloadType.RECHARGE:
		return
	if current_state == ReloadState.RELOADING:
		return
	current_state = ReloadState.RELOADING
	reload_timer = 0.0
	reload_started.emit(current_ammo, max_ammo)
	if reload_start_sfx:
		SoundManager.play_sound(reload_start_sfx)

func cancel_reload() -> void:
	if current_state == ReloadState.READY:
		return
	current_state = ReloadState.READY
	reload_timer = 0.0
	reload_canceled.emit(current_ammo, max_ammo)
