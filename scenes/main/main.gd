extends Node3D


const TestDialogue = preload("uid://r63k0f2m0rdu")
const FirstDialogue = preload("uid://bqovvstfpyaf3")
const MaskBuild1Dialogue = preload("uid://chqxpp1x54boe")


func _ready() -> void:
	get_tree().root.min_size = Vector2i(1280, 720)

	#DialogueWindow.show_dialogue(FirstDialogue.new())
	#await DialogueWindow.dialogue_ended
	# TODO: Start song 1
	DialogueWindow.clear_transcript()
	DialogueWindow.show_dialogue(MaskBuild1Dialogue.new())
	await DialogueWindow.dialogue_ended
	# TODO: Start song 2
	DialogueWindow.clear_transcript()
	DialogueWindow.show_dialogue(MaskBuild1Dialogue.new())
	await DialogueWindow.dialogue_ended
