extends Node3D


const TestDialogue = preload("uid://r63k0f2m0rdu")
const FirstDialogue = preload("uid://bqovvstfpyaf3")
const MaskBuild1Dialogue = preload("uid://chqxpp1x54boe")


func _ready() -> void:
	get_tree().root.min_size = Vector2i(1280, 720)
	pass
	#await get_tree().create_timer(1.0).timeout
	DialogueWindow.show_dialogue(MaskBuild1Dialogue.new())
	#await get_tree().create_timer(5.0).timeout
	#DialogueWindow.show_dialogue(TestDialogue.new())
