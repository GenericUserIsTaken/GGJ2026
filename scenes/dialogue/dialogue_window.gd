@tool
extends Control


enum OptionsState {
	HIDDEN,
	OPTIONS_HIDDEN,
	OPTIONS_SHOWN,
	MASK,
}


signal dialogue_started
signal dialogue_options_shown
signal dialogue_advanced(option_picked: DialogueOption)
signal dialogue_ended

signal selected_option_changed(new_selected_option: int)


@onready var _options_outer_container: PanelContainer = %OptionsOuterContainer
@onready var _options_container: PanelContainer = %OptionsContainer
@onready var _options_vbox: Container = %OptionsGrid
@onready var _transcript: VBoxContainer = %Transcript
@onready var _transcript_scroll_container: ScrollContainer = %TranscriptScrollContainer
@onready var _left_side_container: VBoxContainer = %LeftSideContainer
@onready var _center_spacer_control: Control = %CenterSpacerControl
@onready var _left_top_spacer_control: Control = %LeftTopSpacerControl
@onready var _transcript_container: PanelContainer = %TranscriptContainer
@onready var _continue_indicator: Control = %ContinueIndicator
@onready var _mask_vbox: VBoxContainer = %MaskGrid


@export_tool_button("Animate to hidden", "Tween") var animate_to_state_hidden := _animate.bind(OptionsState.HIDDEN)
@export_tool_button("Animate to options hidden", "Tween") var animate_to_state_options_hidden := _animate.bind(OptionsState.OPTIONS_HIDDEN)
@export_tool_button("Animate to dialogue options", "Tween") var animate_to_state_dialogue_options := _animate.bind(OptionsState.OPTIONS_SHOWN)
@export_tool_button("Animate to mask config", "Tween") var animate_to_state_mask := _animate.bind(OptionsState.MASK)


var selected_option: int:
	set(value):
		selected_option = value
		selected_option_changed.emit(value)
var displayed_options: Array[DialogueOption]
var active_dialog: Dialogue = null
var _option_widgets: Array[DialogueOptionWidget]

## Whether new dialogue is actively being shown.
var is_dialogue_running: bool = false


func _fix_tree_order() -> void:
	get_parent().move_child(self, get_parent().get_child_count() - 1)


func _ready() -> void:
	if Engine.is_editor_hint() and get_parent() == get_tree().root:
		hide()
	selected_option_changed.connect(
		func(selected: int):
			var i := 0
			for option in _option_widgets:
				option.set_selected(selected == i)
				i += 1
	)
	if not Engine.is_editor_hint():
		_animate(OptionsState.HIDDEN, 0.0)
		hide()
		_continue_indicator.hide()
		await get_parent().ready
		_fix_tree_order()


func _unhandled_input(event: InputEvent) -> void:
	if is_dialogue_running:
		pass
	elif event.is_action_pressed("ui_down", true) and selected_option < displayed_options.size() - 1:
		selected_option += 1
	elif event.is_action_pressed("ui_up", true) and selected_option > 0:
		selected_option -= 1
	elif event.is_action_pressed("ui_accept", true):
		if displayed_options.is_empty():
			await active_dialog.dialogue_end()
			dialogue_ended.emit()
			active_dialog = null
			_animate(OptionsState.HIDDEN)
		else:
			var option := displayed_options[selected_option]
			dialogue_advanced.emit(option)
			show_text("[dialogue_response]%s[/dialogue_response]" % option.option_title)
			await _animate(OptionsState.OPTIONS_HIDDEN)
			_show_dialogue_func(option.option_callback)

## Show a [Dialogue] option.
## [br]
## This handles animating the visibility of the dialogue overlay, then starts at [param dialogue]'s [method Dialogue.dialogue] entry point.
## A set of options is then shown to the user once it finishes, allowing the user to choose between which of the next dialogues to show.
func show_dialogue(dialogue: Dialogue) -> void:
	if _tween.is_running():
		await _tween.finished
	dialogue._dialogue_window = self
	active_dialog = dialogue
	_animate(OptionsState.OPTIONS_HIDDEN)
	dialogue_started.emit()
	_show_dialogue_func(dialogue.dialogue)

## Clear the _transcript view.
## This doesn't do any sort of animation.
func clear_transcript() -> void:
	for child in _transcript.get_children():
		child.queue_free()


var _tween: Tween = null


