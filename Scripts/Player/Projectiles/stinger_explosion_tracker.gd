class_name StingerExplosionTracker
extends Node2D

@export var hits_to_explosion: int = 6
@export var explosion_texture: Texture2D = load(
	"res://Assets/Images/SpriteSheets/Animations/explosion-2.png"
	)
@export var explosion_sfx: Array[String] = ["StingerExplosionSFX", "StingerExplosionSFX2"]
var hit_count: int = 1
var explosion_preload = load("res://Scenes/explosion.tscn")
var total_damage: float = 0.0
var tree_root: Window

func connect_to_parent(new_parent: Node2D) -> void:
	new_parent.tree_exiting.connect(explode_on_death)
	SceneManager.scene_reloaded.connect(queue_free)
	tree_root = new_parent.get_tree().root

func explode_on_death() -> void:
	if hit_count > 0:
		explode()

func add_hit(dmg: float = 1) -> void:
	hit_count += 1
	total_damage += dmg
	if hit_count >= hits_to_explosion:
		explode()

func explode() -> void:
	var hit_scale = float(hit_count) / float(hits_to_explosion)
	hit_count = 0
	var explosion: Explosion = explosion_preload.instantiate()
	explosion.global_position = global_position
	explosion.explosion_texture = explosion_texture
	explosion.DAMAGE = total_damage
	explosion.explosion_sfx = explosion_sfx
	explosion.scale = Vector2(hit_scale, hit_scale)
	tree_root.call_deferred("add_child", explosion)
