class_name BossTrackerElement
extends HBoxContainer

var boss_count: int = 0
var boss_hp_load = load("res://Scenes/UI/boss_hp_bar.tscn")

func _ready() -> void:
	SignalBus.boss_spawned.connect(_on_boss_spawned)

func _on_boss_spawned(boss_health_comp: HealthComponent, boss_name: String) -> void:
	if MusicManager.current_song != MusicManager.SONGLIST.BOSS:
		MusicManager.play_music(MusicManager.SONGLIST.BOSS)
	var boss_hp_new = boss_hp_load.instantiate() as BossHPBar
	boss_hp_new.boss_health_comp = boss_health_comp
	boss_hp_new.boss_name = boss_name
	boss_hp_new.boss_destroyed.connect(_on_boss_death)
	call_deferred("add_child", boss_hp_new)
	boss_count += 1

func _on_boss_death() -> void:
	boss_count -= 1
	if boss_count == 0:
		if get_tree().get_nodes_in_group("objective").size() == 0:
			SignalBus.objectives_complete.emit()
		MusicManager.play_previous_song()
