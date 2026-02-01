## The base class of all dialogue interactions.
@abstract class_name Dialogue extends Node


const DialogueWindow = preload("uid://cyhfyn2ceuyef")


var dialogue_window: DialogueWindow
var guy: DialogueGuyScene:
	get: return dialogue_window.dialogue_mask_guy

## The entry point into the dialogue interaction.
## [br]
## Call various functions, such as [method show] to display text on the transcript, or other functions to trigger behaviors in the game world.
## [br]
## Return a set of [DialogueOption]s, representing the various actions a player can take.
@abstract func dialogue() -> Array[DialogueOption]


func dialogue_end() -> void:
	@warning_ignore("redundant_await") await null


func dialogue_setup() -> void:
	pass


func show(text: String) -> void:
	await dialogue_window.show_text(text)


func pause(time: float) -> void:
	await dialogue_window.get_tree().create_timer(time).timeout
