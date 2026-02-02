class_name RhythmNode2 extends Node3D
const _bpm := 140.0
const _measure_length : float = (8.0*30.0)/_bpm
const _subdivision_length : float = 30.0/_bpm

@onready var music_player : AudioStreamPlayer= self.get_node("MaskSongDemo")
@onready var music_player1 : AudioStreamPlayer= self.get_node("MaskGameRhythmTheme1")
@onready var music_player2 : AudioStreamPlayer= self.get_node("MaskGameRhythmTheme2")

static var _song_time := 0.0

@export var _margin := 0.1 #0.08 margin recomended for serious rhythm games
@export var _target_list : Array[HitTime] = []
@export var _ignore_index = -1
@export var _range_index = -1

signal spawn_new_visual(timing)
signal song_end()

signal hit(timing)
signal miss(timing)

signal update_cursor_color(current_hits_in_range)

###STABLE FUNCTIONS
static func calc_measure(song_time) -> int:
	return 1 + floori((song_time/_measure_length))
	
static func calc_subbeat(song_time) -> int:
	var left :float = fmod(song_time,_measure_length)
	return floori(left/_subdivision_length) #have to floor to convert into int
	
static func calc_songtime(measure,subbeat) -> float:
	return (measure-1)*((8.0*30.0)/_bpm) + subbeat*(30.0/_bpm)
###STABLE FUNCTIONS

func calc_subbeat_offset(song_time):
	return (calc_measure(song_time)-1)*8+ calc_subbeat(song_time)

func subbeat_offset_to_time(subbeat_offset):
	return _subdivision_length * subbeat_offset

#input that can hit multiple targets at the same time
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_F or event.keycode == KEY_J):
			for i in range(_ignore_index+1, _range_index): #inclusive,exclusive
				if(_target_list[i].not_hit and _target_list[i].in_range(_song_time, _margin)):
					_target_list[i].not_hit = false
					hit.emit(_target_list[i])


#hit type list, ignore index to start, go until ignore index again
#ignore index set to target that is time + margin < songtime
#in between is possibly in range
#until range_index set to target that is songtime < time - margin 
#TODO also we shouldn't dynamically load beats, just spawn them all in at start of song


func _process(delta: float) -> void:
		#what is the point of process?
		#to update ignore_index and range_index
		#to update miss counter

		#to update any visual elements that require beat start/end
			#so far only visual elements that reacts to beat start/end is the colored arrow that is meant to be a ui indicator of timing
		#so we need start and end times of beat
		#but how to update visual elements if the assumption is that margins may overlap?


		#get song time
		_song_time = music_player.get_playback_position() + AudioServer.get_time_since_last_mix()
		#TODO update ignore_index, move as right as possible
			#TODO while moving right, any that are not hit should be added to miss counter (miss.emit)
		#TODO update range_index, move as right as possible
		
		#update visual element (cursor only), by emiting all the timings that are in range, so it can figure out what color to display
		var out = []
		for i in range(_ignore_index+1, _range_index): #inclusive,exclusive
				if(_target_list[i].in_range(_song_time, _margin)):
					out.append(_target_list[i])
		update_cursor_color.emit(out)
