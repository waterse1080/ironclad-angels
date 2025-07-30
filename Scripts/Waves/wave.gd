extends Resource
class_name Wave

# Lists of enemies to spawn in each wave
@export_group("Enemy Lists")
@export var STANDARD: Array[EnemyStash.ENEMIES]
@export var RARE: Array[EnemyStash.ENEMIES]
@export var INITIAL: Array[EnemyStash.ENEMIES]

# Timers for enemy spawns in seconds between spawns
@export_group("Spawn Timers")
@export var STANDARD_SPAWN_TIMER := 2.0
@export var RARE_SPAWN_TIMER := 5.0
# How long to wait after spawning a INITIAL enemy before normal spawning resumes
@export var INITIAL_SPAWN_TIMER_DELAY := 0.0
@export var TOTAL_WAVE_TIME := 30.0

# Enemies to spawn per instance
@export_group("Spawn Wave Sizes")
@export var STANDARD_SPAWN_COUNT := 1
@export var RARE_SPAWN_COUNT := 1
@export var INITIAL_SPAWN_COUNT := 1

# Base value modifications
@export_group("Stat Mods")
@export var STANDARD_HEALTH_MULT := 1.0
@export var RARE_HEALTH_MULT := 1.0
@export var INITIAL_HEALTH_MULT := 1.0

@export var STANDARD_DAMAGE_MULT := 1.0
@export var RARE_DAMAGE_MULT := 1.0
@export var INITIAL_DAMAGE_MULT := 1.0

@export var STANDARD_SPEED_MULT := 1.0
@export var RARE_SPEED_MULT := 1.0
@export var INITIAL_SPEED_MULT:= 1.0

@export var STANDARD_SCALE_MULT := 1.0
@export var RARE_SCALE_MULT := 1.0
@export var INITIAL_SCALE_MULT:= 1.0
