extends Node2D

@onready var player: Player = $Player
@onready var falling_bomb: FallingBomb = $FallingBomb

func _ready() -> void:
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	falling_bomb.tree_exiting.connect(setup_player)

func setup_player() -> void:
	player.visible = true
	player.process_mode = Node.PROCESS_MODE_INHERIT
