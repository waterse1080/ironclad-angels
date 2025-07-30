class_name RocketmanCopilot
extends PlayerCopilot

func on_part_connect() -> void:
	SignalBus.missile_spawned.connect(on_missile_spawned)

func on_missile_spawned(missile: Missile) -> void:
	missile.target = turret.aim
