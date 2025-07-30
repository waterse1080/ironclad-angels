extends Node

#-Upgrades-
signal upgrade_selected #-(upgrade: ProtoUpgrade)
signal upgrades_done #----(void)
signal level_up #---------(times_to_level: int)
signal change_choice_count #(mod: int)
signal add_reroll # ------(mod: int)

#-Attacks-
signal bullet_destroyed #-(position: Vector2, damage: int, scale: float)
signal ammo_updated #-----(text: String, value: float, max: float)
signal enemy_hurt #-------(damage: int, crit_level: int, spread_effects: bool, area: HurtBox)
signal enemy_destroyed #--(position: Vector2)
signal boss_destroyed #---()
signal bullet_hit_target #(bullet: ProtoBullet)
signal bullet_spawned #---(bullet: ProtoBullet)
signal missile_spawned #--(missile: Missile)

#-Game State-
signal game_over ##-------(new_cam: Camera2D, current_level: int, upgrades: Array[BaseUpgrade])
signal level_cleanup ## --()
signal boss_spawn_progress ## (boss: EnemyStash.ENEMIES, progress_mod: int)
signal boss_spawned #-----(boss_health_comp: HealthComponent, boss_name: String, boss_hp: float)
signal objectives_complete # ()
signal add_objective_marker ## (objective: Node2D)
signal area_cleared # ()
