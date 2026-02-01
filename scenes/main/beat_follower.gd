class_name BeatFollower extends PathFollow3D
@export var timing: HitTime
var follow_enabled := false
static var despawn_time := 30.0 #despawn self after 30 seconds 
static var target_dist := 67.8 #where we are supposed to be when our time comes
static var min_dist := 0.0 #clamp min dist
static var max_dist := 128.21 #clamp max dist
static var march_speed := 25.0 #speed of person

func update_label():
	$Label3D.text = timing._to_short_string()

func update_from_song_time(song_time):
	if(not follow_enabled):
		return
	if self.timing == null:
		push_warning("CANNOT FOLLOW BEAT WITH NULL TIMING INFO")
		return
	var time_until_hit = timing.song_time - song_time
	if time_until_hit < -despawn_time:
		self.queue_free()
	var march_sub_gap = march_speed * RhythmNode._subdivision_length
	var spawn_pos = march_sub_gap * time_until_hit
	self.progress = clamp(target_dist - spawn_pos, min_dist, max_dist)
	#if ( self.progress > 66.23 and self.progress < 68.23):
		#print("hit sub in center")
