extends Node3D
'''
bpm: 140 (4/4 time)
104 measures of song (2:58.3) + about 2 measures of a crash cymbal at the end
'''
@onready var music_player : AudioStreamPlayer= self.get_node("MaskSongDemo")

@export var song_time := 0 #export to see time in editor
@export var timings : Array[HitTime] = []

func _ready() -> void:
	music_player.play()

func _process(delta: float) -> void:
		song_time = music_player.get_playback_position()
