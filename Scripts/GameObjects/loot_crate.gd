class_name LootCrate
extends DestructibleObject

@export var loot_table: DropTable.TABLES = DropTable.TABLES.LOOTBOX

func destroy() -> void:
	DropTable.drop_rand_pickup(get_tree(), self.global_position, 10.0, loot_table)
	super.destroy()
