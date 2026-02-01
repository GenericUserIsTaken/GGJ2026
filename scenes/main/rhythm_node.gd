class_name RhythmNode extends Node3D
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
@export var _timing_index = 0
@export var _margin := 0.08

@export var last_subbeat := 0
@export var next_subbeat := _subdivision_length
@export var active_subbeat := -1
@export var active_subbeat_start := next_subbeat - _margin
@export var active_subbeat_end := next_subbeat + _margin

@export var last_measure := 1
@export var next_measure := _measure_length

#region calc methods for conversion between songtime and measures/subbeats
static func calc_measure(song_time) -> int:
	return 1 + floori((song_time/_measure_length))
	
static func calc_subbeat(song_time) -> int:
	var left :float = fmod(song_time,_measure_length)
	#print(left," : ",left/_subdivision_length, " : ",_subdivision_length)
	return floori(left/_subdivision_length) #have to floor to convert into int
	
static func calc_songtime(measure,subbeat) -> float:
	return (measure-1)*((8.0*30.0)/_bpm) + subbeat*(30.0/_bpm)
#endregion

func _ready() -> void:
	music_player.play()
	var data = load_data_from_file("res://timedata.txt")
	_timings = data
	for row in data:
		print(row)


func _process(delta: float) -> void:
		_song_time = music_player.get_playback_position() + AudioServer.get_time_since_last_mix()
		var target = get_next_target()
		if active_subbeat == -1 and _song_time >= active_subbeat_start:
			active_subbeat = last_subbeat+1
			#print("LEFT ",_song_time,": entered subbeat ",active_subbeat, " at song time ", _song_time," at calculated subbeat ", (calc_measure(_song_time)-1)*8+ calc_subbeat(_song_time)," leaving at ", active_subbeat_end)
			$Sprite3D.visible = true
			#emit entered signal
			var subbeat_target = calculate_subbeat(target)
			if(active_subbeat +1 == subbeat_target):
				print("next subbeat is a target! ",subbeat_target)
		if active_subbeat != -1 and _song_time > active_subbeat_end:
			active_subbeat = -1
			#emit left signal
			active_subbeat_start = next_subbeat - _margin
			#print("RIGHT ",_song_time,": left subbeat ",last_subbeat, " at song time ", _song_time, " at calculated subbeat ", (calc_measure(_song_time)-1)*8+ calc_subbeat(_song_time), " entering next at ", active_subbeat_start)
			active_subbeat_end = next_subbeat + _margin
			$Sprite3D.visible = false
			$Sprite3D2.visible = false
		if _song_time >= next_subbeat:
			last_subbeat += 1
			#print("MIDDLE ",_song_time,": entered new subbeat ",last_subbeat, " at ", _song_time, " ACTIVE SUBBEAT: ", active_subbeat)
			$Sprite3D2.visible = true
			#emit beat number
			next_subbeat += _subdivision_length
			#| | |
			#| |x|
		if _song_time >= next_measure:
			last_measure += 1
			next_measure += _measure_length
			#print("New measure: ", last_measure, " calculated measure: ", calc_measure(_song_time))
			if(target != null and last_measure +1 == target.measure):
				print("next measure is a target! ",target.measure)
				#load in the guys and make them tween
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F:
			#append_new_hit_time(_songtime)
			var target = get_next_target()
			var subbeat_target = calculate_subbeat(target)
			print("next subbeat target: ",subbeat_target)
			if (subbeat_target != -1 && active_subbeat == subbeat_target):
				print("Hit subbeat: ", active_subbeat, " with offset ", _song_time - target.song_time)
				

func calculate_subbeat(hittime : HitTime) -> int:
	if(hittime == null):
		return -1
	return (hittime.measure - 1) * 8 + hittime.subbeat

func get_next_target():
	if(_timing_index >= _timings.size()):
		return null
	if(_song_time > _timings[_timing_index].song_time + _margin):
		_timing_index += 1
		#print("new subbeat ",_timings[_timing_index])
		return get_next_target()
	return _timings[_timing_index]

func append_new_hit_time(songtime,hittype=HitTime.HitType.BEATF):
	var newTime = HitTime.new(calc_measure(songtime), calc_subbeat(songtime), hittype, songtime)
	_timings.append(newTime)
	print(newTime)

func load_data_from_file(path: String) -> Array[HitTime]:
	var result: Array[HitTime] = []
	var lookup: Array = [HitTime.HitType.BEATF,HitTime.HitType.BEATJ]

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + path)
		return result

	while file.get_position() < file.get_length():
		var line := file.get_line().strip_edges()

		if line.is_empty():
			continue

		var parts := line.split(" ", false)
		if parts.size() >= 3:
			var a = int(parts[0])
			var b = int(parts[1])
			var c = int(parts[2])
			result.append(HitTime.new(a, b, lookup[c-1]))

	return result