func _animate(state: OptionsState, time: float = 0.75) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel()
	match state:
		OptionsState.HIDDEN:
			_tween.tween_property(_center_spacer_control, "size_flags_stretch_ratio", 0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_transcript_container, "size_flags_stretch_ratio", 0.5, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_left_top_spacer_control, "size_flags_stretch_ratio", 1.5, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_outer_container, "size_flags_stretch_ratio", 0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_left_side_container, "size_flags_stretch_ratio", 1.5, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_vbox, "scale", Vector2.ZERO, time * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_mask_vbox, "scale", Vector2.ZERO, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_container, "modulate:a", 0.0, time * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			_tween.tween_property(_transcript_container, "modulate:a", 0.0, time * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			_tween.chain().tween_callback(hide)
		OptionsState.OPTIONS_HIDDEN:
			_tween.tween_callback(show)
			_tween.tween_property(_center_spacer_control, "size_flags_stretch_ratio", 0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_transcript_container, "size_flags_stretch_ratio", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_left_top_spacer_control, "size_flags_stretch_ratio", 1.5, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_outer_container, "size_flags_stretch_ratio", 0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_left_side_container, "size_flags_stretch_ratio", 1.5, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_vbox, "scale", Vector2.ZERO, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_mask_vbox, "scale", Vector2.ZERO, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_container, "modulate:a", 0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			_tween.tween_property(_transcript_container, "modulate:a", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		OptionsState.OPTIONS_SHOWN:
			_tween.tween_callback(show)
			_tween.tween_property(_center_spacer_control, "size_flags_stretch_ratio", 0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_transcript_container, "size_flags_stretch_ratio", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_left_top_spacer_control, "size_flags_stretch_ratio", 1.5, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_outer_container, "size_flags_stretch_ratio", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_left_side_container, "size_flags_stretch_ratio", 1.5, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_vbox, "scale", Vector2.ONE, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_mask_vbox, "scale", Vector2.ZERO, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_container, "modulate:a", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			_tween.tween_property(_transcript_container, "modulate:a", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		OptionsState.MASK:
			_tween.tween_callback(show)
			_tween.tween_property(_center_spacer_control, "size_flags_stretch_ratio", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_transcript_container, "size_flags_stretch_ratio", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_left_top_spacer_control, "size_flags_stretch_ratio", 0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_outer_container, "size_flags_stretch_ratio", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_left_side_container, "size_flags_stretch_ratio", 1.5, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_vbox, "scale", Vector2.ZERO, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_mask_vbox, "scale", Vector2.ONE, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			_tween.tween_property(_options_container, "modulate:a", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			_tween.tween_property(_transcript_container, "modulate:a", 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await _tween.finished


func _show_dialogue_func(dialogue: Callable) -> void:
	for child in _options_vbox.get_children():
		child.queue_free()
	_option_widgets.clear()
	displayed_options.clear()
	selected_option = 0

	is_dialogue_running = true
	var options: Array[DialogueOption] = await dialogue.call()
	is_dialogue_running = false
	displayed_options = options
	var i := 0
	for option in options:
		var widget := DialogueOptionWidget.new(option.option_title)
		_options_vbox.add_child(widget)
		widget.hovered.connect(func(): selected_option = i)
		widget.clicked.connect(_show_dialogue_func.bind(option.option_callback))
		_option_widgets.append(widget)
		i += 1
	selected_option = 0
	dialogue_options_shown.emit()
	if displayed_options.is_empty():
		_continue_indicator.show()
	else:
		await _animate(OptionsState.OPTIONS_SHOWN)


var _scroll_tween: Tween = null

## Show a piece of text in the transcript.
## This does animate the text and scroll.
func show_text(text: String) -> void:
	var dialogue := DialogueTranscript.new()
	dialogue.label.append_text("[dialogue_text start_time=\"%s\"]%s[/dialogue_text]" % [Time.get_ticks_msec(), text])
	dialogue.label.fit_content = true
	dialogue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_transcript.add_child(dialogue)
	get_tree().process_frame.connect(
		func():
			if _scroll_tween:
				_scroll_tween.kill()
			_scroll_tween = create_tween()
			_scroll_tween.tween_property(_transcript_scroll_container, "scroll_vertical", _transcript.size.y - _transcript_scroll_container.size.y, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO),
		CONNECT_ONE_SHOT
	)
	await get_tree().create_timer(1.0).timeout


func show_mask_config() -> void:
	await _animate(OptionsState.MASK)
	await get_tree().create_timer(2.0).timeout


func make_dialogue_object(dialogue: GDScript) -> Dialogue:
	var obj: Dialogue = dialogue.new()
	obj._dialogue_window = self
	add_child(obj)
	return obj


class DialogueOptionWidget extends HBoxContainer:
	signal hovered
	signal clicked

	const ICON = preload("uid://isbqsoevkfnm")

	var text: String
	var icon := TextureRect.new()

	func _init(_text: String) -> void:
		text = _text

	func _ready() -> void:
		icon.texture = ICON
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		add_child(icon)
		var label := Label.new()
		label.text = text
		add_child(label)

		mouse_entered.connect(hovered.emit)
		set_selected(false)

	func _gui_input(event: InputEvent) -> void:
		var mb := event as InputEventMouseButton
		if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()

	func set_selected(selected: bool) -> void:
		icon.visible = selected


class DialogueTranscript extends Container:
	var label := RichTextLabel.new()
	var x_offset: float:
		set(value):
			x_offset = value
			queue_sort()

	func _init() -> void:
		label.install_effect(preload("dialogue_response_rich_text_effect.gd").new())
		label.install_effect(preload("dialogue_text_rich_text_effect.gd").new())
		label.minimum_size_changed.connect(update_minimum_size)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(label)

	func _get_minimum_size() -> Vector2:
		return label.get_combined_minimum_size()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_SORT_CHILDREN:
			fit_child_in_rect(label, Rect2(Vector2(x_offset, 0.0), size))
