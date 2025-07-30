class_name AlienEgg
extends DestructibleObject

@export var loot_table: DropTable.TABLES = DropTable.TABLES.LOOTBOX
@export var boss_progress_mod: int = 0 #kludge to make only the last egg spawn a boss
@export var boss_to_spawn: EnemyStash.ENEMIES = EnemyStash.ENEMIES.WORM_BOSS_BUG

#func _ready() -> void:
	#SignalBus.add_objective_marker.emit(self)

func set_sprite(_tileset: TileSet, _location: Vector2i) -> void:
	SignalBus.add_objective_marker.emit(self)

func destroy() -> void:
	DropTable.drop_rand_pickup(get_tree(), self.global_position, 10.0, loot_table)
	var egg_count: int = 0
	var objectives = get_tree().get_nodes_in_group("objective")
	for obj in objectives:
		if obj is AlienEgg:
			egg_count += 1
	var player = get_tree().get_first_node_in_group("player")
	DamageNumbers.display_number(
		egg_count - 1,
		damage_num_origin.global_position,
		0,
		Color.DARK_ORANGE,
		"Egg destroyed, ",
		" left",
		36
	)
	if egg_count <= 1:
		boss_progress_mod = 100
	SignalBus.boss_spawn_progress.emit(boss_to_spawn, boss_progress_mod)
	super.destroy()
