class_name DialogueWindow extends Control


const ICON = preload("uid://isbqsoevkfnm")

const TestDialogue = preload("uid://r63k0f2m0rdu")


@onready var options_grid: GridContainer = %OptionsGrid
@onready var transcript: RichTextLabel = %Transcript


func _ready() -> void:
	transcript.text = ""
	show_dialogue(make_dialogue_object(TestDialogue).dialogue)


func show_dialogue(dialogue: Callable) -> void:
	var options: Array[DialogueOption] = await dialogue.call()
	for child in options_grid.get_children():
		child.queue_free()

	for option in options:
		var icon_wrapper := Control.new()
		var icon := TextureRect.new()
		icon.texture = ICON
		icon_wrapper.custom_minimum_size = Vector2(26, 26)
		icon_wrapper.add_child(icon)
		options_grid.add_child(icon_wrapper)
		var label := Label.new()
		label.text = option.option_title
		options_grid.add_child(label)


func show_text(text: String) -> void:
	transcript.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	transcript.append_text(text)
	transcript.pop()
	await get_tree().create_timer(0.25).timeout


func make_dialogue_object(dialogue: Script) -> Dialogue:
	var obj: Dialogue = dialogue.new()
	obj._dialogue_window = self
	add_child(obj)
	return obj
