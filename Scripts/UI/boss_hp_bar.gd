class_name BossHPBar
extends VBoxContainer

signal boss_destroyed

var boss_name: String = "Boss Name Here"
var boss_health_comp: HealthComponent

@onready var bar: ProgressBar = $ProgressBar
@onready var label: LabelAutoSizer = $LabelAutoSizer
@onready var hp_shaker: ShakerComponent = $ProgressBar/ShakerComponent

func _ready() -> void:
	label.text = boss_name
	boss_health_comp.hurt.connect(hurt)
	boss_health_comp.health_depleted.connect(destroy)

func hurt(health := 0.0, _crit := false, _blood := false) -> void:
	hp_shaker.force_stop_shake()
	hp_shaker.play_shake()
	if boss_health_comp:
		bar.max_value = boss_health_comp.max_health
		bar.value = boss_health_comp.health
	else:
		push_warning("boss_health_comp does not exist")

func destroy() -> void:
	boss_destroyed.emit()
	call_deferred("queue_free")
