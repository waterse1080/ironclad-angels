extends Node

enum SONGLIST {
	MAIN_MENU,
	STAGE1,
	BOSS,
	MISSION_COMPLETE,
	GAME_OVER,
	MISSION_PREP,
	STAGE2,
	STAGE3,
	STAGE4,
	STAGE5
	}

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream: AudioStreamInteractive = audio_stream_player.stream 

var previous_song: SONGLIST = SONGLIST.MAIN_MENU
var current_song: SONGLIST = SONGLIST.MAIN_MENU

func _ready() -> void:
	audio_stream_player.play() ## Must be done instead of autoplay in 4.4.1 to avoid web export crash

func play_music(song: SONGLIST) -> void:
	previous_song = current_song
	current_song = song
	audio_stream_player.get_stream_playback().switch_to_clip(song)

func play_previous_song() -> void:
	var song = previous_song
	play_music(song)
