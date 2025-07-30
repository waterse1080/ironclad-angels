extends Node

var called_this_frame: Array[String] = []

func _physics_process(delta: float) -> void:
	called_this_frame.clear()

func play_sound(key: String, pitch_min := 0.9, pitch_max := 1.1):
	if called_this_frame.find(key) != -1:
		return
	called_this_frame.append(key)
	var sound = self.find_child(key, true)
	if sound is AudioStreamPlayer:
		sound.pitch_scale = randf_range(pitch_min, pitch_max)
		sound.play()
	else:
		push_error("Sound " + key + " not found!")

func stop_sound(key: String):
	var sound = self.find_child(key, true)
	if sound is AudioStreamPlayer:
		sound.stop()
	else:
		push_error("Sound " + key + " not found!")
