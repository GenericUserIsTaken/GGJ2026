extends Node3D
'''
bpm: 140 (4/4 time)
104 measures of song (2:58.3) + about 2 measures of a crash cymbal at the end

140/60 = bps

140/30 * ? sec = 8 subdivisions
(8*30)/140 = sec for one measure


1 measure = ?
4 beats = 1 measure
8 subbeats = 1 measure (for convinience)

measure 30 subbeat 0
measure 30 subbeat 7
measure 30 subbeat 8 -> measure 31 subbeat 0

'''
const _bpm := 140.0
const _measure_length : float = (8.0*30.0)/_bpm
const _subdivision_length : float = 30.0/_bpm

@onready var music_player : AudioStreamPlayer= self.get_node("MaskSongDemo")
@export var _song_time := 0.0 #export to see time in editor
@export var _timings : Array[HitTime] = []
@export var _margin := 0.8



func _ready() -> void:
	music_player.play()
	var calctime := calc_songtime(36,4)
	#print(calctime, " : ",calc_measure(calctime)," : ",calc_subbeat(calctime))

func _process(delta: float) -> void:
		_song_time = music_player.get_playback_position()
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F:
			var newTime = HitTime.new(_song_time,calc_measure(_song_time),calc_subbeat(_song_time),HitTime.HitType.BEATA)
			_timings.append(newTime)
			print(newTime)
			
func calc_measure(song_time) -> int:
	return 1 + (song_time/_measure_length)
	
func calc_subbeat(song_time) -> int:
	var left :float = fmod(song_time,_measure_length)
	#print(left," : ",left/_subdivision_length, " : ",_subdivision_length)
	return left/_subdivision_length 
	
func calc_songtime(measure,subbeat) -> float:
	return (measure-1)*((8.0*30.0)/_bpm) + subbeat*(30.0/_bpm)
