extends Node2D
class_name BuzzsawDrone

@export var base_damage := 100.0
@export var knockback := 300
@export var spread := true
@export var impact_sfx: String

var player: Player

@onready var hit_box: HitBox = $HitBox

func _ready() -> void:
	hit_box.area_entered.connect(hit_box._on_area_entered)
	hit_box.hitbox_triggered.connect(deal_damage)

func get_damage() -> float:
	return player.support_damage_mult * base_damage

func deal_damage(area) -> void:
	if area is HurtBox:
		# Apply damage
		var damage = get_damage()
		area.damage(damage, 0)
		if "knockback" in area.get_parent():
			area.get_parent().knockback = (global_position.direction_to(area.global_position)).normalized() * knockback
		SignalBus.enemy_hurt.emit(damage, 0, spread, area)
		#SignalBus.bullet_hit_target.emit(self)
		# Play SFX
		if impact_sfx:
			SoundManager.play_sound(impact_sfx)
