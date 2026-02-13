class_name RhythmNode extends Node3D
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
signal reset()
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

static func calc_songtime_for_hit(hit) -> float:
	return calc_songtime(hit.measure,hit.subbeat)
###STABLE FUNCTIONS

func calc_subbeat_offset(song_time):
	return (calc_measure(song_time)-1)*8+ calc_subbeat(song_time)

func subbeat_offset_to_time(subbeat_offset):
	return _subdivision_length * subbeat_offset

#input that can hit multiple targets at the same time
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_F or event.keycode == KEY_J):
			print("checking hit ",_ignore_index+1, " : ",_range_index+3)
			for i in range(_ignore_index, _range_index+3): #inclusive,exclusive
				print(_target_list[i].in_range(_song_time, _margin))
				if(not _target_list[i].hit and _target_list[i].in_range(_song_time, _margin)):
					_target_list[i].hit = true
					hit.emit(_target_list[i])
					print("hit someone")


#hit type list, ignore index to start, go until ignore index again
#ignore index set to target that is time + margin < songtime
#in between is possibly in range
#until range_index set to target that is songtime < time - margin 
#TODO also we shouldn't dynamically load beats, just spawn them all in at start of song
func start_song1()-> void:
	reset.emit()
	_target_list = load_data_from_file("res://beatmap_1.txt")
	for row in _target_list:
		print(_song_time," :: ",row)
	music_player = music_player1
	spawn_all_visuals_in_target_list()
	music_player.play()
	music_player.finished.connect(self.song_end_callback)
	
func start_song2()-> void:
	print(_song_time," :: ",'starting song 2')
	reset.emit()
	_target_list = load_data_from_file("res://beatmap_2.txt")
	for row in _target_list:
		print(_song_time," :: ",row)
	music_player = music_player2
	spawn_all_visuals_in_target_list()
	music_player.play()
	music_player.finished.connect(self.song_end_callback)

func load_data_from_file(path: String) -> Array[HitTime]:
	var result: Array[HitTime] = []
	var lookup: Array = [HitTime.HitType.BEATF,HitTime.HitType.BEATJ]

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + path)
		return result

	var id = 0
	while file.get_position() < file.get_length():
		var line := file.get_line().strip_edges()

		if line.is_empty():
			continue

		var parts := line.split(" ", false)
		if parts.size() >= 3:
			var a = int(parts[0]) #measure
			var b = int(parts[1]) #subbeat
			var c = int(parts[2])+1 #hittype, remove plus one if default at 1 and 2 instead of 0 and 1
			var new_hit = HitTime.new(a, b, lookup[c-1],id)
			id+=1
			result.append(new_hit)
	return result

func spawn_all_visuals_in_target_list():
	for i in _target_list:
		spawn_new_visual.emit(i)

func song_end_callback():
	song_end.emit()

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
		#update ignore_index, move as right as possible
		#if a target passes behind the margin and was never hit → MISS
		while _ignore_index + 1 < _target_list.size():
			var next := _target_list[_ignore_index + 1]
			if calc_songtime_for_hit(next) + _margin < _song_time:
				_ignore_index += 1
				if not next.hit:
					miss.emit(next)
			else:
				break

		# update range_index
		# Move range_index right while targets are still ahead of the margin
		# range_index stops when the next target is too far in the future
		while _range_index + 1 < _target_list.size():
			var next := _target_list[_range_index + 1]
			if _song_time < calc_songtime_for_hit(next) - _margin:
				break
			_range_index += 1
			
		#update visual element (cursor only), by emiting all the timings that are in range, so it can figure out what color to display
		var out = []
		for i in range(_ignore_index+1, _range_index): #inclusive,exclusive
				if(_target_list[i].in_range(_song_time, _margin)):
					out.append(_target_list[i])
		update_cursor_color.emit(out)
