class_name TroopSpawnerComponent
extends BaseTimedComponent

@export var voice_packs: Array[VoicePack] = []
@export var helldive_range: float = 300.0
@export var helljump_upgrade: HelljumpUpgrade

var troop_count_max: int = 5
var player: Player
var soldier_preload = load("res://Scenes/basic_soldier.tscn")
var bomb_preload = load("res://Scenes/falling_bomb.tscn")

func on_timer_complete() -> void:
	var troop_count = get_tree().get_nodes_in_group("soldiers").size() #May miscount helldives
	if troop_count < troop_count_max:
		if helljump_upgrade.upgrade_copies_count > 0:	
			helljump_deploy()
		else:
			deploy_soldier(player.global_position)

func deploy_soldier(pos: Vector2) -> void:
	var soldier: BasicSoldier = soldier_preload.instantiate()
	soldier.player = player
	soldier.move_target = player
	soldier.global_position = pos
	if voice_packs.size() > 0:
		soldier.voice_pack = voice_packs.pick_random()
	player.call_deferred("add_sibling", soldier)

func helljump_deploy() -> void:
	var bomb: FallingBomb = bomb_preload.instantiate()
	var range_mod = Vector2(
		randf_range(-helldive_range, helldive_range),
		randf_range(-helldive_range, helldive_range)
	)
	var pos = player.global_position + range_mod
	bomb.boss = false
	bomb.global_position = pos
	#bomb.explosion_damage = projectile_damage
	player.call_deferred("add_sibling", bomb)
	call_deferred("helljump_deploy_standby", bomb, pos)

func helljump_deploy_standby(bomb: FallingBomb, pos: Vector2) -> void:
	await bomb.animation_player.animation_finished
	deploy_soldier(pos)
