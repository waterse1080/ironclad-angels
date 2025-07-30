extends Node

enum ITEMS{XP, XP_BIG, HEALTH, MAGNET, RADIO, REROLL, NONE}
enum TABLES{ENEMY, LOOTBOX, BUILDING, BOSS}

var xp_pickup = load("res://Scenes/Pickups/xp_pickup.tscn")
var health_pickup = load("res://Scenes/Pickups/health_pickup.tscn")
var magnet_pickup = load("res://Scenes/Pickups/magnet_pickup.tscn")
var radio_pickup = load("res://Scenes/Pickups/radio_pickup.tscn")
var reroll_pickup = load("res://Scenes/Pickups/reroll_pickup.tscn")

var enemy_table = [
	{
		item = ITEMS.XP,
		w = 100
	},
	{
		item = ITEMS.HEALTH,
		w = 5
	},
	{
		item = ITEMS.MAGNET,
		w = 2
	},
	{
		item = ITEMS.RADIO,
		w = 1
	},
	{
		item = ITEMS.REROLL,
		w = 1
	},
	]

var lootbox_table = [
	{
		item = ITEMS.XP,
		w = 100
	},
	{
		item = ITEMS.MAGNET,
		w = 2
	},
	{
		item = ITEMS.RADIO,
		w = 1
	},
	{
		item = ITEMS.REROLL,
		w = 2
	},
	]

var building_table = [
	{
		item = ITEMS.XP,
		w = 100
	},
	{
		item = ITEMS.HEALTH,
		w = 10
	},
	{
		item = ITEMS.MAGNET,
		w = 1
	},
	{
		item = ITEMS.RADIO,
		w = 1
	},
	{
		item = ITEMS.REROLL,
		w = 1
	},
	{
		item = ITEMS.NONE,
		w = 1000
	},
	]

var boss_table = [
	{
		item = ITEMS.XP_BIG,
		w = 100
	},
	]

var table_list = {
	TABLES.ENEMY: enemy_table,
	TABLES.LOOTBOX: lootbox_table,
	TABLES.BUILDING: building_table,
	TABLES.BOSS: boss_table
}

func drop_rand_pickup(
	scene_tree: SceneTree,
	global_position: Vector2i,
	xp_total: float = 10.0,
	table_enum: DropTable.TABLES = TABLES.ENEMY,
	alt_table: Array = []
	) -> Pickup:

	var table = null
	if table_enum != null:
		table = table_list[table_enum].duplicate()
	if alt_table and alt_table.size() > 0:
		table = alt_table.duplicate()
	if table == null:
		push_error("Something went wrong with the drop table, exiting...")
		return null

	var total_weight = 0
	for item in table:
		total_weight += item.w

	var rng = randi() % total_weight
	var pickup_weight = 0
	for item in table:
		pickup_weight += item.w
		if rng <= pickup_weight:
			return spawn_pickup(scene_tree, global_position, xp_total, item)
	return null

func spawn_pickup(
	scene_tree: SceneTree,
	global_position: Vector2i,
	xp_total: float, item
	) -> Pickup:

	var item_type = item.item
	var pickup = null
	if item_type == ITEMS.XP:
		pickup = xp_pickup.instantiate()
		pickup.xp = xp_total
	elif item_type == ITEMS.XP_BIG:
		pickup = xp_pickup.instantiate()
		pickup.scale.x += 1
		pickup.scale.y += 1
		pickup.xp = xp_total #* 5
	elif item_type == ITEMS.HEALTH:
		pickup = health_pickup.instantiate()
	elif item_type == ITEMS.MAGNET:
		pickup = magnet_pickup.instantiate()
	elif item_type == ITEMS.RADIO:
		pickup = radio_pickup.instantiate()
	elif item_type == ITEMS.REROLL:
		pickup = reroll_pickup.instantiate()
	elif item_type == ITEMS.NONE:
		return null
	else:
		push_warning("Something has gone wrong, unrecognized item attempted to drop")
		push_warning(item)
		return null

	if pickup:
		pickup.global_position = global_position
		scene_tree.root.call_deferred("add_child", pickup)
	return pickup
