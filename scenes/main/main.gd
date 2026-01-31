extends Node3D


const TestDialogue = preload("uid://r63k0f2m0rdu")


func _ready() -> void:
	#await get_tree().create_timer(1.0).timeout
	DialogueWindow.show_dialogue(TestDialogue.new())
	await get_tree().create_timer(10.0).timeout
	DialogueWindow.show_dialogue(TestDialogue.new())
