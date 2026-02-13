extends Path3D
var beat_follower = preload("res://scenes/main/beat_follower.tscn")
@export var beat_follower_count = 0

func _on_rythm_node_spawn_new_visual(timing: Variant) -> void:
	var new_follower = beat_follower.instantiate()
	self.add_child(new_follower)
	new_follower.timing = timing
	new_follower.follow_enabled = true
	new_follower.progress = 0
	new_follower.setup_visuals()
	%RythmNode.hit.connect(new_follower.mask_check)
	beat_follower_count+=1
	new_follower.update_label()

func _process(delta: float) -> void:
	for i in self.get_children():
		i.update_from_song_time(RhythmNode._song_time)


func _on_rythm_node_reset() -> void:
	for child in self.get_children():
		child.queue_free()
