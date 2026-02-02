class_name BeatFollower extends PathFollow3D
@export var timing: HitTime
var follow_enabled := false
static var despawn_time := 30.0 #despawn self after 30 seconds 
static var target_dist := 67.8 #where we are supposed to be when our time comes
static var min_dist := 0.001 #clamp min dist
static var max_dist := 128.21 #clamp max dist
static var march_speed := 60.0 #speed of person 25.0
@onready var label = $Label3D

func update_label():
	$Label3D.visible = true
	#$Label3D.text = timing._to_short_string()
	$Label3D.text = str(calc_progress_from_time(RhythmNode._song_time))

func mask_check(hitTime,subbeat):
	if(hitTime.equals(self.timing)):
		draw_mask()

func draw_mask():
	$MaskGuy.change_mask_vis(true)
	$MaskGuy.darken_color(timing.hit_type)
	
func setup_visuals():
	$MaskGuy.change_mask_vis(false)
	$MaskGuy.load_visuals_from_hit_type(timing.hit_type)

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
	'''
	E 0:00:09:144   beat_follower.gd:38 @ update_from_song_time(): The target vector can't be zero.
  <C++ Error>   Condition "p_target.is_zero_approx()" is true. Returning: Basis()
  <C++ Source>  core/math/basis.cpp:1035 @ looking_at()
  <Stack Trace> beat_follower.gd:38 @ update_from_song_time()
				beat_path.gd:18 @ _process()

	'''
	self.progress = clamp(target_dist - spawn_pos, min_dist, max_dist)
	#if ( self.progress > 66.23 and self.progress < 68.23):
		#print("hit sub in center")

func calc_progress_from_time(song_time):
	var time_until_hit = timing.song_time - song_time
	if time_until_hit < -despawn_time:
		self.queue_free()
	var march_sub_gap = march_speed * RhythmNode._subdivision_length
	var spawn_pos = march_sub_gap * time_until_hit
	return clamp(target_dist - spawn_pos, min_dist, max_dist)
