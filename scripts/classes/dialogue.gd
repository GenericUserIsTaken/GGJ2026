@abstract class_name Dialogue extends Node


const DialogueWindow = preload("uid://cyhfyn2ceuyef")


var _dialogue_window: DialogueWindow


@abstract func dialogue() -> Array[DialogueOption]


func show(text: String):
	await _dialogue_window.show_text(text)
