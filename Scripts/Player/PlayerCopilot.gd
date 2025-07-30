class_name PlayerCopilot
extends Node

@export var player: Player
@export var turret: PlayerTurret
@export var body: PlayerBody
@export var upgrade_list: Array[BaseUpgrade] = []
@export var selection_asset_path: String

func connect_parts(new_turret: PlayerTurret, new_player: Player, new_body: PlayerBody):
	turret = new_turret
	player = new_player
	body = new_body
	on_part_connect()
	add_upgrades()

func on_part_connect() -> void:
	pass

func add_upgrades() -> void:
	for upgrade in upgrade_list:
		player.upgrades.append(upgrade)
