class_name HeavyTankBody
extends PlayerBody

@export var damage: float = 300.0
@export var impact_sfx: String = "BulletImpactSFX"
@export var move_fps: float = 30.0

var current_frame: float = 0.0

@onready var treads_1: CPUParticles2D = $TreadMarks
@onready var treads_2: CPUParticles2D = $TreadMarks2
@onready var treads_3: CPUParticles2D = $TreadMarks3
@onready var treads_4: CPUParticles2D = $TreadMarks4
@onready var tank_lower: Sprite2D = $Sprite2D
@onready var hit_box: HitBox = $HitBox
@onready var hit_box_collider: CollisionPolygon2D = $HitBox/CollisionPolygon2D
@onready var smoke: SmokeParticles = $BoostSmokeParticles
@onready var smoke2: SmokeParticles = $BoostSmokeParticles2

func extra_ready() -> void:
	hit_box.hitbox_triggered.connect(_on_hit_box_hitbox_triggered)

func extra_input(delta) -> void:
	var modifier = (player.velocity.length() / move_speed) * (move_speed / starting_speed)

	current_frame += delta * move_fps * modifier
	if floori(current_frame) > tank_lower.hframes - 1:
		current_frame = 0
	tank_lower.frame = floori(current_frame)

	if player.velocity.length() < 1:
		treads_1.emitting = false
		hit_box_collider.set_deferred("disabled", true)
	else:
		treads_1.emitting = true
		hit_box_collider.set_deferred("disabled", false)

	treads_2.emitting = treads_1.emitting
	treads_3.emitting = treads_1.emitting
	treads_4.emitting = treads_1.emitting
	treads_1.speed_scale = modifier
	treads_2.speed_scale = modifier
	treads_3.speed_scale = modifier
	treads_4.speed_scale = modifier

	smoke.emitting = is_boosting
	smoke2.emitting = is_boosting

func _on_hit_box_hitbox_triggered(area):
	if area is HurtBox:
		if impact_sfx:
			SoundManager.play_sound(impact_sfx)
		area.damage(damage, 0)
