extends AnimationPlayer
func _ready():
	var anim_player = self
	var animation_name = "float"
	var anim_length = anim_player.get_animation(animation_name).length
	var random_offset = randf() * anim_length  # Random time between 0 and animation length
	anim_player.play_section(animation_name, random_offset)
