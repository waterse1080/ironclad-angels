class_name NaniteSwarm2DComponent
extends Node2D

@export var damage: float = 10.0
@export var impact_sfx: String

var player: Player
var enable_flag: bool = false

@onready var hitbox: HitBox = $HitBox
@onready var hitbox_collider: CollisionShape2D = $HitBox/CollisionShape2D

func _ready() -> void:
	hitbox.area_entered.connect(hitbox._on_area_entered)
	hitbox.hitbox_triggered.connect(_on_hit_box_hitbox_triggered)

func _physics_process(_delta: float) -> void:
	if hitbox_collider.disabled and enable_flag == false:
		enable_flag = true
	elif enable_flag == true:
		enable_hurtbox()
		enable_flag = false

func _on_hit_box_hitbox_triggered(area) -> void:
	if area is HurtBox:
		if impact_sfx:
			SoundManager.play_sound(impact_sfx)
		area.damage(damage * player.support_damage_mult, 0)

func disable_hitbox() -> void:
	hitbox_collider.set_deferred("disabled", true)

func enable_hurtbox() -> void:
	hitbox_collider.set_deferred("disabled", false)
