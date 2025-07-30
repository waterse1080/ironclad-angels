class_name Unlock
extends Resource

enum unlock_types {TURRET, BODY, COPILOT}

@export var display_name := "Default Name"
@export_multiline var description: = "Default description."
@export var unlock_type: unlock_types
@export var unlock_price := 0.0
@export var unlock_node_path: String

var loaded_unlock: Node
