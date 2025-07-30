extends Resource
class_name Difficulty

@export var NAME := "" #----------------- Display name when picking difficulty
@export_multiline var DESCRIPTION := "" # Description of difficulty when hovering
@export var HP_MOD := 1.0 #-------------- Player starting HP Multiplier
@export var WAVE_TIME := 300 #----------- Time in seconds each wave difficulty will last
@export var rp_mult := 1.0 #------------- Earnings multiplier
