extends Node3D


const TestDialogue = preload("uid://r63k0f2m0rdu")
const FirstDialogue = preload("uid://bqovvstfpyaf3")


func _ready() -> void:
	#await get_tree().create_timer(1.0).timeout
	DialogueWindow.show_dialogue(FirstDialogue.new())
	#await get_tree().create_timer(5.0).timeout
	#DialogueWindow.show_dialogue(TestDialogue.new())
