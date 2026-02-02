extends Node3D


const TestDialogue = preload("uid://r63k0f2m0rdu")
const FirstDialogue = preload("uid://bqovvstfpyaf3")
const MaskBuild1Dialogue = preload("uid://chqxpp1x54boe")
const MaskBuild2Dialogue = preload("uid://0p1vsfhdw78s")
@onready var rythm_node: RhythmNode = %RythmNode
const FinalDialogue = preload("uid://cqy5n2xlkvlw8")


func _ready() -> void:
	get_tree().root.min_size = Vector2i(1280, 720)
	rythm_node.start_song1()
	return
	DialogueWindow.show_dialogue(FirstDialogue.new())
	await DialogueWindow.dialogue_ended

	DialogueWindow.clear_transcript()
	DialogueWindow.show_dialogue(MaskBuild1Dialogue.new())
	await DialogueWindow.dialogue_ended
	$AudioStreamPlayer.stream_paused = true
	$AudioStreamPlayer.volume_linear = 0
	# TODO: Start song 1%
	rythm_node.start_song1()
	await rythm_node.song_end

	# TODO: Start song 1
	$AudioStreamPlayer.stream_paused = false
	$AudioStreamPlayer.volume_linear = 1
	DialogueWindow.clear_transcript()
	DialogueWindow.show_dialogue(MaskBuild2Dialogue.new())
	await DialogueWindow.dialogue_ended
	$AudioStreamPlayer.stream_paused = true
	$AudioStreamPlayer.volume_linear = 0
	# TODO: Start song 2
	rythm_node.start_song2()
	await rythm_node.song_end
	$AudioStreamPlayer.stream_paused = false
	$AudioStreamPlayer.volume_linear = 1
	# TODO: Start song 2
	#DialogueWindow.clear_transcript()
	#DialogueWindow.show_dialogue(MaskBuild2Dialogue.new())
	#await DialogueWindow.dialogue_ended
	DialogueWindow.clear_transcript()
	DialogueWindow.show_dialogue(FinalDialogue.new())
	await DialogueWindow.dialogue_ended
