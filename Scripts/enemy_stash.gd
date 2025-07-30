extends Node

enum ENEMIES {
	MELEE_BUG,
	RANGED_BUG,
	FLYING_BUG,
	FIREFLY_BUG,
	SMALL_BUG,
	WORM_BOSS_BUG,
	PILL_BUG
}

const EnemyScenes = {
	MELEE_BUG = preload("res://Scenes/Enemies/Bugs/melee_bug_enemy.tscn"),
	RANGED_BUG = preload("res://Scenes/Enemies/Bugs/ranged_enemy.tscn"),
	FLYING_BUG = preload("res://Scenes/Enemies/Bugs/flying_bug_enemy.tscn"),
	FIREFLY_BUG = preload("res://Scenes/Enemies/Bugs/firefly_bug_enemy.tscn"),
	SMALL_BUG = preload("res://Scenes/Enemies/Bugs/small_bug_enemy.tscn"),
	WORM_BOSS_BUG = preload("res://Scenes/Enemies/Bugs/worm/worm_head.tscn"),
	PILL_BUG = preload("res://Scenes/Enemies/Bugs/pill_bug_enemy.tscn")
}

func load_enemy_scene(enemy: ENEMIES):
	match enemy:
		ENEMIES.MELEE_BUG:
			return EnemyScenes.MELEE_BUG
		ENEMIES.RANGED_BUG:
			return EnemyScenes.RANGED_BUG
		ENEMIES.FLYING_BUG:
			return EnemyScenes.FLYING_BUG
		ENEMIES.FIREFLY_BUG:
			return EnemyScenes.FIREFLY_BUG
		ENEMIES.SMALL_BUG:
			return EnemyScenes.SMALL_BUG
		ENEMIES.WORM_BOSS_BUG:
			return EnemyScenes.WORM_BOSS_BUG
		ENEMIES.PILL_BUG:
			return EnemyScenes.PILL_BUG
	push_error("WARNING: Returning default enemy for spawning")
	return EnemyScenes.SMALL_BUG
