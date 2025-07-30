extends BaseUpgrade
class_name BurnBulletUpgrade

@export var DMG_PER_TICK := 0.2
@export var TICK_TIME := 0.5
@export var DURATION := 5.0

var proto_player: Player
var burn_debuff = load("res://Scenes/Debuffs/burn_debuff.tscn")
var burn_particles = load("res://Scenes/Particles/burn_particles.tscn")

func on_add(player: Player):
	proto_player = player

#func on_bullet_spawn(bullet: ProtoBullet):
	#if bullet is Fire:
		#return
	#add_burn(bullet)

func enemy_hurt(_damage: int, _crit_level: int, spread_effects: bool, area: HurtBox):
	if spread_effects:
		add_dot(area)

func add_burn(bullet: ProtoBullet):
	var particles = burn_particles.instantiate() as BurnParticles
	particles.attatch(bullet)
	particles.emitting = true
	particles.amount = 16

func add_dot(area: HurtBox):
	var health_component = area.health_component
	var hit_target = health_component.get_parent()
	for child in hit_target.get_children():
		if child is BurnDebuff:
			child.DAMAGE_PER_TICK += DMG_PER_TICK * proto_player.turret.damage * upgrade_copies_count
			child.duration_timer = 0.0
			if child.DURATION < DURATION:
				child.DURATION = DURATION
			if child.TICK_TIME > TICK_TIME:
				child.DURATION = DURATION
			return
	var new_burn: BurnDebuff = burn_debuff.instantiate()
	# Apply values
	new_burn.DAMAGE_PER_TICK = DMG_PER_TICK * proto_player.turret.damage * upgrade_copies_count
	new_burn.TICK_TIME = TICK_TIME
	new_burn.DURATION = DURATION
	new_burn.add_to_target(hit_target, area)

func get_description() -> String:
	description = description.replace("$1", str(int(DMG_PER_TICK * 100)))
	description = description.replace("$2", str(int(DURATION)))
	return description
