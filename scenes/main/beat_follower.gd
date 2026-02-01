class_name BeatFollower extends PathFollow3D
@export var timing: HitTime
static var despawn_time := 5.0 #despawn self after 5 seconds 
static var targe_dist := 67.3 #where we are supposed to be when our time comes
static var min_dist := 1000.0 #clamp min dist
static var max_dist := 1000.0 #clamp max dist
static var march_speed := 10.0 #speed of person

func update_from_song_time(song_time):
	#negative for upcoming, 0 for center, positive for leaving
	var march_sub_gap = march_speed * RhythmNode._subdivision_length
	pass
	
	#var song_offset = song_time - timing.song_time
	#self.progress = timing.song_time - song_time
	#how many seconds 
